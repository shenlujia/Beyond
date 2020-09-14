# 探究iOS线程调用栈及符号化

### 概念

**调用栈**，也称为执行栈、控制栈、运行时栈与机器栈，是计算机科学中存储运行子程序的重要的数据结构，主要存放返回地址、本地变量、参数及环境传递，用于跟踪每个活动的子例程在完成执行后应该返回控制的点。

![img](https://cocoachina.oss-cn-beijing.aliyuncs.com/article/202007202059454742)

一个线程的调用栈如上图所示，它分为若干栈帧(`frame`)，每个栈帧对应一个函数调用，如蓝色部分是`DrawSquare`函数的栈帧，它在运行过程中调用了`DrawLine`函数，栈帧为绿色部分表示。栈帧主要包含三部分组成函数参数、返回地址、帧内的本地变量，如上图中的函数`DrawLine`调用时首先把函数参数入栈，然后把返回地址入栈(表示当前函数执行完后上一栈帧的帧指针)，最后是函数内部本地变量(包含函数执行完后继续执行的程序地址)。

大部分操作系统栈的增长方向都是从上往下(包括iOS)，`Stack Pointer`指向栈顶部，`Frame Pointer`指向上一栈帧的`Stack Pointer`值，通过`Frame Pointer`就可以递归回溯获取整个调用栈。

作为一个开发者，有一个学习的氛围跟一个交流圈子特别重要，这是一个我的iOS交流群：[413038000](https://jq.qq.com/?_wv=1027&k=5rQ90tC)，不管你是大牛还是小白都欢迎入驻 ，分享BAT,阿里面试题、面试经验，讨论技术， 大家一起交流学习成长！

### ARM调用栈

首先ARM架构(64位arm64指令集)下的用于调用栈的各个寄存器，如下：

![img](https://cocoachina.oss-cn-beijing.aliyuncs.com/article/202007202059571567)



### 典型的栈帧如下图所示：

![img](https://cocoachina.oss-cn-beijing.aliyuncs.com/article/202007202100103376)

`main stack frame`为调用函数的栈帧，`func1 stack frame`为当前函数(被调用者)的栈帧，栈底在高地址，栈向下增长。图中`FP`就是栈基址，它指向函数的栈帧起始地址；`SP`则是函数的栈指针，它指向栈顶的位置。ARM压栈的顺序很是规矩，依次为当前函数指针`PC`、返回指针`LR`、栈指针`SP`、栈基址`FP`、传入参数个数及指针、本地变量和临时变量。如果函数准备调用另一个函数，跳转之前临时变量区先要保存另一个函数的参数。

上图的调用栈对应的汇编代码如下。

1. 8514行将当前的`sp`保存在`ip`中(`ip`只是个通用寄存器，用来在函数间分析和调用时暂存数据,通常为`r12`);
2. 8518行将4个寄存器从右向左依次压栈。
3. 851c行将保存的`ip`减4，得到当前被调用函数的`fp`地址，即指向栈里的`pc`位置。
4. 8520行将`sp`减8，为栈空间开辟出8个字节的大小，用于存放局部便令。

```
00008514 <func1>:
     8514:   e1a0c00d    mov ip, sp
     8518:   e92dd800    push    {fp, ip, lr, pc}
     851c:   e24cb004    sub fp, ip, #4
     8520:   e24dd008    sub sp, sp, #8
     8524:   e3a03000    mov r3, #0
     8528:   e50b3010    str r3, [fp, #-16]
     852c:   e30805dc    movw    r0, #34268  ; 0x85dc
     8530:   e3400000    movt    r0, #0
     8534:   ebffff9d    bl  83b0 <puts@plt>
     8538:   e51b3010    ldr r3, [fp, #-16]
     853c:   e12fff33    blx r3
     8540:   e3a03000    mov r3, #0
     8544:   e1a00003    mov r0, r3
     8548:   e24bd00c    sub sp, fp, #12
     854c:   e89da800    ldm sp, {fp, sp, pc}
```

我们可以根据`FP`和`SP`寄存器回溯函数调用过程，以上图为例：函数func1的栈中保存了main函数的栈信息（绿色部分的`SP`和`FP`），通过这两个值，我们可以知道main函数的栈起始地址（也就是`FP`寄存器的值）， 以及栈顶（也就是`SP`寄存器的值）。得到了main函数的栈帧，就很容易从里面提取`LR`寄存器的值了（`FP`向下偏移4个字节即为`LR`），也就知道了谁调用了main函数。以此类推，可以得到一个完整的函数调用链（一般回溯到 main函数或者线程入口函数就没必要继续了）。实际上，回溯过程中我们并不需要知道栈顶`SP`，只要`FP`就够了。

实例代码如下：

```
#include <stdio.h>
int add(int a, int b){
    return a + b;
}

int main(){
    int a = 10;
    int b = 20;
    int c = add(a, b);
    printf("add ret:%d 
", c);

    return 0;
}
```

通过`xcrun`指定`sdk`并`clang`编译指定编译架构`-arch`，结果如下：

> // -arch 表示要编译的架构 包括armv7 armv7s arm64 // -isysroot 指定头文件的根路径 $ clang -S **-arch armv64** -o hello hello.c –isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS12.4.sdk
>
> //也可以使用xcrun，xcrun -sdk 会使用最新的sdk去编译 $ xcrun -sdk iphoneos clang -S **-arch armv64** -o hello hello.c

![img](https://cocoachina.oss-cn-beijing.aliyuncs.com/article/202007202100326671)

### 线程栈

每个线程都有自己的线程栈来保存线程的执行调用情况，通过上述调用栈寄存器`SP`和`FP`可以确定栈信息，具体如何获取到线程的栈信息呢？

`NSThread`提供了`[NSThread callstackSymbols]`来获取当前线程的调用栈，也可以通过`backtrace/backtrace_symbols`接口获取，但只能获取当前线程的调用栈，无法获取其他线程的调用栈。所幸`Mach`内核提供了获取线程上下文的接口`thread_get_state`以及获取所有线程`task_threads`，具体定义如下：

```
kern_return_t thread_get_state
(
    thread_act_t target_act,
    thread_state_flavor_t flavor,
    thread_state_t old_state,
    mach_msg_type_number_t *old_stateCnt
);

#if defined(__x86_64__)
    _STRUCT_MCONTEXT ctx;
    mach_msg_type_number_t count = x86_THREAD_STATE64_COUNT;
    thread_get_state(thread, x86_THREAD_STATE64, (thread_state_t)&ctx.__ss, &count);

    uint64_t pc = ctx.__ss.__rip;
    uint64_t sp = ctx.__ss.__rsp;
    uint64_t fp = ctx.__ss.__rbp;
#elif defined(__arm64__)
    _STRUCT_MCONTEXT ctx;
    mach_msg_type_number_t count = ARM_THREAD_STATE64_COUNT;
    thread_get_state(thread, ARM_THREAD_STATE64, (thread_state_t)&ctx.__ss, &count);

    uint64_t pc = ctx.__ss.__pc;
    uint64_t sp = ctx.__ss.__sp;
    uint64_t fp = ctx.__ss.__fp;
#endif

//task_threads 将 target_task 任务中的所有线程保存在 act_list 数组中，数组中包含 act_listCnt 个线程，这里使用mach_task_self()获取当前进程标记 target_task
kern_return_t task_threads
(
    task_inspect_t target_task,
    thread_act_array_t *act_list,
    mach_msg_type_number_t *act_listCnt
);
```

通过 `act_list` 数组可以读取该任务的所有线程，获取线程之后，对于每一个线程，可以用 `thread_get_state` 方法获取它的所有信息，信息填充在 `_STRUCT_MCONTEXT` 类型的参数中。这个方法中有两个参数随着 CPU 架构的不同而改变，因此需要注意不同 CPU 之间的区别。在 `_STRUCT_MCONTEXT` 类型的结构体中，存储了当前线程的 `Stack Pointer` 和最顶部栈帧的 `Frame Pointer`，从而获取到了整个线程的调用栈。

> 注意：任务与进程的概念是一一对应的，即iOS系统进程(对应应用)都在底层关联了一个`Mach`任务对象，因此可以通过`mach_task_self()`来获取当前进程对应的任务对象；
>
> 这里的线程为最底层的`mach`内核线程，`posix`接口中的线程`pthread`与内核线程一一对应，是内核线程的抽象，`NSThread`线程是对`pthread`的面向对象的封装。

对于函数调用过程中可能存在着异常情况导致栈帧损坏，因此当前现成的栈帧地址在不被允许访问的地址空间，若直接通过`thread_get_state`获取线程栈帧而获取整个调用栈，存在指针访问错误，导致程序异常崩溃。可使用`vm_red_overwrite`函数来安全获取线程调用栈，该函数会询问内核是否有权限访问指定的内存，避免指针访问异常。具体的函数使用如下：

```
typedef struct StackFrameEntry{
    const struct StackFrameEntry * const previous;//前一个栈帧地址
    const uintptr_t return_address;//函数地址
} StackFrameEntry;

//mach_task_self：task对象
//src：fp栈帧指针
//numBytes：sizeof（StackFrameEntry）
//dst：StackFrameEntry指针
//bytesCopied：//cpye字节大小
kern_return_t vm_read_overwrite(mach_task_self(), (vm_address_t)src, (vm_size_t)numBytes, (vm_address_t)dst, &bytesCopied)
```

**获取线程名称**

每个内核线程由`thread_t`类型的`id`来唯一标识，`phread`的唯一标识类型为`pthread_t`，`thread_t`与`pthread_t`转换相对容易，但`NSThread`没有存储`pthread_t`的标识，不过`NSThread`能够获取线程名称，而`pthread`接口提供了`pthread_getname_np`来获取线程名称，两者名称是一致的，其中`np`是指`not posix`(不是跨平台接口)。但是主线程无法通过`pthread_getname_np`获取名称，所以需要在`load`方法里获取线程的`thread_t`；

```
//具体的thread_t与pthread_t相互转换接口
pthread_t pthread = pthread_from_mach_thread_np((thread_t)thread);

//获取主线程的thread_t
static mach_port_t main_thread_id;
+ (void)load {
    main_thread_id = mach_thread_self();
}
```

### 函数符号化

获取所有线程的调用栈地址后，如何将函数地址进行符号化进而转化为可读信息，便于排查定位问题。

#### 定位Image

![img](https://cocoachina.oss-cn-beijing.aliyuncs.com/article/202007202101093035)

对于应用会存在多个`Image`镜像文件(如上图所示)，且镜像会映射到唯一的地址段，因此获取的调用栈函数地址就可以确定所属的`Image`，具体获取镜像相关的信息包括镜像数量、镜像名称、镜像`Mach-O`头部信息及偏移等信息，可通过`dyld`提供的相关接口获取，如下：

```
uint64_t count = _dyld_image_count();//image数量
const struct mach_header *header = _dyld_get_image_header(index);//image mach-o header
const char *name = _dyld_get_image_name(index);//image name
uint64_t slide = _dyld_get_image_vmaddr_slide(index);//ALSR偏移地址
```

通过遍历获取`Image Mach-O Header`头部信息及其加载命令来获取所属的地址空间范围来判断是否位于当前`Image`(Mach-O相关的知识点可见[探究Mach-O文件](https://juejin.im/post/5f113c05f265da22bb7b384d))，具体的代码逻辑如下：

```
static uint32_t imageIndexContainingAddress(const uintptr_t address)
{
    const uint32_t imageCount = _dyld_image_count();
    const struct mach_header* header = 0;

    for(uint32_t iImg = 0; iImg < imageCount; iImg++)
    {
        header = _dyld_get_image_header(iImg);
        if(header != NULL)
        {
            // Look for a segment command with this address within its range.
            uintptr_t addressWSlide = address - (uintptr_t)_dyld_get_image_vmaddr_slide(iImg);
            uintptr_t cmdPtr = firstCmdAfterHeader(header);
            if(cmdPtr == 0)
            {
                continue;
            }
            for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++)
            {
                const struct load_command* loadCmd = (struct load_command*)cmdPtr;
                if(loadCmd->cmd == LC_SEGMENT)
                {
                    const struct segment_command* segCmd = (struct segment_command*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize)
                    {
                        return iImg;
                    }
                }
                else if(loadCmd->cmd == LC_SEGMENT_64)
                {
                    const struct segment_command_64* segCmd = (struct segment_command_64*)cmdPtr;
                    if(addressWSlide >= segCmd->vmaddr &&
                       addressWSlide < segCmd->vmaddr + segCmd->vmsize)
                    {
                        return iImg;
                    }
                }
                cmdPtr += loadCmd->cmdsize;
            }
        }
    }
    return UINT_MAX;
}
```

#### 查找符号

符号表储存在 Mach-O 文件的 `LC_SEGMENT(__LINKEDIT)` 段中，涉及其中的符号表`（Symbol Table）`和字符串表`（String Table）`。符号表在 Mach-O目标文件中的地址可以通过`LC_SYMTAB`加载命令指定的 `symoff`找到，对应的符号名称在`stroff`，总共有`nsyms`条符号信息；也就是说，通过`LC_SYMTAB`来找存储在`__LINKEDIT`中的符号地址地址。

符号表是一个连续的列表，其中每一项都是`struct nlist`，如下：

```
truct nlist {
  union {
    uint32_t n_strx;//符号名在字符串表中的偏移量
  } n_un;
  uint8_t n_type;
  uint8_t n_sect;
  int16_t n_desc;
  uint32_t n_value;//符号在内存中的地址，类似于函数指针
};
复制代码复制代码
```

通过符号表项中的`n_un.n_strx`来获取符号名在字符串表`String Table`中的偏移量，进而获取符号名即函数名；通过`n_value`来获取符号在内存中的地址，即函数指针；因此就清楚了符号名和内存地址之间的对应关系。具体的获取符号表及字符串表的代码如下：

```
//获取Mach-O Header
const struct mach_header* header = _dyld_get_image_header(index);
//通过header遍历Load Commands获取_LINKEDIT 及 LC_SYMTAB
for(uint32_t iCmd = 0; iCmd < header->ncmds; iCmd++)
{
        const struct load_command* loadCmd = (struct load_command*)cmdPtr;
    if(loadCmd->cmd == LC_SYMTAB){
      symtabCmd = loadCmd;
    } else if(loadCmd->cmd == LC_SEGMENT_64) {
        const struct segment_command_64* segmentCmd = (struct segment_command_64*)cmdPtr;
        if(strcmp(segmentCmd->segname, SEG_LINKEDIT) == 0)
        {
            linkeditSegment = segmentCmd;
        }
    }
}

//基址 = 偏移量 + _LINKEDIT段虚拟地址 - _LINKEDIT段文件偏移地址
uintptr_t linkeditBase = (uintptr_t)slide + linkeditSegment->vmaddr - linkeditSegment->fileoff;
//符号表的地址 = 基址 + 符号表偏移量 
const nlist_t *symbolTable = (nlist_t *)(linkeditBase + symtabCmd->symoff);
//字符串表的地址 = 基址 + 字符串表偏移量 
char *stringTab = (char *)(linkeditBase + symtabCmd->stroff);
//符号数量
uint32_t symNum = symtabCmd->nsyms;
复制代码复制代码
```

#### 定位符号

上述查找符号是获取的真正的符号内存地址和函数名，而通过函数调用栈获取的是函数内部执行指令的地址，不过该地址与真正的函数地址偏离不大，因此可以通过遍历符号的内存地址与调用栈函数地址比较得到离符号内存地址最近的最佳匹配符号，即是当前调用栈的符号，具体代码如下：

```
const uintptr_t imageVMAddrSlide = (uintptr_t)_dyld_get_image_vmaddr_slide(idx);
const uintptr_t addressWithSlide = address - imageVMAddrSlide;//address为调用栈内存地址
//遍历符号需找最佳匹配符号
for(uint32_t iSym = 0; iSym < symtabCmd->nsyms; iSym++)
{
    // If n_value is 0, the symbol refers to an external object.
    if(symbolTable[iSym].n_value != 0)
    {
        uintptr_t symbolBase = symbolTable[iSym].n_value;//获取符号的内存地址(函数指针)
        uintptr_t currentDistance = addressWithSlide - symbolBase;
        if((addressWithSlide >= symbolBase) &&
        (currentDistance <= bestDistance))
        {
            bestMatch = symbolTable + iSym;//最佳匹配符号地址
            bestDistance = currentDistance;//调用栈内存地址与当前符号内存地址距离
        }
    }
}

if(bestMatch != NULL)
{
    info->dli_saddr = (void*)(bestMatch->n_value + imageVMAddrSlide);
    if(bestMatch->n_desc == 16)
    {
        // This image has been stripped. The name is meaningless, and
        // almost certainly resolves to "_mh_execute_header"
        info->dli_sname = NULL;
    }
    else
    {
        //获取符号名
        info->dli_sname = (char*)((intptr_t)stringTable + (intptr_t)bestMatch->n_un.n_strx);
        if(*info->dli_sname == '_')
        {
            info->dli_sname++;
        }
    }
}
复制代码复制代码
```

### Reference

[关于函数调用栈(call stack)的个人理解](https://blog.csdn.net/VarusK/article/details/83031643)

[调用栈](https://zh.wikipedia.org/wiki/呼叫堆疊)

[获取任意一个线程的Call Stack](https://blog.csdn.net/jasonblog/article/details/49909163)

[iOS获取任意线程调用栈](https://juejin.im/post/5d81fac66fb9a06af7126a44)

[谈谈iOS获取调用链](https://juejin.im/post/5c3c56eff265da614f708595)

[运行时获取函数调用栈](http://djs66256.github.io/2018/01/21/2018-01-21-运行时获取函数调用栈/)

[线程 Call Stack 的捕获和解析](https://juejin.im/entry/5d38183d518825534f635700)

[iOS 之 Thread调用栈学习](https://elliotsomething.github.io/2017/06/28/thread学习/)

[C语言在ARM中函数调用时，栈是如何变化的？](https://cloud.tencent.com/developer/article/1593645)

[iOS 逆向之ARM汇编](https://www.cnblogs.com/csutanyu/p/3575297.html)

[ARM64指令简易手册](https://www.jianshu.com/p/b9301d02a125)

[iOS汇编快速入门](https://juejin.im/entry/5cf4b4256fb9a07ec955f7fa)

[thread_get_state](https://developer.apple.com/documentation/kernel/1418576-thread_get_state?language=objc)

[pthread.c](https://opensource.apple.com/source/Libc/Libc-498/pthreads/pthread.c)

[《深入解析Mac OSX & iOS操作系统》](https://juejin.im/post/5f129d65e51d4534b44621e4)

[vm_read_overwrite](http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/vm_read.html)

[KSCrash](https://github.com/kstenerud/KSCrash.git)