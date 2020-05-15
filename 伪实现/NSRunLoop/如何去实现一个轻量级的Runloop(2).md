## 前言

接着上篇文章[如何实现一个简单的RunLoop（1）](http://lingyuncxb.com/2018/06/09/如何实现一个简单的RunLoop（1）/)，我们来继续分析。

## LWURLConnection

LWURLConnection也是这个框架中比较有意思的一部分，同时也比较复杂，相信看完之后对AFN的理解会有很大的帮助。直接上代码：

```
- (void)performURLConnectionOnRunLoopThread
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.11:8080/v1/list/post"]];
    request.HTTPMethod = @"POST";
    NSString *content = @"name=john&address=beijing&mobile=140005";
    request.HTTPBody = [content dataUsingEncoding:NSUTF8StringEncoding];
    LWURLConnection *conn = [[LWURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [conn scheduleInRunLoop:_lwRunLoopThread.looper];
    [conn start];
}
```



### LWURLConnection的初始化

```
- (instancetype _Nonnull)initWithRequest:(NSMutableURLRequest * _Nullable)request
                                delegate:(nullable id)delegate
                        startImmediately:(BOOL)startImmediately
{
    if (self = [super init]) {
        _internal = [[LWConnectionInternal alloc] initWithRequest:request];
        _internal.delegate = self;
        _startImmediately = startImmediately;
        _delegate = delegate;
    }
    return self;
}

- (void)start
{
    [_internal start];
}
```

可以看到`LWURLConnection`内部持有一个`LWConnectionInternal`对象，并把`LWConnectionInternal`的代理设置为自己。

### LWConnectionInternal初始化

```
- (instancetype)init
{
    if (self = [super init]) {
        _helper = new LWConnHelper();
    }
    return self;
}
- (void)start
{
    // 重启一个子线程
    [NSThread detachNewThreadSelector:@selector(startInternal) toTarget:self withObject:nil];
}

- (void)startInternal
{
    // 设置上下文
    LWConnHelperContext context = {(__bridge void *)self,TimeOutCallBackRoutine, ReceiveCallBackRoutine, FinshCallBackRoutine, FailureCallBackRoutine};
    _helper->setLWConnHelperContext(&context);

    // 建立链接
    if ([self establishConnection]) 
    {
        // 设置请求头参数
        [self prepareHttpRequest];
        if ((strcasecmp("post", [request.HTTPMethod UTF8String]) == 0) && request.HTTPBody.length > 0) {
            // 设置请求体
            [self prepareHTTPBody];
        }
        if (request.timeoutInterval <= 0) {
            request.timeoutInterval = 60;
        }
        _helper->createHttpRequest(request.timeoutInterval);
    } 
    else
    {
        _helper->closeConn();
        [self failure];
    }
}
```

可以看到，start方法时重启了一个子线程执行`startInternal`方法，在该方法里面进行了链接、请求参数准备，以及建立HttpRequest请求，接下来逐步拆解。

### 建立Socket链接

```
- (BOOL)establishConnection
{
    // 获取IP和端口
    NSURL *targetURL = request.URL;
    NSString *host = targetURL.host;
    NSInteger port = [targetURL.port intValue];
    char *ip = _helper->resolveHostName([host UTF8String]);
    if (ip == NULL) {
        NSLog(@"resolve host name failure");
        return NO;
    }

    // 调用LWConnHelper建立链接
    return _helper->establishSocket(ip, (int)port);
}
bool LWConnHelper::establishSocket(const char *ip, const int port)
{
    // IP和端口转换
    struct sockaddr_in serverAddr;
    serverAddr.sin_len = sizeof(struct sockaddr_in);
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(port);
    if (inet_aton(ip, &serverAddr.sin_addr) == 0) {
        printf("address error\n");
        return false;
    }
    inet_aton(ip, &serverAddr.sin_addr);
    
    // 建立套接字，用来打开一个网络连接，如果成功则返回一个网络文件描述符
    this->mSockFd = socket(AF_INET, SOCK_STREAM, 0);

    // 设置为套接字描述符为非阻塞式IO
    int flag = fcntl(this->mSockFd, F_GETFL, NULL);
    flag |= O_NONBLOCK;
    fcntl(this->mSockFd, F_SETFL, flag);
    
    // 通过connect函数与服务端连接，进行通信
    int ret = connect(this->mSockFd, (struct sockaddr *)&serverAddr, sizeof(struct sockaddr));

    if (ret < 0) {
        return false;
    }

    return true;
}
```

### 准备请求头和请求体

负责一些请求参数的设置

```
- (void)prepareHttpRequest
{
    NSURL *targetURL = request.URL;
    NSString *httpMethod = request.HTTPMethod;
    NSString *path = targetURL.path;
    NSString *host = targetURL.host;
    
    NSMutableString *httpRequestLineAndHeader = [[NSMutableString alloc] init];
    
    NSString *requestLine = [NSString stringWithFormat:@"%@ %@ HTTP/1.1 \r\n",httpMethod, path];
    NSString *hostHeader = [NSString stringWithFormat:@"HOST: %@ \r\n", host];
    [httpRequestLineAndHeader appendString:requestLine];
    [httpRequestLineAndHeader appendString:hostHeader];
    
    NSMutableDictionary *allHTTPHeaderFields = [[NSMutableDictionary alloc] init];
    [allHTTPHeaderFields setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    [allHTTPHeaderFields setValue:@(request.HTTPBody.length) forKey:@"Content-Length"];
    [allHTTPHeaderFields setValue:@"wuyunfeng@LWURLConnection" forKey:@"Accept"];
    [allHTTPHeaderFields setValue:@"gzip, deflate" forKey:@"Accept-Encoding"];
    [allHTTPHeaderFields setValue:@"utf-8" forKey:@"Accept-Charset"];
    [allHTTPHeaderFields setValue:@"LWRunLoopAgent" forKey:@"User-Agent"];
    [allHTTPHeaderFields setValue:@"no-cache" forKey:@"Cache-Control"];
    [allHTTPHeaderFields setValue:@"close" forKey:@"Connection"];
    [allHTTPHeaderFields addEntriesFromDictionary:request.allHTTPHeaderFields];
    NSString *httpHeaderAndValues = LWHeaderStringFromHTTPHeaderFieldsDictironary(allHTTPHeaderFields);
    [httpRequestLineAndHeader appendString:httpHeaderAndValues];

    // 把请求行和请求头发送出去
    _helper->sendMsg([httpRequestLineAndHeader UTF8String], (int)httpRequestLineAndHeader.length);
}
```



```
- (void)prepareHTTPBody
{
    NSData *data = request.HTTPBody;
    _helper->sendMsg((const char *)([data bytes]), (int)[data length]);
}
void LWConnHelper::sendMsg(const char *content, int length)
{
    if (content == NULL) {
        return;
    }
    ssize_t mWrite;
    do {
        mWrite = write(this->mSockFd, content, length);
    } while (mWrite == -1 && errno == EINTR);
}
```

### 建立Http请求

```
void LWConnHelper::createHttpRequest(int timeoutMills)
{
    fd_set readfds;

    // 时间戳转换
    struct timeval timeout;
    timeout.tv_sec = timeoutMills / 1000;
    timeout.tv_usec = timeoutMills % 1000 * 1000;

    // 设置readset描述符
    int maxfd = -1;
    FD_ZERO(&readfds);
    maxfd = this->mSockFd + 1;

    int ret;
    do 
    {
        FD_SET(this->mSockFd, &readfds);

        // 检测网络是否回应消息
        ret = select(maxfd, &readfds, NULL, NULL, &timeout);
        
        // 如果超时
        if (0 == ret) {
            // 超时回调
            if (this->mContext->LWConnectionTimeOutCallBack != NULL) {
                this->mContext->LWConnectionTimeOutCallBack(this->mContext->info);
            }
        }

        // 如果this->mSockFd是否在返回的集合readfds中
        if (FD_ISSET(this->mSockFd, &readfds)) {
            char buffer[4 * 1024];
            ssize_t nRead;
            do {
                // 成功返回读取的字节数,出错返回-1, 并设置errno,如果在调read之前已到达文件末尾，则这次read返回0
                nRead = read(this->mSockFd, buffer, sizeof(buffer));

                // 每读到一次数据都要进行回调
                if (this->mContext->LWConnectionReceiveCallBack != NULL) {
                    this->mContext->LWConnectionReceiveCallBack(this->mContext->info, buffer, (int)nRead);
                }
            } while ((nRead == -1 && errno == EINTR) || nRead == sizeof(buffer));
            
            // 成功回调
            if (this->mContext->LWConnectionFinishCallBack) {
                this->mContext->LWConnectionFinishCallBack(this->mContext->info);
            }
        }
    } while (-1 == ret && errno == EINTR);
    
    // 如果失败
    if (-1 == ret) 
    {
        // 失败回调
        if (this->mContext->LWConnectionFailureCallBack != NULL) {
            this->mContext->LWConnectionFailureCallBack(this->mContext->info, -1);
        }
    }
    // 关闭连接
    closeConn();
}
```

实际上这个名字`createHttpRequest`稍微有点欠妥，因为在这个方法里面，已经是在通过IO多路复用技术select等待网络数据回来，请求实际上是在`prepareHttpRequest`的时候已经发出去了。

### 网络回调流程

```
@class LWConnectionInternal;
@protocol LWConnectionInternalDelegate <NSObject>

- (void)internal_connection:(LWConnectionInternal * _Nonnull)connection didReceiveData:(NSData * _Nullable)data;

- (void)internal_connection:(LWConnectionInternal * _Nonnull)connection didFailWithError:(NSError * _Nullable)error;

- (void)internal_connectionDidFinishLoading:(LWConnectionInternal * _Nonnull)connection;

@end
```

`LWConnectionInternal`内部有个`LWConnectionInternalDelegate`，会把网络结果代理给`LWURLConnection`。

```
- (void)internal_connection:(LWConnectionInternal * _Nonnull)connection didReceiveData:(NSData * _Nullable)data
{
    //The new object must have its selector set with setSelector: and its arguments set with setArgument:atIndex: before it can be invoked. Do not use the alloc/init approach to create NSInvocation objects.
    if ([self.delegate respondsToSelector:@selector(lw_connection:didReceiveData:)]) {
        id target = self.delegate;
        NSMethodSignature *sig = [target methodSignatureForSelector:@selector(lw_connection:didReceiveData:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.target = self.delegate;
        invocation.selector = @selector(lw_connection:didReceiveData:);
        id argument = self;
        [invocation setArgument:&argument atIndex:2];
        [invocation setArgument:&data atIndex:3];
        [invocation retainArguments];
        LWMessage *msg = [[LWMessage alloc] initWithTarget:invocation aSel:@selector(invoke) withArgument:nil at:0];
        [_runloop postMessage:msg];
    }
}

- (void)internal_connection:(LWConnectionInternal * _Nonnull)connection didFailWithError:(NSError * _Nullable)error
{
    if ([self.delegate respondsToSelector:@selector(lw_connection:didFailWithError:)]) {
        id target = self.delegate;
        NSMethodSignature *sig = [target methodSignatureForSelector:@selector(lw_connection:didFailWithError:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.target = self.delegate;
        invocation.selector = @selector(lw_connection:didFailWithError:);
        id argument = self;
        [invocation setArgument:&argument atIndex:2];
        [invocation setArgument:&error atIndex:3];
        [invocation retainArguments];
        LWMessage *msg = [[LWMessage alloc] initWithTarget:invocation aSel:@selector(invoke) withArgument:nil at:0];
        [_runloop postMessage:msg];
    }
}

- (void)internal_connectionDidFinishLoading:(LWConnectionInternal * _Nonnull)connection
{
    if ([self.delegate respondsToSelector:@selector(lw_connectionDidFinishLoading:)]) {
        id target = self.delegate;
        NSMethodSignature *sig = [target methodSignatureForSelector:@selector(lw_connectionDidFinishLoading:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        invocation.target = self.delegate;
        invocation.selector = @selector(lw_connectionDidFinishLoading:);
        id argument = self;
        [invocation setArgument:&argument atIndex:2];
        [invocation retainArguments];
        LWMessage *msg = [[LWMessage alloc] initWithTarget:invocation aSel:@selector(invoke) withArgument:nil at:0];
        [_runloop postMessage:msg];
    }
}
```



以`internal_connectionDidFinishLoading`为例，可以看到它将`LWURLConnection`的代理方法（就是最外面的业务层）包装为`LWMessage`，调用我们熟悉的`[_runloop postMessage:msg]`，进入Runloop的消息队列。

可以看到，`LWURLConnection`本身的网络请求是基于Socket和select技术来实现的，然后其网络结果回来之后，就又再次和Runloop打上了交道：将代理方法封装为消息，进入Runloop的消息队列，接下来怎么处理就是Runloop本身的事情了。

## LWPort

Mach中最基本的概念是消息，消息在两个端口之间进行传递，从设计上看，任何两个端口之间都可以传递消息——不论是同一台机器上的端口还是远程主机上的端口（本文中讨论的源码是同一台机器上的端口）。消息从一个端口发送到另一个端口，像一个端口发送消息实际上是将消息放在一个队列中，直到消息能被接受者处理。
例如CFRunloop里面有两种CFRunLoopSource:
source0：处理如UIEvent，CFSocket这样的事件
source1：Mach port驱动，CFMachport，CFMessagePort
从字面上看，这里的source1和端口就脱不了干系。

### Leader

首先创建一个线程，获取对应runloop，定义一个`LWSocketPort`对象_leaderPort，设置其端口为8082，并且把`_leaderPort`添加到runloop中。

```
@autoreleasepool
{
    LWRunLoop *looper = [LWRunLoop currentLWRunLoop];
    _leaderPort = [[LWSocketPort alloc] initWithTCPPort:8082];
    _leaderPort.delegate = self;
    [looper addPort:_leaderPort forMode:LWDefaultRunLoop];
    [looper runMode:LWDefaultRunLoop];
}
```



```
- (void)addPort:(LWPort *)aPort forMode:(NSString *)mode
{
    if (_allPorts) {
        _allPorts = [[NSMutableArray alloc] init];
    }
    [_allPorts addObject:aPort];
    if ([aPort isKindOfClass:[LWSocketPort class]]) {
        LWSocketPort *socketTypePort = (LWSocketPort *)aPort;
        int fd = socketTypePort.socket;
        LWSocketPortRoleType roleType = LWSocketPortRoleTypeLeader;
        LWPortContext context = socketTypePort.context;
        [_queue.nativeRunLoop addFd:fd type:LWNativeRunLoopFdSocketServerType filter:LWNativeRunLoopEventFilterRead callback:context.LWPortReceiveDataCallBack data:context.info];
    }
}
```

### Follow

同时，利用`detachNewThreadSelector`重新创建了一个线程，并定义了一个`WorkerClass`对象。

```
_worker = [[WorkerClass alloc] init];
[NSThread detachNewThreadSelector:@selector(launchThreadWithPort:) toTarget:_worker withObject:_leaderPort];

- (void)launchThreadWithPort:(LWPort *)port
{
    @autoreleasepool {
        [self prepare:port];
    }
}

- (void)prepare:(LWPort *)port
{
    _workPortRunLoopThread = [NSThread currentThread];
    [NSThread currentThread].name = @"workerPortLoopThread";
    _distantPort = (LWSocketPort *)port;
    _localPort = [[LWSocketPort alloc] initWithTCPPort:8082];
    _localPort.delegate = self;
    [_localPort setType:LWSocketPortRoleTypeFollower];
    LWRunLoop *_currentRunLoop = [LWRunLoop currentLWRunLoop];
    [_currentRunLoop addPort:_localPort forMode:LWDefaultRunLoop];
    [_currentRunLoop runMode:LWDefaultRunLoop];
}

- (void)addPort:(LWPort *)aPort forMode:(NSString *)mode
{
    if (_allPorts) {
        _allPorts = [[NSMutableArray alloc] init];
    }
    [_allPorts addObject:aPort];
    if ([aPort isKindOfClass:[LWSocketPort class]]) {
        LWSocketPort *socketTypePort = (LWSocketPort *)aPort;
        int fd = socketTypePort.socket;
        LWSocketPortRoleType roleType = LWSocketPortRoleTypeFollower;
        LWPortContext context = socketTypePort.context;
        [_queue.nativeRunLoop addFd:fd type:LWNativeRunLoopFdSocketClientType filter:LWNativeRunLoopEventFilterRead callback:context.LWPortReceiveDataCallBack data:context.info];
    }
}
```



### LWSocket

来看一下`LWSocket`的初始化

```
- (BOOL)initInternalWithTCPPort:(unsigned short)port
{
    if ((_sockFd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        return NO;
    }
    _context.info = (__bridge void *)(self);
    _context.LWPortReceiveDataCallBack = PortBasedReceiveDataRoutine;
    struct sockaddr_in sockAddr;
    memset(&sockAddr, 0, sizeof(sockAddr));
    sockAddr.sin_family = AF_INET;
    sockAddr.sin_addr.s_addr = htonl(INADDR_ANY);
    sockAddr.sin_port = htons(port);
    _roleType = LWSocketPortRoleTypeLeader;//leader
    int option = 1;
    setsockopt(_sockFd, SOL_SOCKET, SO_REUSEADDR, &option, sizeof(option));
    
    //if bind failure, the _sockFd become follower, othrewise leader
    if (-1 == bind(_sockFd, (struct sockaddr *)&sockAddr, sizeof(sockAddr))) {
        _roleType = LWSocketPortRoleTypeFollower;//follower
    }
    
    if (_roleType == LWSocketPortRoleTypeLeader) {
        if (listen(_sockFd, 5) == -1) {
            return NO;
        }
        [self setValid:YES];
        _port = port;
    } else {
        //we can ignore the `connect` delay for the local TCP connect
        int flag = connect(_sockFd, (struct sockaddr *)&sockAddr, sizeof(sockAddr));
        if (-1 == flag) {
            return NO;
        }
        struct sockaddr_in name;
        socklen_t namelen = sizeof(name);
        getsockname(_sockFd, (struct sockaddr *)&name, &namelen);
        _port = name.sin_port;
        [self setValid:YES];
    }
    return YES;
}
```



> - 对于Leader，其主要的功能是定义一个socket，打开一个网络通讯端口，用bind绑定一个固定的网络地址（127.0.0.1）和端口号（8082），然后调用listen监听请求
> - 对于Follow，其主要的功能是定义一个socket（其端口是默认分配的），并且调connect连接服务器，connect和bind的参数形式一致，区别在于bind的参数是自己的地址，而connect的参数是对方的地址
> - 非常典型的socket编程

### 消息发送

到此时，FollowPort和LeaderPort都有各自的线程以及对应的runloop，
以Follow向Leader发送消息为例，先把消息打包为`LWPortMessage`，然后调用`sendBeforeDate`，随后进入`internalSendBeforDate`

```
- (void)actualSendContent:(id)content
{
    int length = (int)[content length];
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&length length:sizeof(int)];
    [data appendData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    LWPortMessage *message = [[LWPortMessage alloc] initWithSendPort:_localPort receivePort:_distantPort components:data];
    [message sendBeforeDate:0];
}

- (BOOL)sendBeforeDate:(NSInteger)delay
{
    [self internalSendBeforDate:delay];
    return YES;
}

- (void)internalSendBeforDate:(NSInteger)delay
{
    LWSocketPort *_sendSocketPort = (LWSocketPort *)_sendPort;
    LWSocketPort *_receiveSocketPort = (LWSocketPort *)_receivePort;
    LWRunLoop *runloop = [LWRunLoop currentLWRunLoop];
    //send `data` from `leader` to `follower`
    if (_sendSocketPort.roleType == LWSocketPortRoleTypeLeader) {
        short port = _receiveSocketPort.port;
        [runloop send:_components toPort:port];
    } else {//send `data` from `follower` to `leader`
        int fd = _sendSocketPort.socket;
        [runloop send:_components toFd:fd];
    }
}
```



可以看到，在`internalSendBeforDate`中，首先拿到目的地的port，然后调用runloop的send方法

```
- (void)send:(NSData *)data toFd:(int)fd
{
    [_queue.nativeRunLoop send:data toFd:fd];
}

- (void)send:(NSData *)data toFd:(int)fd
{
    ssize_t nWrite;
    do {
        nWrite = write(fd, [data bytes], [data length]);
    } while (nWrite == -1 && errno == EINTR);
}
```



### 消息接受

Leader所在的runloop中kevent检测到了socket文件描述符的变化，然后唤醒该线程，随后调用方法`handleFollowerToLeader`进行处理，从中将前面发送的消息读出来，到此一次消息发送接收的流程就结束了

```
- (BOOL)handleFollowerToLeader:(int)event fd:(int)fd
{
    if (event & EVFILT_READ) {
        int length = 0;
        ssize_t nRead;
        do {
            nRead = read(fd, &length, sizeof(int));
        } while (nRead == -1 && EINTR == errno);
        if (nRead == -1 && EAGAIN == errno) {
            //The file was marked for non-blocking I/O, and no data were ready to be read.
            return false;
        }
        //buffer `follower` LWPort send `buffer` to `leader` LWPort
        char *buffer = malloc(length);
        do {
            nRead = read(fd, buffer, length);
        } while (nRead == -1 && EINTR == errno);
        NSValue *data = [_requests objectForKey:@(_leader)];
        PortWrapper request;
        [data getValue:&request];
        //notify leader
        if (request.callback) {
            request.callback(fd, request.info, buffer, length);
        }
        //remember release malloc memory
        free(buffer);
        buffer = NULL;
        struct sockaddr_in sockaddr;
        socklen_t len;
        int ret = getpeername(fd, (struct sockaddr *)&sockaddr, &len);
        if (ret < 0) {
            return false;
        }
        LWPortClientInfo *info = [_portClients valueForKey:[NSString stringWithFormat:@"%d", sockaddr.sin_port]];
        if (info.cacheSend && info.cacheSend.length > 0) {
            //write cached on next event
            [self kevent:fd filter:EVFILT_WRITE action:EV_ADD];
        }
    } else if (event & EVFILT_WRITE) {
        struct sockaddr_in sockaddr;
        socklen_t len;
        int ret = getpeername(fd, (struct sockaddr *)&sockaddr, &len);
        if (ret < 0) {
            return false;
        }
        LWPortClientInfo *info = [_portClients valueForKey:[NSString stringWithFormat:@"%d", sockaddr.sin_port]];
        if (info.cacheSend && info.cacheSend.length > 0) {
            ssize_t nWrite;
            do {
                nWrite = write(fd, [info.cacheSend bytes], info.cacheSend.length);
            } while (nWrite == -1 && errno == EINTR);
            
            if (nWrite != 1 && errno != EAGAIN) {
                    return false;
            }
            //clean the sending cache
            info.cacheSend = nil;
        } else {
            return false;
        }
    }
    return true;
}
```



## 总结

分析完该源码，回头再仔细想想Runloop，如果有可能，再去深究一下，如果相对之前理解上能有或许提升，本文的目的就达到了。
最后再盗用下作者github中的另一张图，也再次感谢作者 **wuyunfeng** ！
[![img](http://lingyuncxb.com/2018/06/15/%E5%A6%82%E4%BD%95%E5%AE%9E%E7%8E%B0%E4%B8%80%E4%B8%AA%E7%AE%80%E5%8D%95%E7%9A%84RunLoop%EF%BC%882%EF%BC%89/01.jpg)](http://lingyuncxb.com/2018/06/15/如何实现一个简单的RunLoop（2）/01.jpg)

