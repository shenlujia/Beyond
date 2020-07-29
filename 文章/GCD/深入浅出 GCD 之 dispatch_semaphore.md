### 概述

Dispatch Semaphore是持有计数的信号，该信号是多线程编程中的计数类型信号。信号类似于过马路时的手旗，可以通过时举起手旗，不可通过时放下手旗。而在Dispatch Semaphore中使用了计数来实现该功能。计数为0时等待，计数为1或者大于1时放行。

信号量的使用比较简单，主要就三个API：`create`、`wait`和`signal`。

### 使用篇

`dispatch_semaphore_create`可以生成信号量，参数value是信号量计数的初始值；`dispatch_semaphore_wait`会让信号量值减一，当信号量值为0时会等待(直到超时)，否则正常执行；
`dispatch_semaphore_signal`会让信号量值加一，如果有通过`dispatch_semaphore_wait`函数等待Dispatch Semaphore的计数值增加的线程，会由系统唤醒最先等待的线程执行。

接下来具体看一下信号量的用法：
1、信号量常用于对资源进行加锁操作，防止多线程访问修改数据出现结果不一致甚至崩溃的问题，代码示例如下:

```
//在init等函数初始化
_lock = dispatch_semaphore_create(1); 
dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); 
//修改Array或字典等数据的信息

dispatch_semaphore_signal(_lock);
```

2、信号量也可用于链式请求，比如用来限制请求频次：

```
//链式请求，限制网络请求串行执行，第一个请求成功后再开始第二个请求
- (void)chainRequestCurrentConfig {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *list = @[@"1",@"2",@"3"];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self fetchConfigurationWithCompletion:^(NSDictionary *dict) {
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }];
    });
}
- (void)fetchConfigurationWithCompletion:(void(^)(NSDictionary *dict))completion {
    //AFNetworking或其他网络请求库
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模拟网络请求
        sleep(2);
        !completion ? nil : completion(nil);
    });
}
```

以上是信号量的简单用法，接下来看一下Dispatch Semaphore的原理和实现。

### 原理篇

#### dispatch_semaphore_t

首先看一下`dispatch_semaphore_s`的结构体定义：

```
struct dispatch_semaphore_s {
    DISPATCH_STRUCT_HEADER(semaphore);
    semaphore_t dsema_port;    //等同于mach_port_t信号
    long dsema_orig;           //初始化的信号量值
    long volatile dsema_value; //当前信号量值
    union {
        long volatile dsema_sent_ksignals;
        long volatile dsema_group_waiters;
    };
    struct dispatch_continuation_s *volatile dsema_notify_head; //notify的链表头部
    struct dispatch_continuation_s *volatile dsema_notify_tail; //notify的链表尾部
};
```

#### dispatch_semaphore_create

`dispatch_semaphore_create`用来创建信号量，创建时需要指定value，内部会将value的值存储到dsema_value(当前的value)和dsema_orig(初始value)中，value的值必须大于或等于0。

```
dispatch_semaphore_t dispatch_semaphore_create(long value) {
    dispatch_semaphore_t dsema;
    if (value < 0) {
       //value值需大于或等于0
        return NULL;
    }
  //申请dispatch_semaphore_t的内存
    dsema = (dispatch_semaphore_t)_dispatch_alloc(DISPATCH_VTABLE(semaphore),
            sizeof(struct dispatch_semaphore_s) -
            sizeof(dsema->dsema_notify_head) -
            sizeof(dsema->dsema_notify_tail));
    //调用初始化函数
    _dispatch_semaphore_init(value, dsema);
    return dsema;
}
//初始化结构体信息
static void _dispatch_semaphore_init(long value, dispatch_object_t dou) {
    dispatch_semaphore_t dsema = dou._dsema;
    dsema->do_next = (dispatch_semaphore_t)DISPATCH_OBJECT_LISTLESS;
    dsema->do_targetq = dispatch_get_global_queue(
            DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dsema->dsema_value = value; //设置信号量的当前value值
    dsema->dsema_orig = value;  //设置信号量的初始value值
}
```

##### 接着来看Dispatch Semaphore很容易忽略也是最容易造成App崩溃的地方，即信号量的释放。

创建Semaphore的时候会将do_vtable指向_dispatch_semaphore_vtable，_dispatch_semaphore_vtable的结构定义了信号量销毁的时候会执行`_dispatch_semaphore_dispose`方法，相关代码实现如下

```
//semaphore的vtable定义
DISPATCH_VTABLE_INSTANCE(semaphore,
    .do_type = DISPATCH_SEMAPHORE_TYPE,
    .do_kind = "semaphore",
    .do_dispose = _dispatch_semaphore_dispose,  //销毁时执行的回调函数
    .do_debug = _dispatch_semaphore_debug,      //debug函数
);
//释放信号量的函数
void _dispatch_semaphore_dispose(dispatch_object_t dou) {
    dispatch_semaphore_t dsema = dou._dsema;

    if (dsema->dsema_value < dsema->dsema_orig) {
       //Warning:信号量还在使用的时候销毁会造成崩溃
        DISPATCH_CLIENT_CRASH(
                "Semaphore/group object deallocated while in use");
    }
    kern_return_t kr;
    if (dsema->dsema_port) {
        kr = semaphore_destroy(mach_task_self(), dsema->dsema_port);
        DISPATCH_SEMAPHORE_VERIFY_KR(kr);
    }
}
```

如果销毁时信号量还在使用，那么dsema_value会小于dsema_orig，则会引起崩溃，这是一个特别需要注意的地方。这里模拟一下信号量崩溃的代码:

