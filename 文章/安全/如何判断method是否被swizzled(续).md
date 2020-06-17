## 承

[上次的文章](https://segmentfault.com/a/1190000003950284)介绍了一种方法用来检测Objective-C中Method是否被swizzled。但该方法只能检测非系统的方法，即，必须在源文件中的目标方法中添加上述的宏才能Work，对于系统类的方法被Hook就无计可施了。
代码整理后我会放到我的[github](https://github.com/deput/RWHookDetector)

## 突破口

回想一下Objective-C中Method Swizzling的原理，看如下代码：

```
@implementation UIViewController (Hook)
- (void)viewDidLoad2 {
    [self viewDidLoad2];
}
+ (void)load {
    Method ori_method = class_getInstanceMethod([UIViewController class], @selector(viewDidLoad));
    Method replace_method = class_getInstanceMethod([UIViewController class], @selector(viewDidLoad2));
    method_exchangeImplementations(ori_method, replace_method);
}
@end
```

`Method Swizzling`的核心是交换两个Method的`IMP`,而`IMP`的定义则是:

```
typedef id (*IMP)(id, SEL, ...); 
```

实际上是函数指针。

那我可以做一些推测（[撞大运编程](http://coolshell.cn/articles/2058.html)又开始了），当App的二进制格式不会被混淆的前提下，App加载的某个dylib或者编译时期某个framework的.a文件，其二进制肯定连续的，意思是在二进制文件中，某个dylib或者framework中符号肯定是相对固定的。譬如，对于上述这个例子，`UIViewController`这个Class的symbol的地址相对于`-[UIViewController viewDidLoad]`的`IMP`的地址偏移肯定是固定的。

写段代码来证明一下：

```
NSMutableDictionary *offsetDict = @{}.mutableCopy;
unsigned classCount = 0;
Class *allClasses = objc_copyClassList(&classCount);
for (unsigned classIndex = 0; classIndex < classCount; ++classIndex) {
    @autoreleasepool {
        Class cls = allClasses[classIndex];
        //只管UI NS开头的类
        if ([NSStringFromClass(cls) hasPrefix:@"UI"] || [NSStringFromClass(cls) hasPrefix:@"NS"]) {
            unsigned methodCount = 0;
            Method *methods = class_copyMethodList(cls, &methodCount);
            for (unsigned methodIndex = 0; methodIndex < methodCount; ++methodIndex) {
                Method mtd = methods[methodIndex];
                NSString *mtdString = [NSString stringWithUTF8String:sel_getName(method_getName(mtd))];
                //_开头的内部方法忽略
                if ([mtdString hasPrefix:@"_"]){
                    continue;
                }

                IMP imp = method_getImplementation(mtd);
                int offset = (int) cls - (int) imp;
                offsetDict[[NSString stringWithFormat:@"[%@ %s]", NSStringFromClass(cls), sel_getName(method_getName(mtd))]] = @(offset);
            }
        }
    }
}
```

所以我就拿到了所有类的所有方法相对于该类的偏移。这个offsetDict是在离线环境拿到的，必须是在纯净的（即保证没有任何`method swizzling`的情况下）环境下获得的。

在实际项目环境中，再读取这个offsetDict，用来和实际的offset比较，就能判断该Method是否被swizzled或者overridden。代码如下：

```
BOOL isSiwwzledOrOverridden(Class cls, SEL selector) {
    //省略部分代码。。。
    if (offsetDict){
        NSNumber *num = offsetDict[[NSString stringWithFormat:@"[%@ %s]", NSStringFromClass(cls), sel_getName(selector)]];
        if (num == nil){
            NSLog(@"Could not find selector!");
            return NO;
        }
        IMP imp = [cls instanceMethodForSelector:selector];
        int offset = (int) cls - (int) imp;

        if (offset != [num integerValue])
            return YES;
    }
    return NO;
}
```

试了一下，果然有用！对于下列示例：

```
@implementation UIViewController (YouDonKnow)
- (void)viewDidLoad2 {
    [self viewDidLoad2];
}
+ (void)load {
    Method ori_method = class_getInstanceMethod([UIViewController class], @selector(viewDidLoad));
    Method replace_method = class_getInstanceMethod([UIViewController class], @selector(viewDidLoad2));
    method_exchangeImplementations(ori_method, replace_method);
}
- (void)viewDidAppear:(BOOL)animated {
}
@end
```

我们只需要调用：

```
BOOL ret = isSiwwzledOrOverridden([UIViewController class], @selector(viewDidLoad));//YES 这是swizzling的情况
ret = isSiwwzledOrOverridden([UIViewController class], @selector(viewDidAppear:));//YES 这是overridden的情况
ret = isSiwwzledOrOverridden([UIViewController class], @selector(viewWillAppear:))//NO
```

就能知道是否被替换或者被覆盖了。

## 问题一大堆

- `x86` `armv7` `arm64` binary的format是不一样的，经实验的确如此，所以offsetdict需要三个，分别是三个平台的。
- 由于OC有Category,如Foundation里的Class某些Method的实现并不是放在Foundation的二进制里的。比如：NSObject的Accessibility。这些method也有可能会被认为是swizzled。
- 上面说了，这样推断只不过是撞大运编程大法的升级版，其实并没有证据表明iOS的二进制结构满足这个规律（实际上有这些文档与资料）。
- 其实arm64或许有更简单的方法：

```
#if TARGET_CPU_ARM64
BOOL isSiwwzledOrOverriddenOnArm64(Class cls, SEL selector) {
    IMP imp = [cls instanceMethodForSelector:selector];
    int offset = (int) cls - (int) imp;
    return offset < 0;
}
#endif
```

就不误人子弟了，自己参悟一下吧，没找到有确切证据，只是实验出来的。

- 只在DEBUG下试过，不太确定是否会被[ASLR](https://www.theiphonewiki.com/wiki/ASLR)影响。不过我持乐观态度，因为：

1. 该文章的目的并不是要在真正的运行时去检测Swizzling从而进行防御，因为如果是防御攻击，在有可能被hook的前提下，上述方法本身也能够被Hook。
2. ASLR应该只会做基址偏移（`On program load, the address space offset of the program is randomized between 0x0 and 0x100000`），不会影响上述offset的计算，没看到说iOS的ASLR会将其他lib的二进制全弄乱。