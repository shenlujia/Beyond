- 应用崩溃是影响 APP 体验的重要一环， 而崩溃定位也常常让开发者头疼。本文就讲讲关于 Crash 分析的那些事。

  

  

  

  ## **Crash 日志的渠道**

  ------

  

  Crash 日志从哪来？一般有 2 个渠道:

  

  - **苹果收集的 Crash 日志**

  - - 用户手机上 设置 -> 隐私 -> 分析 里面的，可以连接电脑 Xcode 导出。
    - 在 Xcode -> Window -> Organizer -> Crashes 里面可以查看

  - **自己应用内收集的**

  - - 接入一些 APM 产品， 如 EMAS、mPaaS、phabricator 等。
    - 接入 PLCrashReporter 、 KSCrash 等 SDK 进行收集，上报到自建平台统计

  

  两者各有利弊，但是二者的捕获原理是差不多的。

  

  - **苹果的日志**

  - - 优点: 理论上捕获类型最全，因为是 launchd 进程捕获的日志。
    - 缺点：不是全量日志，因为需要用户隐私授权才会上报，没有数据化支撑。

  - **自己收集的**

  - - 优点：可以自建数据化支撑，获取 Crash 率等指标。
    - 缺点：存在无法捕获的 Crash 的类型。

  ##  

  ## **Crash 捕获的原理**

  ------

  

  要了解 Crash 捕获的原理，要先清楚几个基本概念，和它们之间的关系：

  

  - **软件异常** 

  - - 软件异常主要来源于两个 API 的调用 kill() 、 pthread_kill() , 而 iOS 中我们常常遇到的 NSException 未捕获、 abort()  函数调用等，都属于这种情况。比如我们常看到 Crash 堆栈中有 pthead_kill 方法的调用。

  - **硬件异常**

  - - 硬件产生的信号始于处理器 trap，处理器 trap 是平台相关的。比如我们遇到的野指针崩溃大部分是硬件异常。

  - **Mach异常**

  - - 这里虽然叫异常，但是要和上面的两种分开来看。我们了解到苹果的内核 xnu 的核心是 Mach , 在 Mach 之上建立了 BSD 层。“Mach异常” 是 “Mach异常处理流程” 的简称。

  - **UNIX信号**

  - - 这就是我们常说的信号了，如 SIGBUS  SIGSEGV SIGABRT SIGKILL 等。

  ![1.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUvvot8UbWXyVOHubK95PicovVJpicIwiaxWbJic23EEpyJJOqpBvay3S8hw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  **软件产生的信号**的处理流程如下图， 就是用户态的 “UNIX信号” 处理流程

  

  

  ![2.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUv1ZXDq8dxonCnaD6Wicz5icibyErZica9Jjc1gctNJ15Eb9KMPQ0usCnyg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  

  **硬件产生的信号**的处理流程如下图：硬件错误被 Mach 层捕获，然后转换为对应的 “UNIX信号”。为了维护一个统一的机制，操作系统和用户产生的信号首先被转换为 "Mach异常"，然后再转换为信号。如下图所示:

  
  ![3.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUldu9AG0vwZCNXK1TuNnLUS8ldR6FJ0CvriaiaLNetDKBzAZXFNkkvJwQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  上面两图来自 **“深入解析 Mac OS X & iOS 操作系统”**一书。

  

  由上图可以看到，无论是硬件产生的信号，还是软件产生的信号，都会走到 act_set_astbsd() 进而唤醒收到信号的进程的某一个线程。这个机制就给我们在“自身进程内捕获 Crash” 提供了可能性。就是可以通过拦截 “UNIX信号” 或 “Mach异常” 来捕获崩溃。

  

  而且这里还有个小知识，当我们拦截信号处理之后是可以让程序不崩溃而继续运行的，但是不建议这样做，因为程序已经处于异常不可知状态。

  

  PLCrashReporter  和 KSCrash 两个开源库都提供了 2 种方式拦截异常，包括 “Mach异常拦截” 和 “UNIX信号拦截”。说到这里有人可能困惑了，看上图里面最终都会转换为 “UNIX信号”， 是不是代表我们只用监听 “UNIX 信号” 就够了呢？**为什么还要拦截 Mach 异常呢？**

  

  有两个原因：

  - 不是所有的 "Mach异常” 类型都映射到了 “UNIX信号”。 如 EXC_GUARD 。在苹果开源的 xnu 源码中可以看到这点。
  - “UNIX信号” 在崩溃线程回调，如果遇到 Stackoverflow 问题，已经没有条件(栈空间)再执行回调代码了。

  那么，是不是我们只拦截 “Mach异常” 就够了呢？也不是，用户态的软件异常是直接走信号流程的，如果不拦截信号可能导致这部分 Crash 丢失。

  

  附 “Mach异常” 与 “UNIX信号” 的转换关系代码，来自 xnu 中的 bsd/uxkern/ux_exception.c ：

  

  ```
  switch(exception) {case EXC_BAD_ACCESS:    if (code == KERN_INVALID_ADDRESS)        *ux_signal = SIGSEGV;    else        *ux_signal = SIGBUS;    break;
  case EXC_BAD_INSTRUCTION:    *ux_signal = SIGILL;    break;
  case EXC_ARITHMETIC:    *ux_signal = SIGFPE;    break;
  case EXC_EMULATION:    *ux_signal = SIGEMT;    break;
  case EXC_SOFTWARE:    switch (code) {
      case EXC_UNIX_BAD_SYSCALL:    *ux_signal = SIGSYS;    break;    case EXC_UNIX_BAD_PIPE:    *ux_signal = SIGPIPE;    break;    case EXC_UNIX_ABORT:    *ux_signal = SIGABRT;    break;    case EXC_SOFT_SIGNAL:    *ux_signal = SIGKILL;    break;    }    break;
  case EXC_BREAKPOINT:    *ux_signal = SIGTRAP;    break;}
  ```

  

  看到这里，有同学可能会说，还有 NSException 呢？我们都用 NSUncaughtExceptionHandler 来捕获异常 Crash 的。在前面就将 c++/ObjC 异常归类到了“软件异常” 类型，那是不是“捕获信号”就行了呢？为什么还要注册 NSUncaughtExceptionHandler 呢？是因为 CrashReporter 需要通过这个 handler 来获取异常相关信息和堆栈。

  

  ![4.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosU5yoPWtZuQ5zWJGWtCsOq075sQvNPN9LGmlC1keRU6DPOtzLuBrBn7Q/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  ##  

  ## **看懂 Crash 日志**

  ------

  

  我们这里说的 Crash 日志，是指 Apple Format 格式的 全堆栈 Crash 日志。

  ###  

  #### **▐**  **Crash 头部信息**

  - **Incident Identifier:** 每个 Crash 生成的唯一的 uuid.
  - **CrashReporter Key:** CrashReporter 的 uuid, 如果自己捕获日志，这个可以忽略。
  - **Hardware Model:** 机型
  - **Process:** 进程名和进程ID
  - **Path:** 进程的可执行文件路径
  - **Identifier:** Info.plist 中配置的 CFBundleIdentifier 值
  - **Version:** CFBundleVersion (CFBundleVersionShort) 即应用的Build号+版本号
  - **Code Type:** 机型的 CPU 架构，但是不是详细的架构名。比如 arm64e 在这里也是 ARM-64
  - **Parent Process:** 父进程和进程ID
  - **Data/Time:** Crash发生的具体时间。
  - **Launch Time：** 进程启动时间
  - **OS Version:** iOS 系统版本和 build号
  - Report Version: Crash日志格式的版本号，一般是 104。如果这个version偏高，用系统的symbolicatecrash命令不能符号化日志，一般如果看到是204， 改成104之后用symbolicatecrash就可以符号化了

  ###  

  ### **Crash 异常码**

  ------

  

  在 Crash 头部信息之下, 会有个段记录了 Crash 异常码。类似下图：

  
  ![5.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUgZ5kl7g3UyXoNGKW8rKdhqBG1rDCgSpMnAVLsC5a28NZGv1Vo05zjg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  

  这里我们应该关注：

  - **Exception Type:** 异常码，一般格式是 Mach异常码 ( UNIX 信号类型 )
  - **Exception Subtype:** 一般情况里面带的是 Mach异常的 subcode, 还有 Crash 相关地址信息。
  - **Triggered by Thread:** 发生Crash的线程，大部分情况到这个线程的堆栈里面去看 Crash 堆栈。
  - **Application Specific Information:** 如果是 Objc/c++ Exception 异常，这里是异常的信息，这个是定位异常的关键信息
  - **Last Exception Backtrace:** 抛出异常的代码堆栈, 如果是 Objc/c++ Exception 异常造成的 Crash，就看这个堆栈，Crashed Thread: 里的堆栈是 abort()，没有意义。

  

  附异常码的解释, 非所有异常码，只是我们 Crash 中可能会看到的 :

  

  | Mach 异常                                                    | UNIX 信号 | 简介                               | 案例                                                         |
  | ------------------------------------------------------------ | --------- | ---------------------------------- | ------------------------------------------------------------ |
  | EXC_BAD_ACCESS                                               | SIGBUS    | 总线错误                           | 1、内存地址对齐出错 2、试图执行没有执行权限的代码地址        |
  |                                                              | SIGSEGV   | 段错误                             | 1、访问未申请的虚拟内存地址2、没有写权限的内存写入           |
  | EXC_BAD_INSTRUCTION                                          | SIGILL    | 非法指令，即机器码指令不正确       | 1, iOS 上偶现的问题，遇到之后用户会连续闪退，直到应用二进制的缓存重新加载 或重启手机。此问题挺影响体验，但是报给苹果不认，因为苹果那边没有收集到，目前没有太好办法。因为 iOS 应用内无法对一篇内存同时获取 w+x 权限的，因此应用无法造成此类问题，所以判断是苹果的问题。 |
  | EXC_ARITHMETIC                                               | SIGFPE    | 算术运算出错，比如除0错误          | iOS 默认是不启用的，所以我们一般不会遇到                     |
  | EXC_SOFTWARE (我们在 Crash 日志中一般不会看到这个类型，苹果的日志里会是 EXC_CRASH) | SIGSYS    | 系统调用异常                       | 无                                                           |
  |                                                              | SIGPIPE   | 管道破裂                           | 1, Socket通信是可能遇到，如读进程以及终止时，写进程继续写入数据。2, 根据苹果的文档，我们可以忽略这个信号: https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/CommonPitfalls/CommonPitfalls.html |
  |                                                              | SIGABRT   | abort() 发生的信号                 | 典型的软件信号，通过 pthread_kill() 发送                     |
  |                                                              | SIGKILL   | 9毫米子弹,大杀特杀。进程内无法拦截 | 1, exit(), kill(9) 等函数调用 2, iOS系统杀进程用的，比如 watchDog 杀进程 |
  | EXC_BREAKPOINT                                               | SIGTRAP   | 由断点指令或其它trap指令产生       | 部分系统框架里面会用 `__builtin_trap()` 来产生一个 SIGTRAP 类型的 Crash |
  | EXC_GUARD                                                    | 无        | 文件句柄错误                       | 试图 close 一个内核的 fd.                                    |
  | EXC_RESOURCE                                                 | 无        | 资源受限                           | 线程调度太频繁，子线程每秒被唤醒次数超过150: https://stackoverflow.com/questions/25848441/app-shutdown-with-exc-resource-wakeups-exception-on-ios-8-gm |

  ####  

  #### **▐**  **Crash 堆栈**

  

  下面一张图介绍了 Crash 堆栈中每个段的含义:

  
  ![6.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUQAiaqFSUVkLCE40whyxUWqNaOAb2Boc3GoW4Zjgq4JFYCwjGRfia0KKQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  ###  

  #### **▐**  **Thread State**

  

  Thread State 中记录了 Crash 线程的寄存器的值，对于一些问题的定位是有一定帮助的。

  

  ![7.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUydz6yXwXQkZcOJX2J1iaXgZbzkUD8ia8bxvAZ8wsvChNCcqe6BWKibb2g/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  

  比如通过 fp, sp 的值配合 异常码 中的地址判断是否是栈溢出问题。但是大部分情况下，这块内容可以提供的帮助都比较小，因为都是单纯的数值，而不是其代表的：意义。在这一点上， KSCrash 提供了分析功能, 可以对寄存器内值的意义进一步分析，比如分析是不是一个 ObjC 的对象，分析string的内容，可以帮助我们对Crash进一步分析，因为 Crash 现场如果能拿到更多的信息，对于定位 Crash 的帮助可能是很大的，这个功能是很赞的。

  

  一个简单的 Case: 当 ObjC 对象野指针时，调用它的任何方法都会 Crash， 而往往野指针问题不太容易快速定位野的对象是什么， 但是我们可以通过分析 x1 的值，也就是最后调用它的 @selector 再结合代码就很容易定位出野掉的对象是谁了。

  

  #### **▐**  **Binary Images**

  

  Binary Images 中记录了进程加载的所有镜像列表， 这块内容是符号化 Crash 日志的关键，符号化的原理就是通过这里的镜像 UUID 来找到对应镜像的符号化文件从而进行对堆栈的符号化工作的。

  ```
  镜像起始地址 镜像结束地址    0x1815b8000 - 0x181c73fff
  镜像名    libobjc.A.dylib     
  架构    arm64               
  镜像uuid    <5f420cdc6f593721a9cf0464bd87e1a2>                             
  镜像完整路径    /usr/lib/libobjc.A.dylib
  ```

  

  读这段内容在 Crash 定位时也是有帮助的，比如：

  - 我们可以根据是否有加载越狱的动态库来判断设备是否越狱
  - 有些越狱设备会更改 iOS 系统版本号，也可以通过 uuid 来判断是否是有此种行为。

  ##  

  ## **Crash 分析方法**

  ------

  

  在了解了上面基本知识后，我们已经具备一定的定位 Crash 的能力了。然而光有理论知识，也还要有实战工具。

  

  #### **▐**  **符号化**

  

  关于堆栈符号化的文章可以说是很多了，但是既然叫攻略，这里还是讲一下吧。

  

  - **Xcode 自动符号化**

  苹果收集的日志，Xcode会自动帮我们符号化，如果你没有发布包，比如是别人电脑打包的发布包，或者是一些平台上打的包，只需要你把 xcarchive  拷贝到 $HOME/Library/Developer/Xcode/Archives 目录下之后，Xcode 就可以自动帮你符号化了。

  

  - **手动符号化之 symbolicatecrash**

  Xcode 自带了一个命令行工具 symbolicatecrash , 在 /Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash , 这个工具可以帮助我们将整个 Crash 日志符号化：

  ```
  # 这两行可以写到 ~/.bash_profile 里面，这样不用每次敲了export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer/alias symbolicatecrash="/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/symbolicatecrash"
  # 执行符号化symbolicatecrash [原始CrashLog路径] [dSYM文件路径或待符号的.app路径] > [导出符号化的文件路径]
  ```

  

  使用 symbolicatecrash ，如果要符号化系统库的堆栈的话，需要有对应系统库的符号表放到 $HOME/Library/Developer/Xcode/iOS DeviceSupport 目录下面。符号表的获取可以通过插入对应系统版本的手机，或者从别人那拷贝获取。

  

  - **atos 单行符号化**

  

  在了解了 3.3 中的堆栈的信息后，我们也可以使用 atos 命令来对 单行或多行 的堆栈进行符号化操作。

  

  使用方法：

  ```
  atos -o [镜像的DWAF文件地址] -l [镜像的起始地址] [堆栈内存地址1] [堆栈内存地址2] ...
  ```

  

  #### **▐**  **汇编定位法**

  

  因为 iOS 上的 Native 代码都会被编译为机器码，且 Crash 堆栈中的很多信息其实是二进制上的内容，哪怕我们符号化了，但是经过编译器的翻译，有时候也无法通过符号化之后匹配到的代码行来定位最精确的原因。因为一行源代码可能包含很多逻辑而被编译为大段汇编，或者编译优化将多行代码合并优化等操作。

  

  所以，有时候 Crash 定位就需要我们进阶版的 汇编定位法 。当然要学习汇编定位法可能需要一定的基础知识，比如看懂一些基础的汇编指令，可以通过学习和练习来提高，推荐一下一篇旧文: https://blog.cnbluebox.com/blog/2017/07/24/arm64-start/

  

  汇编定位法，还需要一个反汇编的工具。

  

  - 推荐使用 Hopper Disassembler 工具，这是个收费工具
  - 将二进制文件拖进工具就可以了

  

  - 也可以用 mac 自带的 otool 命令
  - otool -tV 二进制文件

  

  - Xcode 本身自带汇编调试
  - Xcode -> Debug -> Debug Workflow -> Always Show Disassmbly

  

  Tips: 二进制就是我们工程编译的可执行文件、动态库。系统库的二进制可以在 $HOME/Library/Developer/Xcode/iOS DeviceSupport/ 中找到。dylib 在 Symbols/usr/lib 目录 ，动态库在 Symbols/System/Library/Frameworks 目录。

  

  工具准备好了之后，怎么定位到具体位置呢，还是回到 3.3 节中的图，“代码在镜像中的偏移” 我们就根据这个信息进行查找就可以找到对应的汇编行了。

  符号化的堆栈，无法直接看到“代码在镜像中的偏移”，我们可以自己减一下就行了。

  

  一个例子：

  

  - **Crash堆栈**

  ![8.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUmSAxn8s17ng1BibgS62qM5hG72007mklbvJeBrxONEvPj1NWLv4mbOA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  

  - **找到 VideoToolbox 的镜像起始地址**

  ![9.0ng.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUT1bDciafmibR5ujUatv9yh7N55aloWkickRFuufKPXmCC29MrVa9xDTibA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  

  - **找到 VideoToolbox 的镜像，拖到 Hopper**

  ![10.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUbn91ahak0U6LibKMI37ibcjf5P09YqZkwt22BB1PLLVaIib7HENjSjwjw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  

  - **算出“代码偏移”**

  因为 VideoToolbox 是系统库，放在 dyld_shared_cache 里面的，所以它镜像的文件地址也不是 0x0， 所以这里计算时候要加上 0x1848a2000, 我们自己打的动态库一般不存在这个。

  
  ![11.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUQfjbSYRpciabaCfPHllMJJWIYF2NlH9GLCzfCNIr7lsIXD4DhhpN5Hw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  

  - **找到对应的代码行**

  ![12.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUTlQJ2ibzzru3tsAYG3rHKMfxU6BiacgMBDibzIlFzgNVURj5KLNsAhD9Q/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  

  注意，这里 0x184900618 虽然是 orr 这一行，但其实是 0x184900614 这一行，因为这是 iOS 堆栈采集的原理所决定的（取lr)，除了 frame 0 的堆栈地址是最后崩溃的地址，frame 序号 大于0的地址都是实际地址的下一行。

  ###  

  #### **▐**  **现场勘探法**

  

  这是基于汇编法的基础上的一种分析方法。会了汇编分析之后，可能发现定位到了具体的汇编行，有时候问题还是较难分析，因为我们只拿到了代码信息，而运行时的各种状态都是丢失的。

  

  现场勘探法，就是我们使用 Xcode 调试应用，断点到 Crash 地方附近，哪怕是我们线下无法复现的 Crash， 我们也可以到现场去看下正常情况的 栈、寄存器是怎么样的，再对比 Crash 日志中的信息，就可以推断出哪里出了问题。

  

  打断点的方法：

  

  - **符号断点**
    ![13.png](https://mmbiz.qpic.cn/mmbiz_png/33P2FdAnju9fKnQW0x2LwG82YBOkoosUKicZ5XibQ6V97vZibScZP0pAfsEXHZN6DjNQCcjiaoIVahvGQLvpicrnaWA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

  - **地址断点**

  - - 通过 image list 读取加载的镜像，获取镜像的起始地址，然后就可以算出代码地址
    - 使用 br set -a 0x184900618 这样的指令来设置地址断点。

  ##  

  ##  

  ## **小结**

  ------

  

  本文主要从 Crash 日志渠道、Crash 捕获的原理、看懂 Crash 日志、Crash分析方法 等角度向大家普及下 Crash 原理及分析的思路。

  

  其中讲到的知识点有：Mach异常、UNIX信号、常见 Crash 错误码、Mach-O、汇编等。

  

  Crash 定位的过程是不断追溯 Crash 现场发生了什么的过程，通过对 Crash 日志的原理和内容的深入了解，可以帮助我们更快更好的定位应用崩溃问题。

  然而现实中可能还是会有些疑难的 Crash 不易定位，是因为 Crash 日志其实也并未保存了 Crash 现场最全的信息，更进一步的优化就是丰富 Crash 日志的信息，让我们获取更多的 Crash 现场信息， 比如 KSCrash 这个框架在这块做了一些努力。这些开源项目的代码是值得学习的。

  

  ##  

  ## 参考&引用&拓展阅读

  - 总线错误: https://zh.wikipedia.org/wiki/%E6%80%BB%E7%BA%BF%E9%94%99%E8%AF%AF
  - 书籍:《深入解析 Mach OS X & iOS 操作系统》
  - 崩溃捕获系统的原理: https://junyixie.github.io/2019/09/28/CrashMonitorSystem/
  - 分析iOS Crash文件: https://developer.aliyun.com/article/8854
  - iOS开发同学的arm64入门: https://blog.cnbluebox.com/blog/2017/07/24/arm64-start/
  - SIGSEGV 和 SIGBUS: https://www.cnblogs.com/charlesblc/p/6262783.html?spm=ata.13261165.0.0.26cd7529Cecpmj
  - iOS 调试进阶： https://zhuanlan.zhihu.com/c_142064221
  - KSCrash： https://github.com/kstenerud/KSCrash
  - PLCrashReporter: https://github.com/microsoft/plcrashreporter