```
dispatch_semaphore_t semephore = dispatch_semaphore_create(1);
dispatch_semaphore_wait(semephore, DISPATCH_TIME_FOREVER);
//重新赋值或者将semephore = nil都会造成崩溃,因为此时信号量还在使用中
semephore = dispatch_semaphore_create(0);
```

#### dispatch_semaphore_wait

```
long dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout){
    long value = dispatch_atomic_dec2o(dsema, dsema_value, acquire);
    if (fastpath(value >= 0)) {
        return 0;
    }
    return _dispatch_semaphore_wait_slow(dsema, timeout);
}
```

`dispatch_semaphore_wait`先将信号量的dsema值原子性减一，并将新值赋给value。如果value大于等于0就立即返回，否则调用`_dispatch_semaphore_wait_slow`函数，等待信号量唤醒或者timeout超时。`_dispatch_semaphore_wait_slow`函数定义如下：

```
static long _dispatch_semaphore_wait_slow(dispatch_semaphore_t dsema,
        dispatch_time_t timeout) {
    long orig;
    mach_timespec_t _timeout;
    kern_return_t kr;
again:
    orig = dsema->dsema_sent_ksignals;
    while (orig) {
        if (dispatch_atomic_cmpxchgvw2o(dsema, dsema_sent_ksignals, orig,
                orig - 1, &orig, relaxed)) {
            return 0;
        }
    }

    _dispatch_semaphore_create_port(&dsema->dsema_port);
    switch (timeout) {
    default:
    do {
            uint64_t nsec = _dispatch_timeout(timeout);
            _timeout.tv_sec = (typeof(_timeout.tv_sec))(nsec / NSEC_PER_SEC);
            _timeout.tv_nsec = (typeof(_timeout.tv_nsec))(nsec % NSEC_PER_SEC);
            kr = slowpath(semaphore_timedwait(dsema->dsema_port, _timeout));
        } while (kr == KERN_ABORTED);

        if (kr != KERN_OPERATION_TIMED_OUT) {
            DISPATCH_SEMAPHORE_VERIFY_KR(kr);
            break;
        }
    case DISPATCH_TIME_NOW:
        orig = dsema->dsema_value;
        while (orig < 0) {
            if (dispatch_atomic_cmpxchgvw2o(dsema, dsema_value, orig, orig + 1,
                    &orig, relaxed)) {
                return KERN_OPERATION_TIMED_OUT;
            }
        }
    case DISPATCH_TIME_FOREVER:
    do {
            kr = semaphore_wait(dsema->dsema_port);
        } while (kr == KERN_ABORTED);
        DISPATCH_SEMAPHORE_VERIFY_KR(kr);
        break;
    }
    goto again;
}
```

`_dispatch_semaphore_wait_slow`函数根据timeout的类型分成了三种情况处理：

1、DISPATCH_TIME_NOW：若`desma_value`小于0，对其加一并返回超时信号KERN_OPERATION_TIMED_OUT，原子性加一是为了抵消`dispatch_semaphore_wait`函数开始的减一操作。
2、DISPATCH_TIME_FOREVER：调用系统的`semaphore_wait`方法，直到收到`signal`调用。

```
kr = semaphore_wait(dsema->dsema_port);
```

3、default：调用内核方法`semaphore_timedwait`计时等待，直到有信号到来或者超时了。

```
kr = slowpath(semaphore_timedwait(dsema->dsema_port, _timeout));
```

`dispatch_semaphore_wait`的流程图可以用下图表示：

![img](https://images.xiaozhuanlan.com/photo/2018/4f46d6eff4332a95141b885c94bf6867.png)

#### dispatch_semaphore_signal

```
long dispatch_semaphore_signal(dispatch_semaphore_t dsema) {
    long value = dispatch_atomic_inc2o(dsema, dsema_value, release);
    if (fastpath(value > 0)) {
        return 0;
    }
    if (slowpath(value == LONG_MIN)) {
       //Warning：value值有误会造成崩溃，详见下篇dispatch_group的分析
        DISPATCH_CLIENT_CRASH("Unbalanced call to dispatch_semaphore_signal()");
    }
    return _dispatch_semaphore_signal_slow(dsema);
}
```

首先将dsema_value调用原子方法加1，如果大于零就立即返回0，否则进入`_dispatch_semaphore_signal_slow`方法，该函数会调用内核的`semaphore_signal`函数唤醒在`dispatch_semaphore_wait`中等待的线程。代码如下：

```
long _dispatch_semaphore_signal_slow(dispatch_semaphore_t dsema) {
    _dispatch_retain(dsema);
    (void)dispatch_atomic_inc2o(dsema, dsema_sent_ksignals, relaxed);
    _dispatch_semaphore_create_port(&dsema->dsema_port);
    kern_return_t kr = semaphore_signal(dsema->dsema_port);
    DISPATCH_SEMAPHORE_VERIFY_KR(kr);

    _dispatch_release(dsema);
    return 1;
}
```

`dispatch_semaphore_signal`的流程比较简单，可以用下图表示：

![img](https://images.xiaozhuanlan.com/photo/2018/f6e7b19fcd9b3819d48671c8de8b3224.png)

### 总结篇

Dispatch Semaphore信号量主要是`dispatch_semaphore_wait`和`dispatch_semaphore_signal`函数，`wait`会将信号量值减一，如果大于等于0就立即返回，否则等待信号量唤醒或者超时；`signal`会将信号量值加一，如果value大于0立即返回，否则唤醒某个等待中的线程。

需要注意的是信号量在销毁或重新创建的时候如果还在使用则会引起崩溃，详见上面的分析。