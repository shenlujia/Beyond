### GCD介绍

Grand Central Dispatch(GCD)是Apple推出的一套多线程解决方案，它拥有系统级的线程管理机制，开发者不需要再管理线程的生命周期，只需要关注于要执行的任务即可。

本系列文章会从源码层面分析GCD的原理，总结GCD的用法和需要注意的地方，因此后续的文章都会从使用篇->原理篇->总结篇来讲，不太关心原理的可重点看下开头的`使用篇`和结尾的`总结篇`。

GCD的源码libdispatch版本很多，源代码风格各版本都有不同，但大体逻辑没有太大变化。libdispatch的源码下载地址[在这里](https://opensource.apple.com/tarballs/libdispatch/),我选择阅读的版本是`libdispatch-339.92.1`。

### 基础知识

阅读GCD的源码之前，先了解一些相关知识，方便后面的理解。

##### DISPATCH_DECL

```
#define DISPATCH_DECL(name) typedef struct name##_s *name##_t
```

GCD中的变量大多使用了这个宏，比如`DISPATCH_DECL(dispatch_queue)`展开后是

```
typedef struct dispatch_queue_s *dispatch_queue_t；
```

它的意思是定义一个`dispatch_queue_t`类型的指针，指向了一个`dispatch_queue_s`类型的结构体。

##### fastpath vs slowpath

```
#define fastpath(x) ((typeof(x))__builtin_expect((long)(x), ~0l))
#define slowpath(x) ((typeof(x))__builtin_expect((long)(x), 0l))
```

`__builtin_expect`是编译器用来优化执行速度的函数，fastpath表示条件更可能成立，slowpath表示条件更不可能成立。我们在阅读源码的时候可以做忽略处理。

##### TSD

Thread Specific Data(TSD)是指线程私有数据。在多线程中，会用全局变量来实现多个函数间的数据共享，局部变量来实现内部的单独访问。TSD则是能够在同一个线程的不同函数中被访问，在不同线程时，相同的键值获取的数据随线程不同而不同。可以通过pthread的相关api来实现TSD:

```
//创建key
int pthread_key_create(pthread_key_t *, void (* _Nullable)(void *));
//get方法
void* _Nullable pthread_getspecific(pthread_key_t);
//set方法
int pthread_setspecific(pthread_key_t , const void * _Nullable);
```

### 常用数据结构

dispatch_object_s是GCD最基础的结构体，定义如下：

```
//GCD的基础结构体
struct dispatch_object_s {
    DISPATCH_STRUCT_HEADER(object);
};

//os object头部宏定义
#define _OS_OBJECT_HEADER(isa, ref_cnt, xref_cnt) \
        isa; /* must be pointer-sized */ \  //isa
        int volatile ref_cnt; \             //引用计数
        int volatile xref_cnt               //外部引用计数，两者都为0时释放

//dispatch结构体头部
#define DISPATCH_STRUCT_HEADER(x) \
    _OS_OBJECT_HEADER( \
    const struct dispatch_##x##_vtable_s *do_vtable, \  //vtable结构体
    do_ref_cnt, \
    do_xref_cnt); \                            
    struct dispatch_##x##_s *volatile do_next; \   //下一个do
    struct dispatch_queue_s *do_targetq; \         //目标队列
    void *do_ctxt; \                               //上下文
    void *do_finalizer; \                          //销毁时调用函数
    unsigned int do_suspend_cnt;                   //suspend计数，用作暂停标志

```

dispatch_continuation_s结构体主要封装block和function，`dispatch_async`中的block最终都会封装成这个数据类型，定义如下：

```
struct dispatch_continuation_s {
    DISPATCH_CONTINUATION_HEADER(continuation);
};

//continuation结构体头部
#define DISPATCH_CONTINUATION_HEADER(x) \
    _OS_OBJECT_HEADER( \
    const void *do_vtable, \                            do_ref_cnt, \
    do_xref_cnt); \                                 //_OS_OBJECT_HEADER定义
    struct dispatch_##x##_s *volatile do_next; \    //下一个任务
    dispatch_function_t dc_func; \                  //执行内容
    void *dc_ctxt; \                                //上下文
    void *dc_data; \                                //相关数据
    void *dc_other;                                 //其他
```

dispatch_object_t是个union的联合体，可以用dispatch_object_t代表这个联合体里的所有数据结构。

```
typedef union {
    struct _os_object_s *_os_obj;
    struct dispatch_object_s *_do;             //object结构体
    struct dispatch_continuation_s *_dc;       //任务,dispatch_aync的block会封装成这个数据结构
    struct dispatch_queue_s *_dq;              //队列
    struct dispatch_queue_attr_s *_dqa;        //队列属性
    struct dispatch_group_s *_dg;              //群组操作
    struct dispatch_source_s *_ds;             //source结构体
    struct dispatch_mach_s *_dm;
    struct dispatch_mach_msg_s *_dmsg;
    struct dispatch_timer_aggregate_s *_dta;
    struct dispatch_source_attr_s *_dsa;       //source属性
    struct dispatch_semaphore_s *_dsema;       //信号量
    struct dispatch_data_s *_ddata;
    struct dispatch_io_s *_dchannel;
    struct dispatch_operation_s *_doperation;
    struct dispatch_disk_s *_ddisk;
} dispatch_object_t __attribute__((__transparent_union__));
```

GCD中常见结构体（比如queue、semaphore等）的vtable字段中定义了很多函数回调，在后续代码分析中会经常看到，定义如下所示：

```
//dispatch vtable的头部
#define DISPATCH_VTABLE_HEADER(x) \
    unsigned long const do_type; \     //类型
    const char *const do_kind; \       //种类，比如:group/queue/semaphore
    size_t (*const do_debug)(struct dispatch_##x##_s *, char *, size_t); \ //debug用
    void (*const do_invoke)(struct dispatch_##x##_s *); \    //invoke回调
    unsigned long (*const do_probe)(struct dispatch_##x##_s *); \   //probe回调
    void (*const do_dispose)(struct dispatch_##x##_s *);     //dispose回调，销毁时调用

//dx_xxx开头的宏定义，后续文章会用到，本质是调用vtable的do_xxx
#define dx_type(x) (x)->do_vtable->do_type
#define dx_metatype(x) ((x)->do_vtable->do_type & _DISPATCH_META_TYPE_MASK)
#define dx_kind(x) (x)->do_vtable->do_kind
#define dx_debug(x, y, z) (x)->do_vtable->do_debug((x), (y), (z))
#define dx_dispose(x) (x)->do_vtable->do_dispose(x)
#define dx_invoke(x) (x)->do_vtable->do_invoke(x)
#define dx_probe(x) (x)->do_vtable->do_probe(x)
```

dispatch_queue_s是队列的结构体，也是GCD中开发者接触最多的结构体了，定义如下：

```
struct dispatch_queue_s {
    DISPATCH_STRUCT_HEADER(queue);    //基础header
    DISPATCH_QUEUE_HEADER;            //队列头部，见下面的定义
    DISPATCH_QUEUE_CACHELINE_PADDING; // for static queues only
};
//队列自己的头部定义
#define DISPATCH_QUEUE_HEADER \
    uint32_t volatile dq_running; \                       //队列运行的任务数量
    struct dispatch_object_s *volatile dq_items_head; \   //链表头部节点
    struct dispatch_object_s *volatile dq_items_tail; \   //链表尾部节点
    dispatch_queue_t dq_specific_q; \                     //specific队列
    uint32_t dq_width; \                                  //队列并发数
    unsigned int dq_is_thread_bound:1; \                  //是否线程绑定
    unsigned long dq_serialnum; \                         //队列的序列号
    const char *dq_label; \                               //队列名
    DISPATCH_INTROSPECTION_QUEUE_LIST;
```

队列的do_table中有很多函数指针，阅读queue的源码时会遇到dx_invoke或者dx_probe等函数，它们其实就是调用vtable中定义的函数。下面看一下相关定义：

```
//main-queue和普通queue的vtable定义
DISPATCH_VTABLE_INSTANCE(queue,
    .do_type = DISPATCH_QUEUE_TYPE,
    .do_kind = "queue",
    .do_dispose = _dispatch_queue_dispose,    //销毁时调用
    .do_invoke = _dispatch_queue_invoke,      //invoke函数
    .do_probe = _dispatch_queue_probe,        //probe函数
    .do_debug = dispatch_queue_debug,         //debug回调
);
//global-queue的vtable定义
DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_root, queue,
    .do_type = DISPATCH_QUEUE_ROOT_TYPE,
    .do_kind = "global-queue",
    .do_dispose = _dispatch_pthread_root_queue_dispose,  //global-queue销毁时调用
    .do_probe = _dispatch_root_queue_probe,              //_dispatch_wakeup时会调用
    .do_debug = dispatch_queue_debug,                    //debug回调
);
```

### 总结

上述是阅读GCD源码前的基础介绍，后续分析会详细讲解到。该系列参考学习了一些优秀博客的文章，链接见参考资料。

### 参考资料：

- [深入理解RunLoop](https://blog.ibireme.com/2015/05/18/runloop/)
- [GCD源码下载地址](https://opensource.apple.com/tarballs/libdispatch/)
- [深入理解GCD](https://bestswifter.com/deep-gcd/)
- [GCD源码分析](http://lingyuncxb.com/2018/01/31/GCD源码分析1+——+开篇/)
- [扒了扒libdispatch源码](http://joeleee.github.io/2017/02/21/005.扒了扒libdispatch源码/)
- [GCD源码分析](https://yq.aliyun.com/articles/61328)
- [关于GCD开发的一些事儿](https://www.jianshu.com/p/f9e01c69a46f)
- [GCD 深入理解：第一部分](https://github.com/nixzhu/dev-blog/blob/master/2014-04-19-grand-central-dispatch-in-depth-part-1.md)
- [GCD教程](http://www.dreamingwish.com/article/gcdgrand-central-dispatch-jiao-cheng.html)