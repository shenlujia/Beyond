## 前言

说起Runloop，似乎也是一个被讲的烂大街的概念，很多大神都在自己的博客中阐述自己的理解，我自己也拜读了好多大神关于Runloop的杰作，深感敬佩，例如：

> - [Runloop知识树](https://segmentfault.com/a/1190000004938638)
> - [深入理解RunLoop](https://blog.ibireme.com/2015/05/18/runloop/)

然而我总感觉我对Runloop的理解似乎还是有些模糊，总觉得在我的理解中，Runloop的神秘面纱没有完全被揭开，毕竟好多东西都是听别人这么说的。

Runloop就是事件驱动的一个大循环，事件驱动在很多语言中都有实现，伪代码如下：

```
int main(int argc, char * argv[]) {
     //程序一直运行状态
     while (AppIsRunning) {
          //睡眠状态，等待唤醒事件
          id whoWakesMe = SleepForWakingUp();
          //得到唤醒事件
          id event = GetEvent(whoWakesMe);
          //开始处理事件
          HandleEvent(event);
     }
     return 0;
}
```



有时候会想，如果凭着自己的学习和理解去实现一个简（山）易（寨）版的Runloop，自己又该怎么做呢？

> - 本着对Runloop是个圈的理解，首先应该写个死循环；
> - 同时Runloop还应该有一个自己的事件队列，存放事件，每当有事件发生时，将事件加入队列，而Runloop每次循环中，取出一个事件，进行处理；
> - Runloop在队列为空的情况下，还得让所在的线程学会睡眠，当有事件发生的时候，还得将线程唤醒，在我有限的知识仓库中，似乎也只有IO多路复用能解决这个问题
> - Runloop得区分Timer、Observer、Source等
> - …

收集资料的过程中，无意中发现了一位大神写的[LightWeightRunLoop-A-Reactor-Style-NSRunLoop](https://github.com/wuyunfeng/LightWeightRunLoop-A-Reactor-Style-NSRunLoop)，真是踏破铁鞋无觅处，仔细拜读之后，发现和自己的构思还整体比较吻合，这里借花献佛，借源码分析一下如何去实现一个轻量级的Runloop，这里首先感谢一下作者 **wuyunfeng**。

## 整体框架

`LightWeightRunLoop`主要实现了和Runloop相关的一些API，例如：PerformSelector、Timer、URLConnection、LWStream和LWPort等，但是本文的目的不是为了怎么去使用这些API，而是去理解这些API的内部实现，从而加深对Runloop的理解。

借用下作者的图
[![img](http://lingyuncxb.com/2018/06/09/%E5%A6%82%E4%BD%95%E5%AE%9E%E7%8E%B0%E4%B8%80%E4%B8%AA%E7%AE%80%E5%8D%95%E7%9A%84RunLoop%EF%BC%881%EF%BC%89/01.jpg)](http://lingyuncxb.com/2018/06/09/如何实现一个简单的RunLoop（1）/01.jpg)

## LWRunloop

### 线程如果获取LWRunLoop对象

每一个线程（除了主线程），都可以拥有一个`LWRunLoop`对象，可以通过以下方式获取：在运行的线程中调用`[LWRunLoop currentLWRunLoop]`

```
NSThread *_lwRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(lightWeightRunloopThreadEntryPoint:) object:nil];

- (void)lightWeightRunloopThreadEntryPoint:(id)data
{
    @autoreleasepool {
        [[LWRunLoop currentLWRunLoop] run];
    }
}
```



### currentLWRunLoop内部实现

看一下`currentLWRunLoop`的内部实现

```
+ (instancetype)currentLWRunLoop
{
    int result = pthread_once(& mTLSKeyOnceToken, initTLSKey);
    LWRunLoop *instance = (__bridge LWRunLoop *)pthread_getspecific(mTLSKey);
    if (instance == nil) {
        instance = [[[self class] alloc] init];
        [[NSThread currentThread] setLooper:instance];
        pthread_setspecific(mTLSKey, (__bridge const void *)(instance));
    }
    return instance;
}
```



通过源码可以发现，线程的LWRunloop对象被存储为线程私有数据（TSD)，通过`pthread_setspecific`和`pthread_getspecific`进行存取。继续看下LWRunloop的初始化函数，只是简单地初始化了一个类型为`LWMessageQueue`的消息队列。

```
- (instancetype)init
{
    if (self = [super init]) {
        _queue = [LWMessageQueue defaultInstance];
    }
    return self;
}
```



### LWRunloop如何运行

再看下`LWRunloop`的run函数的实现过程

```
- (void)run
{
    [self runMode:LWDefaultRunLoop];
}

#pragma mark run this loop at specific mode
- (void)runMode:(NSString *)mode
{
    _currentRunLoopMode = mode;
    _queue.queueRunMode = _currentRunLoopMode;
    while (YES) 
    {
        LWMessage *msg = [_queue next:_queue.queueRunMode];
        [msg performSelectorForTarget];
        [self necessaryInvocationForThisLoop:msg];
    }
}
```



实际上思路也很简单：每次循环中，都从消息队列中取出一个消息，然后执行对应的事件。

```
- (void)performSelectorForTarget
{
    if (_mTarget == nil) { return; }
    if ([_mTarget respondsToSelector:_mSelector]) {
        [_mTarget performSelector:_mSelector withObject:_mArgument];
    } 
}
```



```
// 周期性的LWTime要特殊处理
- (void)necessaryInvocationForThisLoop:(LWMessage *)msg
{
    if ([msg.data isKindOfClass:[LWTimer class]]) { 
        LWTimer *timer = msg.data;
        if (timer.repeat) {
            msg.when = timer.timeInterval; // must
            [self postMessage:msg];
        }
    }
}
```

## LWMessageQueue

### LWMessageQueue如何获取

```
+ (instancetype)defaultInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_key_create(&mThreadOneInstanceKey, threadDestructor);
    });
    
    LWMessageQueue *queue = (__bridge LWMessageQueue *)(pthread_getspecific(mThreadOneInstanceKey));
    if (queue == nil) {
        queue = [[LWMessageQueue alloc] init];
        pthread_setspecific(mThreadOneInstanceKey, (__bridge const void *)(queue));
    }
    return queue;
}
```

显然，和`LWRunloop`的获取是一样的套路，不再赘言。

### LWMessageQueue的初始化工作

```
- (instancetype)init
{
    if (self = [super init]) 
    {
        _nativeRunLoop = [[LWNativeRunLoop alloc] init];
        _allowStop = NO;
        [self addObserver:self forKeyPath:@"queueRunMode" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:"modechange"];
    }
    return self;
}
```

里面做了两件比较重要的事情

> - 定义了一个`LWNativeRunLoop`，这个和内核相关，也就是前文提到的IO多路复用.`LWNativeRunLoop`是`LWRunloop`的核心，也是`LWRunloop`之所以可以跑圈的基石(看西部世界看多了)。
> - 观察了RunMode的切换，一旦切换，便调用`LWNativeRunLoop`唤醒内核。

```
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"queueRunMode"] && (strcmp("modechange", context) == 0 )) {
        _messages = _preMessages;//runtime change
        [_nativeRunLoop nativeWakeRunLoop];// should wake kernel
    }
}
```

### LWMessageQueue的消息入队

```
- (BOOL)enqueueMessage:(LWMessage *)msg when:(NSInteger)when
{
    @synchronized(self) 
    {
        msg.when = when;
        LWMessage *p = _messages;
        BOOL needInterruptBolckingState = NO;
        
        if (p == nil /*|| when == 0 */|| when < p.when) {
            msg.next = p;
            _messages = msg;
            needInterruptBolckingState = _isCurrentLoopBlock;
        } else {
            LWMessage *prev = nil;
            while (p != nil && p.when <= when) {
                prev = p;
                p = p.next;
            }
            msg.next = prev.next;
            prev.next = msg;
            needInterruptBolckingState = false;
        }
        if (needInterruptBolckingState) {
            [_nativeRunLoop nativeWakeRunLoop];
        }
    }
    return YES;
}
```

消息入队方法有两个参数，一个时消息本身，另一个是消息触发的时间。可以看到，消息的存储结构是通过链表来实现的。首先寻找链表头，
（1）如果链表头为空，或者当前入队的消息触发时间比队首消息的时间要早，则把当前消息设置为链表头；
（2）否则，沿着链表往后寻找第一个比当前消息触发时间晚的消息，然后将入队消息插入到该消息之前；
最后如果当前线程出于阻塞状态，则需要调用nativeWakeRunLoop进行唤醒。

### LWMessageQueue的消息出队

```
- (LWMessage *)next:(NSString *)mode
{
    NSInteger nextWakeTimeoutMillis = 0;
    _queueRunMode = mode;
    while (YES)
    {
        [_nativeRunLoop nativeRunLoopFor:nextWakeTimeoutMillis];
        @synchronized(self)
        {
            NSInteger now = [LWSystemClock uptimeMillions];
            LWMessage *msg = _messages;
            //find the head message, assign it to _preMessages for preposition
            if (msg != nil)
            {
                if (![self isMsgModesHit:msg.modes])
                {
                    // can not discard, but may use in mode's changing
                    if (!_preMessages) {
                        _preMessages = msg;
                        notHitCurrentMsg = _preMessages;
                    } else {
                        notHitCurrentMsg.next = msg;
                        notHitCurrentMsg = msg;
                    }
                    _messages = msg.next;
                    continue;// enter into next loop
                }
                else
                {
                    if (now < msg.when) {
                        nextWakeTimeoutMillis = msg.when - now;
                    }
                    else
                    {
                        _isCurrentLoopBlock = NO;
                        _messages = msg.next;
                        msg.next = nil;
                        return msg;
                    }
                }
            } else {
                nextWakeTimeoutMillis = -1;
            }

            _isCurrentLoopBlock = YES;
        }
    }
}
```

首先从nativeRunLoopFor获取到需要处理的消息_messages，
（1）如果消息为空，将当前线程设置为阻塞状态；
（2）如果消息命中了当前线程的RunMode，则检查其触发时间：如果触发时间小于等于当前时间，则需要将该消息从消息队列中取出并返回，否则简单地设置`nextWakeTimeoutMillis`唤醒时间即可；
（3）如果消息并没有命中当前线程的RunMode，则需要将其保存到一个没有命中的消息队列中，以防止RunMode切换的时候会用到。

## LWNativeRunLoop（核心）

上述内容看完后，总感觉还是不痛不痒，真正核心的东西还是没有讲到，如前所述，`LWNativeRunLoop`是基石，是核心重点，那么我们来分析下`LWNativeRunLoop`到底为什么这么重要。

> - 注：看这部分代码的时候需要预先准备下 **IO多路复用** 的知识

### LWNativeRunLoop初始化工作

```
- (instancetype)init
{
    if (self = [super init]) {
        [self prepareLWRunLoop];
    }
    return self;
}
- (void)prepareLWRunLoop
{
    int fds[2];
    
    // 利用pipe创建一个管道
    int result = pipe(fds);
    
    // fds参数返回两个文件描述符,fds[0]指向管道的读端,fds[1]指向管道的写端
    _mReadPipeFd = fds[0];
    _mWritePipeFd = fds[1];
    
    // fcntl系统调用可以用来对已打开的文件描述符进行各种控制操作以改变已打开文件的的各种属性
    // 这里的一堆代码主要是为了讲上述两个文件描述符的I/O操作设置为非阻塞模式，主要是出于性能考虑
    int rflags;
    if ((rflags = fcntl(_mReadPipeFd, F_GETFL, 0)) < 0) {
        NSLog(@"Failure in fcntl F_GETFL");
    };
    rflags |= O_NONBLOCK;
    result = fcntl(_mReadPipeFd, F_SETFL, rflags);
    
    int wflags;
    if ((wflags = fcntl(_mWritePipeFd, F_GETFL, 0)) < 0) {
        NSLog(@"Failure in fcntl F_GETFL");
    };
    wflags |= O_NONBLOCK;
    result = fcntl(_mWritePipeFd, F_SETFL, wflags);

    // 定义一个kqueue
    _kq = kqueue();

    // 设置要监视的事件列表
    struct kevent changes[1];
    EV_SET(changes, _mReadPipeFd, EVFILT_READ, EV_ADD, 0, 0, NULL);

    // 进行kevent函数调用，如果changes列表里有任何就绪的fd，则把该事件对应的结构体放进events列表里面，但是这里不太关心events，所以设置为NULL
    int ret = kevent(_kq, changes, 1, NULL, 0, NULL);
    
    // 其它等
    _fds = [[NSMutableArray alloc] init];
    _requests = [[NSMutableDictionary alloc] init];
    _portClients = [[NSMutableDictionary alloc] init];
}
```

可以发现，kqueue体系有三样东西：struct kevent结构体，EV_SET宏以及kevent函数。

> - struct kevent 结构体内容如下：

```
struct kevent {
    uintptr_t       ident;          /* identifier for this event，比如该事件关联的文件描述符 */
    int16_t         filter;         /* filter for event，可以指定监听类型，如EVFILT_READ，EVFILT_WRITE，EVFILT_TIMER等 */
    uint16_t        flags;          /* general flags ，可以指定事件操作类型，比如EV_ADD，EV_ENABLE， EV_DELETE等 */
    uint32_t        fflags;         /* filter-specific flags */
    intptr_t        data;           /* filter-specific data */
    void            *udata;         /* opaque user data identifier，可以携带的任意数据 */
};
```

> - EV_SET 是用于初始化kevent结构的便利宏，其签名为:

```
EV_SET(&kev, ident, filter, flags, fflags, data, udata);
```

它和kevent结构体完全对应，第一个参数就是你要初始化的那个kevent结构。

> - kevent 是真正进行IO复用的函数，其签名为：

```
int kevent(int kq, 
    const struct kevent *changelist, // 监视列表
    int nchanges, // 长度
    struct kevent *eventlist, // kevent函数用于返回已经就绪的事件列表
    int nevents, // 长度
    const struct timespec *timeout); // 超时限制
```

总的来说，`prepareLWRunLoop`方法主要就是对`_mReadPipeFd`文件描述符进行了监视。

### 神奇的nativeRunLoopFor

前面代码中多次出现了关键的`nativeRunLoopFor`，我们来重点分析下：

```
- (void)nativeRunLoopFor:(NSInteger)timeoutMillis
{
    struct kevent events[MAX_EVENT_COUNT];

    // 设定超时时间
    struct timespec *waitTime = NULL;
    if (timeoutMillis == -1) {
        waitTime = NULL;
    } else {
        waitTime = (struct timespec *)malloc(sizeof(struct timespec));
        waitTime->tv_sec = timeoutMillis / 1000;
        waitTime->tv_nsec = timeoutMillis % 1000 * 1000 * 1000;
    }

    // 如果之前监视的changes列表里有任何就绪的fd，则把该事件对应的结构体放进events列表里面
    // 在fd就绪之前或者超时时间未结束之前，kevent将使得该线程阻塞
    int ret = kevent(_kq, NULL, 0, events, MAX_EVENT_COUNT, waitTime);
    
    free(waitTime);
    waitTime = NULL; // avoid wild pointer

    // 依次循环处理就绪
    for (int i = 0; i < ret; i++) {
        int fd = (int)events[i].ident;
        int event = events[i].filter;
        if (fd == _mReadPipeFd) { // for pipe read fd
            if (event & EVFILT_READ) {
                // 如果是之前监视的mReadWakeFd描述符，则进行nativePollRunLoop调用
                [self nativePollRunLoop];
            } else {
                continue;
            }
        } else if (_leader == fd){//for LWPort leader fd
            if (event & EVFILT_READ) {
                [self handleAccept:fd];
            }
        } else if (_follower == fd) {// leader -> follower
            if (![self handleLeaderToFollower:fd]) {
                continue;
            }
        } else { // follower -> leader read for LWPort follower fd, then notify leader
            if (![self handleFollowerToLeader:event fd:fd]) {
                continue;
            }
        }
    }
}
```



这里我们先只关心`_mReadPipeFd`文件描述符，一旦契合，则进行`nativePollRunLoop`方法调用：

```
- (void)nativePollRunLoop
{
    char buffer[16];
    ssize_t nRead;
    do {
        // 从管道的读端_mReadPipeFd读取数据
        nRead = read(_mReadPipeFd, buffer, sizeof(buffer));
    } while ((nRead == -1 && errno == EINTR) || nRead == sizeof(buffer));
}
```



`nativePollRunLoop`方法中读出来的数据buffer仅仅是读出来，然后什么都没做就被扔掉了，有人可能要问，为什么要多此一举呢？

我们先来想想：如果管道的一端有数据可读，必然在管道的另一端有数据写入：

```
- (void)nativeWakeRunLoop
{
    ssize_t nWrite;
    do {
        nWrite = write(_mWritePipeFd, "w", 1);
    } while (nWrite == -1 && errno == EINTR);
}
```



看到了吗？这个方法名起的是多么地直抒胸臆！
**我们知道，在被监视的文件描述符就绪之前或者超时时间未结束之前，kevent将一直使得该线程阻塞（休眠），不再占用CPU的时间。所以管道里面发送和接受了什么数据，我们根本不需要关心！我们要关心的是它们这么一发一收，直接造成了Runloop被唤醒的结果，从而可以继续进行消息的处理。有了kevent的阻塞休眠，有了这里管道的唤醒（也可以有其他的唤醒方式），一个线程的Runloop就形成了。**

## NSObject

看看这里的`postSelector`，来想象下`performSelector`的实现吧

```
- (void)postSelector:(SEL)aSelector onThread:(NSThread *)thread
          withObject:(id)arg afterDelay:(NSInteger)delay
{
    __weak __typeof(self) weakSelf = self;
    LWRunLoop *loop = [thread looper];
    [loop postTarget:weakSelf withAction:aSelector withObject:arg afterDelay:delay];
}
```



```
- (void)postTarget:(id)target withAction:(SEL)aSel withObject:(id)arg afterDelay:(NSInteger)delayMillis
{
    NSInteger when = [LWSystemClock uptimeMillions] + delayMillis;
    LWMessage *message = [[LWMessage alloc] initWithTarget:target aSel:aSel withArgument:arg at:when];
    // 将target和selector直接封装为LWMessage，入队
    [_queue enqueueMessage:message when:when];
}
```

## LWTimer

一个套路，自己体会吧

```
+ (LWTimer *)scheduledLWTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    if (interval <= 0) {
        interval = 100;
    }
    LWTimer *instance = [[[self class] alloc] init];
    [instance setTimeInterval:interval];
    [instance setValid:YES];
    [instance setUserInfo:userInfo];
    [instance setRepeat:yesOrNo];
    LWMessage *msg = [[LWMessage alloc] initWithTarget:aTarget aSel:aSelector withArgument:instance at:interval];
    msg.data = instance;
    [instance setMessage:msg];
    LWRunLoop *runloop = [[NSThread currentThread] looper];
    [runloop postMessage:msg];
    return instance;
}
```



```
- (void)postMessage:(LWMessage *)msg
{
    NSInteger when = msg.when + [LWSystemClock uptimeMillions];
    [_queue enqueueMessage:msg when:when];
}
```