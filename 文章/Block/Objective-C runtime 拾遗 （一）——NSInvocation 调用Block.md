## 起

一日在开发之中，遇到这样一个问题，在某些场合，需要用NSInvocation来调用Block，而Block签名并不是固定，即，Block参数类型个数可以不同。

## 问题

### 回忆NSInvocation 一般用法

自然想到了NSInvocation，譬如如下代码：

```
NSString* string = @"Hello";
NSString* anotherString = [string stringByAppendingString:@" World!"];
```

写成Invocataion大致是这样的：

```
NSString* string = @"Hello";
NSString* anotherString;
NSString* stringToAppend = @" World!";
NSInvocation* inv = [NSInvocation invocationWithMethodSignature:[NSString instanceMethodSignatureForSelector:@selector(stringByAppendingString:)]];
inv.target = string;
[inv setArgument:&stringToAppend atIndex:2];
[inv invoke];
[inv getReturnValue:&anotherString];
```

具体就不详细介绍了，文档里讲得很详细。请移步[Apple Doc](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSInvocation_Class/index.html#//apple_ref/occ/cl/NSInvocation)

### MethodSignature

一个问题是如何Block获得MethodSignature。Block没有selector，但发现NSMethodSignature有这样一个方法`-[NSMethodSignature signatureWithObjCTypes:]`，那问题转化成如何从Block获得编码的Signature。

一搜索。发现[Clang官方文档](http://clang.llvm.org/docs/Block-ABI-Apple.html)和[stackoverflow](http://stackoverflow.com/questions/9048305/checking-objective-c-block-type)都有说这个问题。(Clang官方文档真是个宝库啊)。

按Clang的文档，Block定义如下：

```
struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
    unsigned long int reserved;     // NULL
    unsigned long int size;         // sizeof(struct Block_literal_1)
    // optional helper functions
    // void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
    // void (*dispose_helper)(void *src);             // IFF (1<<25)
    // required ABI.2010.3.16
    // const char *signature;                         // IFF (1<<30)
    void* rest[1];
    } *descriptor;
    // imported variables
};
```

中间注释部分是对做了些小改造，因为对于可以copy的Block，上述两个函数指针才存在。（另外，发现其实Block还能通过`block->invoke(...)`来调用，先按下不表）。

```
static const char *__BlockSignature__(id blockObj)
{
    struct Block_literal_1 *block = (__bridge void *)blockObj;
    struct Block_descriptor_1 *descriptor = block->descriptor;
    int copyDisposeFlag = 1 << 25;
    int signatureFlag = 1 << 30;
    assert(block->flags & signatureFlag);
    int offset = 0;
    if(block->flags & copyDisposeFlag)
        offset += 2;
    return (const char*)(descriptor->rest[offset]);
}

NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:__BlockSignature__(block)]];
```

最重要的一个问题解决了。之后就是对invocation调用setArgument，进行参数传递。（先简化一下问题，参数都是NSObject，放在NSArray里,关于参数获取后面还有坑，以后再写）

```
    for(NSUInteger i = 0; i < args.count ; ++i){
        id object = args[i];
        [invocation setArgument:&object atIndex:i + 2];
    }
    [invocation invokeWithTarget:block];
```

调用，Crash！越界了

> Reason: -[NSInvocation setArgument:atIndex:]: index (5) out of bounds [-1, 4]

文档是这样描述`setArgument`的

> Indices 0 and 1 indicate the hidden arguments self and _cmd, respectively; these values can be retrieved directly with the target and selector methods. Use indices 2 and greater for the arguments normally passed in a message.

其实上述代码问题很多，刚才有点[撞大运编程](http://coolshell.cn/articles/2058.html)

1. selector(即`_cmd`)哪里去了？并没有传递给NSInvocation
2. 为什么越界，按照文档说法应该从2开始。
3. 为什么从-1开始

文档说的言之凿凿，第一个参数传self，第二个是selector(即`_cmd`)，但block调用并没有selector，参数个数其实可以从MethodSignature获取：`invocation.methodSignature.numberOfArguments`

所以这就是会越界的原因，正确的做法是从1开始：

```
[invocation setArgument:&object atIndex:i + 1]
```

一调试，果然。

> 另外从-1开始原因是-1的位置是存储return result，当然这个结论我查了文档并没有找到，也是试出来的。囧。

## 源码及其他

源码我放在了github，戳[这里](https://github.com/deput/NSInvocation-Block)

用法也很简单：

```
NSInvocation* inv = [NSInvocation invocationWithBlock:block];
```

后续会增加一些接口如：
`+ (instancetype) invocationWithBlockAndArguments:(id) block ,...;`

## 更新

恩 已经增加了。

增加的接口用法：
对于

```
void (^myBlock)(id, NSArray*,double, int**) = ^(id obj1, NSArray* array, double dNum,int** pi) {
  NSLog(@"%@",@"Hey!");
};
int* i = NULL;
NSInvocation* inv = [NSInvocation invocationWithBlockAndArguments:myBlock,[NSObject new],@[@1,@2,@3],1.23,&i];
```

参数支持`id`,所有简单值类型,`IMP`,`SEL`,`Class`,`Block`,`指针`, 但Struct,Union,C-style Array 不支持，比较预想的tricky，研究中。

