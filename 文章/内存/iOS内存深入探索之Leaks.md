# 前言

提到iOS的内存泄漏检测，第一个想到的应该就是Instruments的Leaks检测模版。不过使用过的人一般都会觉得这个检测不准确，有时候明明泄露了，但是它却检测不出来。本文将带大家深入了解Leaks模版检测泄漏的原理，知道原理之后，你就会明白哪些类型的内存泄漏可以被检测，哪些无法被检测了。

# 常规的内存泄漏情景

iOS中我们使用引用计数来管理OC对象，但是对于CoreFoundation中的对象，我们只能手动管理或者桥接到OC对象，通过引用计数来管理。对于手动malloc或者vm_allocate的内存，则只能手动或者自定义一套内存管理系统去管理了。所以对于一个iOS开发人员来说，发生泄漏的主要情景有

1. OC对象循环引用
2. OC对象被全局变量直接或者间接持有，忘记断开
3. CF对象或者malloc的内存忘记手动释放

那么Leaks检测模版能检测出哪些泄漏呢？我们先介绍Leaks模版检测泄漏的原理再一一分析。

# Leaks如何检测内存泄漏

Instruments对Leaks的介绍仅仅是`Examines a process' heap for leaked memory;`，检测一个进程堆里的泄露内存。翻看一下官方的[Find Memory Leaks](https://link.jianshu.com/?t=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Fcontent%2Fdocumentation%2FDeveloperTools%2FConceptual%2FInstrumentsUserGuide%2FFindingLeakedMemory.html)介绍，里面对于Leak Memory的介绍稍微的详细一些，`check for leaks—memory that has been allocated to objects that are no longer referenced and reachable.`，所以一块内存是否泄露，主要取决于它是否`referenced and reachable`，那么怎么定义一块内存是否被引用呢？当然不是通过引用计数，因为还得检测malloc出来的内存，只有OC对象有引用计数概念。通过搜索，我找到了Leaks模版的命令行版本，也是苹果官方提供的。打开你的命令行，输入



```undefined
man leaks
```

一份详细的介绍文档就出来了。



```cpp
NAME
     leaks -- Search a process's memory for unreferenced malloc buffers
```

这里对于leaks工具的简介更加的清晰，`unreferenced malloc buffers`表明这个工具的基本原理就是检测malloc的内存块是否被依然被引用。非malloc出来的内存块则无能为力，比如vm_allocate出来的内存。想要了解vm_allocate相关的知识，可以去看[这篇文章](https://link.jianshu.com/?t=http%3A%2F%2Fwww.gltech.win%2Fios%E5%BC%80%E5%8F%91%2F2018%2F01%2F23%2FiOS%E5%86%85%E5%AD%98%E6%B7%B1%E5%85%A5%E6%8E%A2%E7%B4%A2%E4%B9%8BVM-Tracker.html)。因为OC对象也都是通过malloc分配内存的，所以自然也可以检测。下面的文档则更清晰的告诉我们什么是`unreferenced malloc buffers`。



```rust
Specifically, leaks examines a specified process's memory for values that may be pointers to malloc-allocated buffers.  Any buffer reachable from a pointer in writable
global memory (e.g., __DATA segments), a register, or on the stack is
assumed to be memory in use.  Any buffer reachable from a pointer in a
reachable malloc-allocated buffer is also assumed to be in use.  The
buffers which are not reachable are leaks;
```

大致意思就是leaks搜索所有可能包含指向malloc内存块指针的内存区域，比如全局数据内存块，寄存器和所有的栈。如果malloc内存块的地址被直接或者间接引用，则是`reachable`的，反之，则是leaks。

# 泄漏检测情景分析

## OC对象循环引用

我们可以通过一个小例子来还原这个情景。



```dart
@interface LeakObject : NSObject
@property LeakObject *cycleRef;
@end

// 构造循环引用
LeakObject *leakObj1 = [LeakObject new];
LeakObject *leakObj2 = [LeakObject new];
leakObj1.cycleRef = leakObj2;
leakObj2.cycleRef = leakObj1;
```

接下来我们使用Instruments Leaks或者leaks命令行来检测泄漏。





![img](https:////upload-images.jianshu.io/upload_images/2949750-a6826609c6671719.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)



下面是我用leaks工具检测出来的泄漏。使用命令`leaks PID`，PID是进程ID，在模拟器运行App，然后通过Activity Monitor找到对应的PID。



```dart
...
Analysis Tool Version:  iOS Simulator 11.2 (15C107)
----

leaks Report Version:  2.0
leaks[9676]: Process 9648 is not debuggable.
Due to security restrictions, leaks cannot show memory contents of restricted processes.

Process 9648: 32174 nodes malloced for 7490 KB
Process 9648: 2 leaks for 9216 total leaked bytes.
Leak: 0x7fe4c9044e00  size=4608  zone: MallocHelperZone_0x123380000   LeakObject  ObjC  LeaksExample
Leak: 0x7fe4c9046000  size=4608  zone: MallocHelperZone_0x123380000   LeakObject  ObjC  LeaksExample
```

命令行工具也很好的为我们检测出来了泄漏。由于两个LeakObject互相引用，而且未被全局数据内存块，寄存器或者任何栈持有引用，所以被判定为unreachable的leak对象。

## OC对象被全局变量直接或者间接持有

这种情况其实是Leaks无法检测的，因为被全局对象直接或者间接引用的malloc内存块在Leaks看来还是reachable的。最简单的例子就是被static的指针变量引用，在上面的基础上举个例子。



```dart
static void *leakObj = NULL;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 构造循环引用
    LeakObject *leakObj1 = [LeakObject new];
    LeakObject *leakObj2 = [LeakObject new];
    leakObj1.cycleRef = leakObj2;
    leakObj2.cycleRef = leakObj1;
    
    leakObj = (__bridge void *)leakObj1;
}
@end
```

注意，我用的static变量只是一个`void *`类型的指针，不会对`leakObj1`的引用计数造成任何实质性的影响，但却对Leaks的检测结果造成了影响。



![img](https:////upload-images.jianshu.io/upload_images/2949750-4d1663829c093299.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/998)





因为static变量`leakObj`处于全局数据内存区，Leaks检测到这个变量指向`leakObj1`的内存区域，所以认为`leakObj1`是reachable的，并无泄漏发生。这就是static变量对Leaks检测的影响。这个例子属于展示的比较直接，下面再看一个隐藏比较深的例子。
为LeakObject增加一个block属性。



```objectivec
typedef void(^LeakCallback)(void);
@interface LeakObject : NSObject
@property LeakObject *cycleRef;
@property (copy) LeakCallback callback;
@end
```

利用这个block构造循环引用。下面是一个标准的由block引起的循环引用。



```css
@interface ViewController () {
    LeakObject *_testLeak;
}
@end
```



```objectivec
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    LeakObject *leakObj = [LeakObject new];
    leakObj.callback = ^ {
        NSLog(@"%@", self);
    };
    _testLeak = leakObj;
}
@end
```

最后在AppDelegate中创建ViewController然后再释放掉它。



```objectivec
UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
window.rootViewController = navVC;
[window makeKeyAndVisible];

ViewController *vc = [ViewController new];
[navVC.topViewController presentViewController:vc animated:YES completion:^{
    
}];
[vc dismissViewControllerAnimated:YES completion:nil];
```

使用Leaks进行检测，你会发现并无泄漏。



![img](https:////upload-images.jianshu.io/upload_images/2949750-c507a26de39c3c86.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/890)




为什么呢？我们再次运行App，使用Debug Memory Graph来看看内存中对象的引用关系图。



![img](https:////upload-images.jianshu.io/upload_images/2949750-66d327ca57f838aa.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)




我们可以发现，ViewController被一个引用，很明显这只是一个弱引用，否则ViewController永远不会被释放，这和我在上面使用void *引用LeakObject属于同一种方式。你可以使用来查看这个的内存区域，可以看到ViewController的内存地址。



![img](https:////upload-images.jianshu.io/upload_images/2949750-ace2231b28fce95f.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)





`0x60000001dc90`是`malloc(16)`的起始地址，`0x7fe312608780`是ViewController的内存地址。ViewController通过这个`malloc(16)`被reachable的内存块引用，所以Leaks认为ViewController并没有泄漏。不过目前我还没有弄清楚这个`malloc(16)`来自哪里，有什么作用，如果你感兴趣，可以深入研究一下。

上面的2个例子解释了为什么有时候Leaks无法检测出来某些内存泄露，它们还仅仅是弱引用，如果你不小心使用全局变量强引用了OC对象，那么你只能靠Allocations的引用计数Recorder来一一排查了，Leaks工具完全无法给你提供任何帮助。

## CF对象或者malloc的内存忘记手动释放

这两种情况还是很好检测的，不过它们同样会受全局变量引用的影响。读者可以自己尝试全局变量引用对于malloc和CF对象Leaks检测的影响。

# 总结

实际开发过程中，遇到的情况会复杂的多，不过当我们掌握了Leaks检测的原理后，就能够更有目标性的解决内存泄露。当Leaks检测失效，可以在Allocations列表中观察当前存活的对象，是否有应该已经被释放却依然存活的，如果有就应该开始思考系统或者自身的代码是否在全局数据区对它有任何形式的引用，还可以借助Debug Memory Graph来观察存疑对象的引用关系图。结合多方工具，大部分的内存泄漏还是很好解决的，不过有些泄漏可能存在于第三方库甚至系统库中，这些就要费很多功夫了，或者你也可以直接换其他库。