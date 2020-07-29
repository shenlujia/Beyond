# 深入解构iOS系统下的全局对象和初始化函数

2018.05.31 14:08:28

### 神奇的崩溃事件

事件源于接入了一个第三方库导致应用出现了大量的crash记录，很奇怪的是这么多的crash居然没有收到用户的反馈信息！ 在这个过程中每个崩溃栈的信息都明确的指向了是那个第三方库的某个工作线程产生的崩溃。这个问题第三方提供者一直无法复现，而且我们的RD、PM、QA同学在调试和测试过程中都没有出现过这个问题。后来再经过仔细检查分析，发现每次崩溃时的各线程的调用栈都大概是如下的情况：

```
Hardware Model:      iPhone7,2
Code Type:       ARM-64
Parent Process:  ? [1]
Date/Time:       2018-05-10 10:22:32.000 +0800
OS Version:      iOS 10.3.3 (14G60)
Report Version:  104
Exception Type:  EXC_BAD_ACCESS (SIGBUS)
Exception Codes: 0x00000000 at 0xbadd0c44f948beb5
Crashed Thread:  33


Thread 0:
0   xxxx                            xxxx::Threads::Synchronization::AppMutex::~AppMutex() (xxxx.cpp:58)
1   libsystem_c.dylib               __cxa_finalize_ranges + 384
2   libsystem_c.dylib               exit + 24
3   UIKit                           +[_UIAlertManager hideAlertsForTermination] + 0
4   UIKit                           __102-[UIApplication _handleApplicationDeactivationWithScene:shouldForceExit:transitionContext:completion:]_block_invoke.2093 + 792
5   UIKit                           _runAfterCACommitDeferredBlocks + 292
6   UIKit                           _cleanUpAfterCAFlushAndRunDeferredBlocks + 528
7   UIKit                           _afterCACommitHandler + 132
8   CoreFoundation                  __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ + 32
9   CoreFoundation                  __CFRunLoopDoObservers + 372
10  CoreFoundation                  __CFRunLoopRun + 956
11  CoreFoundation                  CFRunLoopRunSpecific + 424
12  GraphicsServices                GSEventRunModal + 100
13  UIKit                           UIApplicationMain + 208
14  xxxx                            main (main.m:36)
15  libdyld.dylib                   start + 4


Thread 33 name:  xxxx
Thread 33 Crashed:
0   xxxx                            xxxx::Message::recycle() + 184
1   xxxx                            xxxx::Message::recycle() + 176
2   xxxx                            xxxx::BaseMessageLooper::onProcMessage(xxxx::Message*) + 192
3   xxxx                            xxxx::Looper::loop() + 60
4   xxxx                            xxxx::MessageThread::run() + 96
5   xxxx                            xxxx::Thread::runCallback(void*) + 108
6   libsystem_pthread.dylib         _pthread_body + 240
7   libsystem_pthread.dylib         _pthread_body + 0

Thread 33 crashed with ARM-64 Thread State:
  cpsr: 0x00000000a0000000     fp: 0x000000017102ae60     lr: 0x00000001018744c4     pc: 0x00000001018744cc 
    sp: 0x000000017102ae40     x0: 0xbadd0c44f948bead     x1: 0x0000000000000000    x10: 0x0000000000000000 
   x11: 0x0000000102a50178    x12: 0x000000000000002c    x13: 0x000000000000002c    x14: 0x0000000102a502d8 
   x15: 0x0000000000000000    x16: 0x0000000190f3fa1c    x17: 0x010bcb01010bcb00    x18: 0x0000000000000000 
   x19: 0x00000001744a2460     x2: 0x0000000000000008    x20: 0x00000001027da5b8    x21: 0x0000000000000000 
   x22: 0x0000000000000001    x23: 0x0000000000025903    x24: 0x0000000000000000    x25: 0x0000000000000000 
   x26: 0x0000000000000000    x27: 0x0000000000000000    x28: 0x0000000000000000    x29: 0x000000017102ae60 
    x3: 0x0000000190f4f2c0     x4: 0x0000000000000002     x5: 0x0000000000000008     x6: 0x0000000000000000 
    x7: 0x00000000010bcb01     x8: 0xbadd0c44f948beb5     x9: 0x0000000000000000 
```

从上面主线程的调用栈可以看出里面有执行exit函数，而exit是一个执行进程结束的函数，因此从调用栈来看其实这正是用户在主动杀掉我们的App应用进程时主线程会执行的逻辑。也就是说出现崩溃的时机就是在主动杀掉我们的应用的时刻发生的！

这真的是一个非常神奇的时刻，当我们主动杀掉应用时产生了崩溃，所以整个事件就出现了上面的场景：没有用户反馈异常、我们自身也很难复现出崩溃的场景(非连机运行时)。

### 问题复现

分析出原因后为了验证问题，通过不停的执行手动杀进程的测试，在一个偶然的机会下终于复现了问题：在主线程执行exit的时机，那个第三方库的工作线程的某处出现非法地址访问，而停止了执行：

