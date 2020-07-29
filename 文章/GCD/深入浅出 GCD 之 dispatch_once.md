### 概述

`dispatch_once`能保证任务只会被执行一次，即使同时多线程调用也是线程安全的。常用于创建单例、
swizzeld method等功能。它的功能比较简单，接下来看下使用方法和具体的原理。

### 使用篇

```
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    //创建单例、method swizzled或其他任务
});
```

### 原理篇

```
//调用dispatch_once_f来处理
void dispatch_once(dispatch_once_t *val, dispatch_block_t block) {
    dispatch_once_f(val, block, _dispatch_Block_invoke(block));
}
```

`dispatch_once`封装调用了`dispatch_once_f`函数，其中通过_dispatch_Block_invoke来执行block任务，它的定义如下：

```
//invoke是指触发block的具体实现，感兴趣的可以看一下Block_layout的结构体
#define _dispatch_Block_invoke(bb) \
        ((dispatch_function_t)((struct Block_layout *)bb)->invoke)
```

接着看一下具体的实现函数`dispatch_once_f`：

```
void dispatch_once_f(dispatch_once_t *val, void *ctxt, dispatch_function_t func) {
    struct _dispatch_once_waiter_s * volatile *vval =
            (struct _dispatch_once_waiter_s**)val;
    struct _dispatch_once_waiter_s dow = { NULL, 0 };
    struct _dispatch_once_waiter_s *tail, *tmp;
    _dispatch_thread_semaphore_t sema;

    if (dispatch_atomic_cmpxchg(vval, NULL, &dow, acquire)) {
        _dispatch_client_callout(ctxt, func);

        dispatch_atomic_maximally_synchronizing_barrier();
        // above assumed to contain release barrier
        tmp = dispatch_atomic_xchg(vval, DISPATCH_ONCE_DONE, relaxed);
        tail = &dow;
        while (tail != tmp) {
            while (!tmp->dow_next) {
                dispatch_hardware_pause();
            }
            sema = tmp->dow_sema;
            tmp = (struct _dispatch_once_waiter_s*)tmp->dow_next;
            _dispatch_thread_semaphore_signal(sema);
        }
    } else {
        dow.dow_sema = _dispatch_get_thread_semaphore();
        tmp = *vval;
        for (;;) {
            if (tmp == DISPATCH_ONCE_DONE) {
                break;
            }
            if (dispatch_atomic_cmpxchgvw(vval, tmp, &dow, &tmp, release)) {
                dow.dow_next = tmp;
                _dispatch_thread_semaphore_wait(dow.dow_sema);
                break;
            }
        }
        _dispatch_put_thread_semaphore(dow.dow_sema);
    }
}
```

由上面的代码可知`dispatch_once`的流程图大致如下：

![img](https://images.xiaozhuanlan.com/photo/2018/0623f6463e88dba8a9d3cd257224aa6c.png)

首先看一下`dispatch_once`中用的的原子性操作`dispatch_atomic_cmpxchg(vval, NULL, &dow, acquire)`，它的宏定义展开之后会将$dow赋值给vval，如果vval的初始值为NULL，返回YES,否则返回NO。

接着结合上面的流程图来看下`dispatch_once`的代码逻辑：

首次调用`dispatch_once`时，因为外部传入的dispatch_once_t变量值为nil，故vval会为NULL，故if判断成立。然后调用`_dispatch_client_callout`执行block，然后在block执行完成之后将vval的值更新成`DISPATCH_ONCE_DONE`表示任务已完成。最后遍历链表的节点并调用`_dispatch_thread_semaphore_signal`来唤醒等待中的信号量；

当其他线程同时也调用`dispatch_once`时，因为if判断是原子性操作，故只有一个线程进入到if分支中，其他线程会进入else分支。在else分支中会判断block是否已完成，如果已完成则跳出循环；否则就是更新链表并调用`_dispatch_thread_semaphore_wait`阻塞线程，等待if分支中的block完成后再唤醒当前等待的线程。

### 总结篇

`dispatch_once`用原子性操作block执行完成标记位，同时用信号量确保只有一个线程执行block，等block执行完再唤醒所有等待中的线程。

`dispatch_once`常被用于创建单例、swizzeld method等功能。