这个来之不易的崩溃信息起了非常大的作用，根据汇编代码按图索骥，并和对方进行交流定位到了对应的源代码。第三方库的一个线程是一个常驻线程，它会周期性并且高频的访问一个全局C++对象实例的数据，出现奔溃的原因就是这个全局C++对象的类的构造函数中从堆里面分配了一块内存，而当进程被终止这个过程中，这个全局对象被析构，析构函数中会将分配的堆内存进行回收。但是那个常驻线程因为此刻还没有被终止，它还像往常一样继续访问这个已经被析构了的全局对象的堆内存，从而导致了上面图中的内存地址访问非法的问题。下面就是问题发生的过程：

### C++全局对象

可以肯定一点的就是那个第三方库由于对全局C++对象的使用不当而产生了问题。我们知道每个C++对象在创建时都会调用对应的构造函数，而对象销毁时则会调用对应的析构函数。构造和析构函数都是一段代码，对象的创建和销毁一般都是在某个函数中进行，这时候对象的构造/析构函数也是在那个调用者函数中执行，比如下面的代码：

```
class CA{
public:
    CA(){
       printf("CA::CA()");
     }

   void ~CA(){
     printf("CA::~CA()");
     }
};

CA b; 

int main()
{
     CA  a;   
     printf("hello");
     return 0;
}
```

系统在编译C++代码时会进行一些特定的处理(这里以C语言的形式来描述)：

```
struct CA{
};


void __ZN2CAC1Ev(CA *  const this)
{
    printf("CA::CA()");
}


void __ZN2CAD1Ev(CA * const this)
{
     printf("CA::~CA()");
}


struct CA b;

int main()
{
     struct CA a;
     __ZN2CAC1Ev(&a);   
     printf("hello");
     __ZN2CAD1Ev(&a);   
     return 0;
}
```

上面的源代码中b这个全局对象并不是在某个函数或者方法内部定义，
所以它并没有执行构造函数以及析构函数的上下文环境，那么是否创建一个全局对象时它的构造函数以及析构函数就无法被执行呢了？答案是否定的。只要任何一个C++类定义了构造函数或者析构函数，那么在对象创建时总是会调用构造函数，并且在对象销毁时会调用对应的析构函数。那么全局对象的构造函数和析构函数又是在什么时候被调用执行的呢？

### +load方法

在一个Objective-C类中，可以定义一个+load方法，这个+load方法会在所有OC对象创建前被执行，同时也会在main函数调用前被执行。一般情况下我们会在类的+load方法中实现一些全局初始化的逻辑。OC类的方法也是要求一定的上下文环境下才能被执行，那么+load方法又是在什么时候被调用执行的呢？

### 全局构造/析构C函数

除了建立C++全局对象、实现OC类的+load方法来进行一些全局的初始化逻辑外，我们还可以定义带有特殊标志的C函数来实现main函数执行前以及main函数执行完毕后的处理逻辑。

```
void __attribute__ ((constructor)) beginfunc()
{
    printf("beginfunc\n");
}


void __attribute__ ((destructor)) endfunc()
{
    printf("endfunc\n");
}

int main()
{
    printf("main\n");
    return 0;
}
```

上面的代码中可以看出，我们并没有显式的调用beginfunc和endfunc函数的情况下，函数依然被调用执行。那么这些函数又是如何被调用执行的呢？

### main函数执行前发生了什么？

操作系统在启动一个程序时，内核会为程序创建一个进程空间，并且会为进程创建一个主线程，主线程会执行各种初始化操作，完成后才开始执行我们在程序中定义的main函数。也就是说main函数其实并不是主线程最开始执行的函数，在main函数执行前其实还发生了很多的事情：操作系统内核为可执行程序创建进程空间后，会分别将可执行程序文件以及可执行程序所依赖的动态库文件中的内容加载到进程的虚拟内存地址空间。可执行程序以及动态库文件中的内容是符合苹果操作系统ABI规则的mach-o格式的二进制数据，我们必须要将这些数据加载到内存中，对应的代码才能被执行以及变量才能被访问。我们称每个映射到内存空间中的可执行文件以及动态库文件的副本为**image(映像)**。注意此时只是将文件加载到内存中去并没有执行任何用户进程的代码，也没有调用库中的任意初始化函数。当所有image加载完毕后，内核会为进程创建一个主线程，并将可执行程序的image在内存中的地址做为参数压入用户态的堆栈中，把**dyld**库中的**_dyld_start**函数作为主线程执行的入口函数。这时候内核将控制权交给用户，系统由核心态转化为用户态，dyld库来实现进程在用户态下的可执行文件以及所有动态库的加载和初始化的逻辑。**可见一个程序运行时可执行文件以及所有依赖的动态库其实是经历过了两次的加载过程：核心态下的image的加载，以及用户态下的二次加载以及初始化操作。** dyld库接管进程后，进程的主线程将从__dyld_start处开始所有用户态下代码的执行。

> dyld库最新版本的开源源代码以及_dyld_start函数的代码可以从苹果的开源站点:https://opensource.apple.com/source/dyld/dyld-519.2.2/处获取到。你也可以打开URL：**https://opensource.apple.com/source/** 来浏览所有苹果已经开源了的系统库。还有一点需要注意的就是开源的代码不一定是最新的代码，而且有可能和运行时的代码有差异，所以如果想了解真实的实现原理，最好是配合调试时的汇编代码来一起分析和阅读。

我们可以在**dyldStartup.s**中看到__dyld_start函数的各种平台下的实现，下面是一段arm64架构下的汇编代码，函数的定义大体如下：

```
#if __arm64__
    .data
    .align 3
__dso_static: 
    .quad   ___dso_handle

    .text
    .align 2
    .globl __dyld_start
__dyld_start:
    mov     x28, sp
    and     sp, x28, #~15       
    mov x0, #0
    mov x1, #0
    stp x1, x0, [sp, #-16]! 
    mov fp, sp          
    sub sp, sp, #16             
    ldr     x0, [x28]       
    ldr     x1, [x28, #8]           
    add     x2, x28, #16        
    adrp    x4,___dso_handle@page
    add     x4,x4,___dso_handle@pageoff 
    adrp    x3,__dso_static@page
    ldr     x3,[x3,__dso_static@pageoff] 
    sub     x3,x4,x3        
    mov x5,sp                   
    
    
    bl  __ZN13dyldbootstrap5startEPK12macho_headeriPPKclS2_Pm
    mov x16,x0                  
    ldr     x1, [sp]
    cmp x1, #0
    b.ne    Lnew

    
    add sp, x28, #8     
    br  x16         

    
Lnew:   mov lr, x1          
    ldr     x0, [x28, #8]       
    add     x1, x28, #16        
    add x2, x1, x0, lsl #3  
    add x2, x2, #8      
    mov x3, x2
Lapple: ldr x4, [x3]
    add x3, x3, #8
    cmp x4, #0
    b.ne    Lapple          
    br  x16     

#endif 
```

将汇编代码翻译为高级语言的伪代码可以简单理解为：

```
void __dyld_start(const struct macho_header* appsMachHeader, int argc, char *[] argv)
{
       intptr_t slide = dyld的image在内存中的偏移量。
       const struct macho_header *dyldsMachHeader = dyld库的macho_header的地址。
       void (*startGlue)(int);   

       
       int (*main)(int argc, char*[] argv) = dyldbootstrap::start(appsMachHeader, argc, argv, slide, dyldsMachHeader, &startGlue);
       
       int ret = main(argc, argv);
       
       startGlue(ret);
}
```

这里需要说明一下，上面的汇编代码并没有出现调用startGlue的地方，但是高级语言伪代码中又出现了，原因是最后的 `br x16` 指令只是一个简单的跳转到main函数的指令而非是函数调用指令，而**dyldbootstrap::start**函数的最后一个输出参数&startGlue其实是保存到栈顶sp中的，因此当main函数执行完毕并返回后就会把栈顶sp中保存的startGlue地址赋值给pc寄存器，从而实现了对startGlue函数的调用。那么**dyldbootstrap::start**最后一个参数返回并保存到startGlue中的又是一个什么函数地址呢？这个函数地址是**libdyld.dylib(注意dyld和libdyld.dylib是两个不同的库)**库中的一个静态函数start。它的实现很简单：

```
   void start(int ret)
   {
        exit(ret);
   }
```

> 小知识点：当我们查看主线程的调用栈时发现调用栈的最底端的函数是libdyld库中的start函数，而非dyld库中的__dyld_start函数。同时当你切换到start函数的汇编代码处时，你会发现它并没有调用main函数的痕迹。原因就是在调用main函数之前，其实栈顶寄存器中的值保存的是start函数的地址，而非br x16的下条指令的地址 并且br指令只是跳转并不会执行压栈的动作，所以在查看主线程调用栈时您所看到的栈底函数就是start而非__dyld_start了。

从**__dyld_start**函数的实现中可以看出它总共做了三件事：

1. **dyldbootstrap::start**函数执行所有库的初始化，执行所有OC类的+load的方法，执行所有C++全局对象的构造函数，执行带有_*attribute_*(constructor)定义的C函数。
2. **main**函数执行用户的主功能代码。
3. **startGlue**函数执行exit退出程序，收回资源，结束进程。

在这里我不打算深入的去介绍*dyldbootstrap::start*函数的实现，详细情况大家可以去阅读源代码。

- *dyldbootstrap::start*函数内部主要调用了*dyld::_main*函数。
- *dyld::main*函数内部会根据依赖关系递归的为每个加载的动态库构建一个对应的*ImageLoaderMachO*对象，并添加到一个全局的数组*sImageRoots*中去，最后再调用*dyld::initializeMainExecutable*函数。
- *dyld::initializeMainExecutable*函数内部的实现主要就是则遍历全局数组*sImageRoots*中的每个*ImageLoaderMachO*对象，并分别调用每个对象的*runInitializers*方法来执行动态库的各种初始化逻辑，最后再调用主程序的*ImageLoaderMachO*的*runInitializers*方法来执行主程序的各种初始化逻辑。
- *ImageLoaderMachO*是一个C++类，类里面的*runInitializers*方法内部主要是调用类中的成员函数*processInitializers*来处理各种初始化逻辑。
- *processInitializers*方法内部的实现主要调用动态库自身所依赖的其他动态库的ImageLoaderMachO对象的*recursiveInitialization*方法。
- *recursiveInitialization*方法内部的主要实现是首先调用*dyld::notifySingle*函数来初始化所有objc相关的信息，比如执行这个库里面的所有类定义的+load的方法；然后再调用doInitialization方法来进一步执行初始化的动作。
- *doInitialization*方法内部首先调用*doImageInit*来执行映像的初始化函数，也就是LC_ROUTINES_COMMAND中记录的函数(这个函数就是在构建动态库时的编译选项中指定的那个初始执行函数)；然后再执行doModInitFunctions方法来执行所有库内的全局C++对象的构造函数，以及所有带有_*attribute_*(constructor)标志的C函数。

自此，所有main函数之前的逻辑代码都已经被执行完毕了。可能你会问整个过程中还是没有看到关于C++全局对象构造函数是如何被执行的？关于这个问题，我们先暂停一下，而是首先来考察一下当一个进程被结束前系统到底做了什么。

### 进程结束时我们能做什么？

当我们双击home键然后滑动手势来终止某个进程或者手动调用exit函数时会结束进程的执行。当进程被结束时操作系统会回收进程所使用的资源，比如打开的文件、分配的内存等等。进程有可能会主动结束，也有可能被动的结束，因此操作系统提供了一系列注册进程结束回调函数的能力。在进程结束前会调用这些回调函数，因此我们可以通过进程结束回调函数来执行一些特定资源回收或者一些善后收尾的工作。注册进程结束回调函数的函数定义如下：

```
 #include <stdlib.h>

     
     int  atexit(void (*func)(void));

    
     int  atexit_b(void (^block)(void));

    
    int __cxa_atexit(void (*func)(void *), void *arg, void *dso)
```

上面的三个函数分别用来注册进程结束时的标准C函数、block代码、C++函数。可以注册多个进程结束回调函数，并且系统是按照后注册先执行的后进先出的顺序来执行所有回调函数代码的。比如下面的代码：

```
void foo1()
{
    printf("foo1\n");
} 

void foo2()
{
    printf("foo2\n");
}

int main(int argc, char* [] argv)
{
      atexit(&foo1);
      atexit(&foo2);

     printf("main\n");
     return 0;
}
```

从上面提供的三种注册方法，以及回调函数的执行顺序其实我们可以大体了解到系统是如何存储这些回调函数的，我们可以通过如下的数据结构清楚的看到：

```
#define ATEXIT_FN_EMPTY 0
#define ATEXIT_FN_STD   1
#define ATEXIT_FN_CXA   2
#define ATEXIT_FN_BLK   3

struct atexit {
    struct atexit *next;            
    int ind;                
    struct atexit_fn {
        int fn_type;            
        union { 
            void (*std_func)(void);
            void (*cxa_func)(void *);
            void (^block)(void);
        } fn_ptr;           
        void *fn_arg;           
        void *fn_dso;           
    } fns[ATEXIT_SIZE];         
};


static struct atexit *__atexit;     
```

**struct atexit**是一个链表和数组的结合体。用图形表示所有注册的函数的存储结构大体如下：

从数据结构的定义以及atexit函数的描述和上面的图形我们应该可以很容易的去实现那三个注册函数。大家可以去阅读上面三个函数的实现，这里就不再列出了。

上面说了进程结束回调注册函数会在进程结束时被调用，而进程结束的函数是exit函数，因此可以很容易就想到这些回调函数的执行肯定是在exit函数内部调用的，事实也确实如此，通过汇编代码查看exit的实现如下：

```
libsystem_c.dylib`exit:
    0x1838a7088 <+0>:  stp    x20, x19, [sp, #-0x20]!
    0x1838a708c <+4>:  stp    x29, x30, [sp, #0x10]
    0x1838a7090 <+8>:  add    x29, sp, #0x10            ; =0x10 
    0x1838a7094 <+12>: mov    x19, x0
    0x1838a7098 <+16>: mov    x0, #0x0
    0x1838a709c <+20>: bl     0x1838fdc30               ; __cxa_finalize
    0x1838a70a0 <+24>: adrp   x8, 200782
    0x1838a70a4 <+28>: ldr    x8, [x8, #0xf20]
    0x1838a70a8 <+32>: cbz    x8, 0x1838a70b0           ; <+40>
    0x1838a70ac <+36>: blr    x8
    0x1838a70b0 <+40>: mov    x0, x19
    0x1838a70b4 <+44>: bl     0x1839702e4               ; __exit
```

上面的汇编翻译为高级语言伪代码大体如下：

```
  void exit(int ret)
  {
       __cxa_finalize(NULL);
       __exit(ret);
  }
```

**__cxa_finalize**函数字面上是用于结束所有C++对象，但实际上却负责调用所有注册了进程结束回调函数的代码。**__exit函数**内部则是实际的进程结束操作。 __cxa_finalize函数的源代码大体如下：

```
void __cxa_finalize(const void *dso)
{
    if (dso != NULL) {
        
        
        struct __cxa_range_t range;
        range.addr = dso;
        range.length = 1;
        __cxa_finalize_ranges(&range, 1);
    } else {
        __cxa_finalize_ranges(NULL, 0);
    }
}





void
__cxa_finalize_ranges(const struct __cxa_range_t ranges[], unsigned int count)
{
    struct atexit *p;
    struct atexit_fn *fn;
    int n;

    for (p = __atexit; p; p = p->next) {
        for (n = p->ind; --n >= 0;) {
            fn = &p->fns[n];

            if (fn->fn_type == ATEXIT_FN_EMPTY) {
                continue; 
            }

            
            int fn_type = fn->fn_type;
            fn->fn_type = ATEXIT_FN_EMPTY;

            
            if (fn_type == ATEXIT_FN_CXA) {
                fn->fn_ptr.cxa_func(fn->fn_arg);
            } else if (fn_type == ATEXIT_FN_STD) {
                fn->fn_ptr.std_func();
            } else if (fn_type == ATEXIT_FN_BLK) {
                fn->fn_ptr.block();
            }
        }
    }
}
```

三种进程结束回调函数中只有注册类型为C++的函数才带有一个参数，而其他两类函数都不带参数，这样的做的原因就是专门为调用全局C++对象的析构函数而服务的。

###### 异常退出和abort函数

如果进程正常退出，最终都会执行exit函数。exit函数内部会调用atexit函数注册的所有回调，以便有时间进行一些资源的回收工作。而如果我们的应用出现了异常而导致进程结束则并不会激发进程结束回调函数的调用，系统异常出现时会产生中断，操作系统会接管异常，并对异常进行分析，最后将分析的结果再交给用户进程，并执行用户进程的std::terminate方法来终止进程。std::terminate方法内部会调用通过NSSetUncaughtExceptionHandler函数注册的未处理异常回调函数，来给我们机会处理产生崩溃的异常，处理完成最后再结束进程。

我们也可以调用abort函数来终止进程的执行，abort函数的内部并不会调用atexit函数注册的所有回调，也就是说通过abort函数来终止进程时，并不会给我们机会来进行任何资源的回收处理，而是简单的在内部简单粗暴的调用__pthread_kill方法来杀死主线程，并终止进程。

通过上面对main函数执行前所做的事情，以及进程结束前我们能做的事情的介绍，您是否又对程序的启动时和结束时所发生的一切有了更加深入的理解。可是这似乎离我要说的C++全局对象的构造和析构更加遥远了，当然也许你不会这么认为，因为通过我上面的介绍，你也许对C++全局对象的构造和析构的时机有了一些想法，这些都没有关系，这也是我下面将要详细介绍的。

### 再论C++的全局对象的构造和析构

就如本文的开始部分的一个例子，对于非全局的C++对象的构造和析构函数的调用总是在调用者的函数内部完成，这时候存在着明显的函数上下文的调用结构。但是当我们定义了一个C++全局对象时因为没有明显的可执行代码的上下文，所以我们无法很清楚的了解到全局对象的构造函数和析构函数的调用时机。为了实现全局对象的构造函数和析构函数的调用，此时我们就需要编译器来出马帮助我们做一些事情了! 我们知道其实C++编译器会在我们的源代码的基础上增加非常多的隐式代码，对于每个定义的全局对象也是如此的。

当我们在某个.mm文件或者.cpp文件中定义了全局变量时比如下面某个文件的代码：

```
class CA
{
  public:
      CA();
       void ~CA();
};


#include "CA.h"

CA::CA()
{
    printf("CA::CA()\n");
}

void CA::~CA()
{
     printf("CA::~CA()\n");
}



#include "CA.h"



CA  a;
CA  b;
```

当编译器在编译MyTest.cpp文件时发现其中定义了全局C++对象，那么除了会将全局对象变量保存在数据段(.data)外，还会为每个全局变量定义一个静态的全局变量初始化函数。其命名的规则如下：

```
     static  ___cxx_global_var_init.<数字序列>();
```

同时会以定义全局变量的文件名为标志定义一个如下的静态函数：

```
  static  void _GLOBAL__sub_I_<文件名>(int argc, char **argv, char** env, char **apple, void * programVars);
```

因此当编译上面的MyTest.cpp文件时，其实最真实的文件的内容是如下的：

```
#include "CA.h"


struct CA  a;
struct CA  b;


static void ___cxx_global_var_init()
{
      CA::CA(&a);
       
     __cxa_atexit(&CA::~CA(), &a, NULL);
}


static void ___cxx_global_var_init.1()
{
      CA::CA(&b);
     __cxa_atexit(&CA::~CA(), &b, NULL);
}


static void _GLOBAL__sub_I_MyTest.cpp(int argc, char **argv, char** env, char **apple, void * programVars)
{
      ___cxx_global_var_init();
      ___cxx_global_var_init.1();
}
```

从上面的代码中我们可以看出每个全局对象的初始化函数都其实是做了两件事：

1. 调用对象类的构造函数。
2. 通过__cxa_atexit函数来注册进程结束时的析构回调函数。

前面我曾经说过__cxa_atexit这个函数并没有对外暴露，而是留给编译器以及内部使用，这个函数接收三个参数：一个函数指针，一个对象指针，一个库指针。我们知道所有C++类定义的函数其实都是有一个隐藏的this参数的，析构函数也一样。还记得上面的__cxa_finalize_ranges函数内部是如何调用注册的C++函数的吗？

```
fn->fn_ptr.cxa_func(fn->fn_arg);


__cxa_atexit(&CA::~CA(), &a, NULL);


CA::~CA(&a) 方法，也就是调用的是全局对象的析构函数！！
```

可以看出系统采用了一个非常巧妙的方法，借助__cxa_atexit函数来实现全局对象析构函数的调用。那么问题又来了？对象的构造函数又是再哪里调用的呢？换句话说**_GLOBAL__sub_I_MyTest.cpp()**这个函数又是在哪里被调用的呢？

这就需要我们去了解一下mach-o文件的结构了，关于mach-o文件结构的介绍这就不再赘述，大家可以到网上去参考阅读相关的文章。

可以明确的就是当我们定义了全局对象并生成了_GLOBAL__sub_I_XXX系列的函数时或者当我们的代码中存在着*attribute*(constructor)声明的C函数时，系统在编译过程中为了能在进程启动时调用这些函数来初始化全局对象，会在数据段__DATA下建立一个名为__mod_init_func的section，并把所有需要在程序启动时需要执行的初始化的函数的地址保存到__mod_init_func这个section中。 我们可以从下面mach-o view这个工具中看到我们所有的注册的信息。

您是否还记得前面介绍的main函数执行前所执行的代码流程，在那些代码中，有一个名叫**ImageLoaderMachO::doModInitFunctions**的函数就是专门用来负责执行__DATA下的__mod_init_func中注册的所有函数的，我们可以来看看这段代码的实现：

```
void ImageLoaderMachO::doModInitFunctions(const LinkContext& context)
{
    if ( fHasInitializers ) {
        const uint32_t cmd_count = ((macho_header*)fMachOData)->ncmds;
        const struct load_command* const cmds = (struct load_command*)&fMachOData[sizeof(macho_header)];
        const struct load_command* cmd = cmds;
        for (uint32_t i = 0; i < cmd_count; ++i) {
            if ( cmd->cmd == LC_SEGMENT_COMMAND ) {
                const struct macho_segment_command* seg = (struct macho_segment_command*)cmd;
                const struct macho_section* const sectionsStart = (struct macho_section*)((char*)seg + sizeof(struct macho_segment_command));
                const struct macho_section* const sectionsEnd = &sectionsStart[seg->nsects];
                for (const struct macho_section* sect=sectionsStart; sect < sectionsEnd; ++sect) {
                    const uint8_t type = sect->flags & SECTION_TYPE;
                    if ( type == S_MOD_INIT_FUNC_POINTERS ) {
                        Initializer* inits = (Initializer*)(sect->addr + fSlide);
                        const uint32_t count = sect->size / sizeof(uintptr_t);
                        for (uint32_t i=0; i < count; ++i) {
                            Initializer func = inits[i];
                            if ( context.verboseInit )
                                dyld::log("dyld: calling initializer function %p in %s\n", func, this->getPath());
                            
                            func(context.argc, context.argv, context.envp, context.apple, &context.programVars);
                        }
                    }
                }
                cmd = (const struct load_command*)(((char*)cmd)+cmd->cmdsize);
            }
        }
    }
}
```

因此可以看出上面定义的__GLOBAL__sub_I_MyTest.cpp函数就是在doModInitFunctions函数内部被执行。

从上面的macho-view展示的图表来看，全局对象的构造函数以及声明了_attribute_(constructor)的C函数都会记录在_*DATA_*,_mod_init_func这个section中并且会在doModInitFunctions函数内部被执行。那么对于一个声明了_attribute_(destructor)的C函数呢？它又是如何在进程结束前被执行的呢？答案就在_DATA_,_mod_term_func这个section中，系统在编译时会将所有带_attribute_(destructor)声明的函数地址记录到这个section中。还记得上面程序启动初始化时会有一个环节调用dyld::initializeMainExecutable函数吗？

```
void initializeMainExecutable()
{
    
    
    
    if ( gLibSystemHelpers != NULL ) 
        (*gLibSystemHelpers->cxa_atexit)(&runAllStaticTerminators, NULL, NULL);


    
    
}
```

可以清楚的看到里面又是用了cxa_atexit方法来注册了一个进程结束时的回调函数**runAllStaticTerminators**。继续来跟踪函数的实现：

```
  static void runAllStaticTerminators(void* extra)
 {
    try {
        const size_t imageCount = sImageFilesNeedingTermination.size();
        for(size_t i=imageCount; i > 0; --i){
            ImageLoader* image = sImageFilesNeedingTermination[i-1];
            
            image->doTermination(gLinkContext);
        }
        sImageFilesNeedingTermination.clear();
        notifyBatch(dyld_image_state_terminated, false);
    }
    catch (const char* msg) {
        halt(msg);
    }
 }
```

继续来看ImageLoaderMachO::doTermination的内部实现：

```
void ImageLoaderMachO::doTermination(const LinkContext& context)
{
    if ( fHasTerminators ) {
        const uint32_t cmd_count = ((macho_header*)fMachOData)->ncmds;
        const struct load_command* const cmds = (struct load_command*)&fMachOData[sizeof(macho_header)];
        const struct load_command* cmd = cmds;
        for (uint32_t i = 0; i < cmd_count; ++i) {
            if ( cmd->cmd == LC_SEGMENT_COMMAND ) {
                const struct macho_segment_command* seg = (struct macho_segment_command*)cmd;
                const struct macho_section* const sectionsStart = (struct macho_section*)((char*)seg + sizeof(struct macho_segment_command));
                const struct macho_section* const sectionsEnd = &sectionsStart[seg->nsects];
                for (const struct macho_section* sect=sectionsStart; sect < sectionsEnd; ++sect) {
                    const uint8_t type = sect->flags & SECTION_TYPE;

                    if ( type == S_MOD_TERM_FUNC_POINTERS ) {
                        
                        if ( (sect->addr < seg->vmaddr) || (sect->addr+sect->size > seg->vmaddr+seg->vmsize) || (sect->addr+sect->size < sect->addr) )
                            dyld::throwf("DOF section has malformed address range for %s\n", this->getPath());
                        Terminator* terms = (Terminator*)(sect->addr + fSlide);
                        const size_t count = sect->size / sizeof(uintptr_t);
                        for (size_t j=count; j > 0; --j) {
                            Terminator func = terms[j-1];
                            
                            if ( ! this->containsAddress((void*)func) ) {
                                dyld::throwf("termination function %p not in mapped image for %s\n", func, this->getPath());
                            }
                            if ( context.verboseInit )
                                dyld::log("dyld: calling termination function %p in %s\n", func, this->getPath());
                            func();  
                        }
                    }
                }
            }
            cmd = (const struct load_command*)(((char*)cmd)+cmd->cmdsize);
        }
    }
}
```

可见带有_attribute_(destructor)声明的函数，也是在系统初始化时通过了atexit的机制来实现进程结束时的调用的。

上面就是我要介绍的C++全局对象的构造函数和析构函数的调用以及实现的所有过程。我们从上面的章节中还可以了解到程序在启动和退出这个阶段所做的事情，以及我们所能做的事情。

最后还有一个问题需要解决：那就是我们知道所有的库的加载以及初始化操作都是通过dyld这个库来处理的。也就是一个进程在用户态最先运行的代码是dyld库中的代码，但是dyld库中本身也用到了一些全局的C++对象比如vector数组来存储所有的ImageLoaderMachO对象：

```
 static std::vector<ImageLoader*>   sAllImages;
static std::vector<ImageLoader*>    sImageRoots;
static std::vector<ImageLoader*>    sImageFilesNeedingTermination;
static std::vector<RegisteredDOF>   sImageFilesNeedingDOFUnregistration;
static std::vector<ImageCallback>   sAddImageCallbacks;
static std::vector<ImageCallback>   sRemoveImageCallbacks;
```

dyld要加载所有其他的库并且调用每个库的初始化函数来构造库内定义的全局C++对象，那么dyld库本身所定义的全局C++对象的构造函数又是如何被初始化的呢？很显然我们不可能在doModInitFunctions中进行初始化操作，而是必须要将初始化全局对象的逻辑放到加载其他库之前做处理。要想回答这个问题我们可以再次考察一下**dyldbootstrap::start**函数的实现：

```
uintptr_t start(const struct macho_header* appsMachHeader, int argc, const char* argv[], 
             intptr_t slide, const struct macho_header* dyldsMachHeader,
             uintptr_t* startGlue)
{
 
 
 if ( slide != 0 ) {
     rebaseDyld(dyldsMachHeader, slide);
 }

 
 mach_init();

 
 const char** envp = &argv[argc+1];
 
 
 const char** apple = envp;
 while(*apple != NULL) { ++apple; }
 ++apple;

 
 __guard_setup(apple);

#if DYLD_INITIALIZER_SUPPORT
 
     
 runDyldInitializers(dyldsMachHeader, slide, argc, argv, envp, apple);
#endif

 
    
 uintptr_t appsSlide = slideOfMainExecutable(appsMachHeader);
 return dyld::_main(appsMachHeader, appsSlide, argc, argv, envp, apple, startGlue);
}
```

start函数中在加载并初始化其他库之前有调用函数**runDyldInitializers**
下面的代码就是runDyldInitializers的实现，可以看出其他就是一个doModInitFunctions函数的简化版本的实现。

```
extern const Initializer  inits_start  __asm("section$start$__DATA$__mod_init_func");
extern const Initializer  inits_end    __asm("section$end$__DATA$__mod_init_func");







static void runDyldInitializers(const struct macho_header* mh, intptr_t slide, int argc, const char* argv[], const char* envp[], const char* apple[])
{
    for (const Initializer* p = &inits_start; p < &inits_end; ++p) {
        (*p)(argc, argv, envp, apple);
    }
}
```

> 小知识点：如果我们在编程时想要访问自身mach-o文件中的某个段下的某个section的数据结构时，我们就可以借助上面的汇编代码：__asm("section![start](https://math.jianshu.com/math?formula=start)__DATA$__mod_init_func"); 来获取section的开头和结束的地址区间。

###### 一个疑惑的地方

整个例子中我们定义了一个C++的类，还定义了beginfunc, endfunc函数，建立了全局对象，以及一个main函数。我们可以通过nm命令来看可执行程序所有导出的符号表：

```
nm /Users/apple/Library/Developer/Xcode/DerivedData/cpptest1-bwxlgbiudmjsyadeqbnivxsezipu/Build/Products/Debug/cpptest1 
0000000100001c80 t __GLOBAL__sub_I_MyTest.cpp
0000000100001000 T __Z7endfuncv
0000000100000fe0 T __Z9beginfuncv
0000000100001020 t __ZN2CAC1Ev
0000000100001060 t __ZN2CAC2Ev
0000000100001040 t __ZN2CAD1Ev
0000000100001bc0 t __ZN2CAD2Ev
0000000100001c00 t ___cxx_global_var_init
0000000100001c40 t ___cxx_global_var_init.2
00000001000020f0 S _a
00000001000020f1 S _b
0000000100000fb0 T _main
```

上面的符号表我删除了一些其他的符号，在这里可以看到大写T标志的函数是非静态全局函数，小写t标志的函数是静态函数，S标志的符号是全局变量。可以看出程序为了支持C++的全局对象并初始化需要定义一些附加的函数来完成。这里有一个让人疑惑的地方就是:

```
0000000100001020 t __ZN2CAC1Ev
0000000100001060 t __ZN2CAC2Ev
0000000100001040 t __ZN2CAD1Ev
0000000100001bc0 t __ZN2CAD2Ev
```

这里面定义了2个CA类的构造函数和析构函数，差别只是序号的不同。根据汇编代码转化为高级语言伪代码如下：

```
static void __ZN2CAC1Ev(CA * const this)
{
      __ZN2CAC2Ev(this);
}


static void __ZN2CAC2Ev(CA *const this)
{
     printf("CA::CA()\n");
}


static void __ZN2CAD1Ev(CA * const this)
{
      __ZN2CAD2Ev(this);
}


static void __ZN2CAD2Ev(CA *const this)
{
     printf("CA::~CA()\n");
}

static void ___cxx_global_var_init()
{
      __ZN2CAC1Ev(&a);
     __cxa_atexit(& __ZN2CAD1Ev, &a, NULL);
}
```

上面的代码中可以看出，系统在编译时分别实现了2个构造函数和析构函数，而且标号为1的函数内部其实只是简单的调用了标号为2的真实函数的实现。**所以当我们在调试或者查看崩溃日志时，如果问题出现在了全局对象的构造函数或者析构函数内部，我们看到的函数调用栈里面会出现两个相同的函数名字**

这个实现机制非常令我迷惑！希望有高手为我答疑解惑。

### 后记：崩溃的修复方法

最后我想再来说说那个崩溃事件，本质的原因还是对于全局对象的使用不当导致，当进程将要被杀死时，主线程执行了exit方法的调用，exit方法内部析构了所有定义的全局C++对象，并且当主线程在执行在全局对象的析构函数时，如果我们的应用中还有其他的常驻线程还在运行时，此时那些线程还并没有销毁或者杀死，也就是一个进程的所有其他线程的终止处理其实是发生在exit函数调用结束后才会发生的，因此如果一个常驻线程一直在访问一个全局对象时就有可能存在着隐患以及不确定性。一个解决的方法就是在全局对象析构函数调用前先终止所有其他的线程；另外一个解决方案是对全局对象的访问进行加锁处理以及进行是否为空的判断处理。我们使用的那个第三方库所采用的一个解决方案是在程序启动后通过调用atexit函数来注册了一个进程结束回调函数，然后再那个回调函数里面终止了所有工作线程。因为按照atexit后进先出的规则，我们手动注册的进程结束回调函数要比C++析构的进程结束回调函数后添加，所以工作线程的终止逻辑回调函数就会比析构函数调用要早，从而可以防止问题的发生了。

------

**欢迎大家访问我的github地址和简书地址**