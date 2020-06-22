# 前言

我们在查看iOS应用内存时，最常见的手法就是查看左边的Debug Navigator。不知你是否也曾困惑于这个内存究竟包括哪些部分，或者使用Allocations模版观察内存时发现无法和Debug Navigator显示的内存匹配上，这篇文章将带你解答这些疑惑。





![img](https:////upload-images.jianshu.io/upload_images/2949750-a34ffd02bd4a7f2b.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/532)



# Debug Navigator VS Allocations

我们运行一个很简单的iOS App，我只在ViewController中放置了一个View，然后对比下Debug Navigator 和 Allocations给出的内存用量。





![img](https:////upload-images.jianshu.io/upload_images/2949750-98630f9811a7efce.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/554)







![img](https:////upload-images.jianshu.io/upload_images/2949750-8674b8c148892a24.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)



可以发现，Debug Navigator给出的是79.3M，而Allocations统计的所有堆和相关VM加起来才38.72M，相差的还是很多的。在之前的文章中我有介绍关于[Allocations](https://link.jianshu.com/?t=http%3A%2F%2Fwww.gltech.win%2Fios%E5%BC%80%E5%8F%91%2F2018%2F01%2F16%2F%E6%8E%A2%E7%B4%A2iOS%E5%86%85%E5%AD%98%E5%88%86%E9%85%8D.html)和[VM Tracker](https://link.jianshu.com/?t=http%3A%2F%2Fwww.gltech.win%2Fios%E5%BC%80%E5%8F%91%2F2018%2F01%2F23%2FiOS%E5%86%85%E5%AD%98%E6%B7%B1%E5%85%A5%E6%8E%A2%E7%B4%A2%E4%B9%8BVM-Tracker.html)的深入理解，其实Allocations中主要包含的是所有MALLOC_XXX VM Region和部分App进程创建的VM Region。非动态的内存，以及部分其他动态库创建的VM Region并不在Allocations的统计范围内。比如主程序或者动态库的_DATA数据段，这些数据内存区域并非通过malloc分配，也就没有统计在All Heap Allocations中，所以你会发现All Heap Allocations往往会比较小。除非你自行使用malloc系列方法创建大内存块，否则很难看到All Heap Allocations有一个大的数值。我们在实际的App中，大的内存占用一般都是类似于WebKit，ImageIO，CoreAnimation等虚拟内存区域（VM Region），这些VM Region一般由系统代码生成和管理，我们编写的代码如果间接引用了这些内存而没有释放，也就会造成大面积的内存泄漏。

# Debug Navigator VS VM Tracker

接下来我们来看看VM Tracker统计的内存如何，下面是截图。





![img](https:////upload-images.jianshu.io/upload_images/2949750-ea8517b29b102f98.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)



在看VM Tracker时，我们主要看Dirty Size和Swapped Size，由于我是在模拟器上调试的，所以才需要关注Swapped Size，在手机上，主进程的内存应该是不会交换到硬盘上的，内存不足时，会触发内存警告。Dirty Size主要指的是不可被重新载入的内存区域大小，比如函数栈，如果你把函数栈的数据给抹掉了，也就无法恢复之前的函数调用栈数据了，这种可以称为Dirty内存区域，但如果是通过文件内存映射载入到内存区域的，可以先清除掉这部分内存里的数据暂时把这部分内存给别人用，需要时再从文件载入到内存，这种内存区域可以认为是非Dirty的。Dirty Size可以代表一个进程需求的最少内存量，当然在模拟器上，还要加上被交换出去的数据大小，即Swapped Size。
我们回到上图，VM Tracker给出的Dirty Size总量时69.79M，还是和79.3M有些差距。不过我们可在在图中看到_DATA数据段，Stack（函数栈）等等Allocations没有统计的内存区域。

# Debug Navigator VS vmmap command line

苹果除了Instrument的VM Tracker可以查看虚拟内存之外，还有一个vmmap命令行可以查看进程的虚拟内存分配。使用模拟器启动App，通过Activity Monitor找到App的进程ID，比如1364，使用vmmap查看它的虚拟内存分配。



```undefined
vmmap 1364 
```

结果如下



```csharp
...
                                VIRTUAL RESIDENT    DIRTY  SWAPPED VOLATILE   NONVOL    EMPTY   REGION 
REGION TYPE                        SIZE     SIZE     SIZE     SIZE     SIZE     SIZE     SIZE    COUNT (non-coalesced) 
===========                     ======= ========    =====  ======= ========   ======    =====  ======= 
Activity Tracing                   256K      36K      36K      12K       0K      36K       0K        2 
CoreAnimation                     36.1M    33.3M    33.3M    2848K       0K    33.3M       0K        2 
Kernel Alloc Once                    8K       8K       8K       0K       0K       0K       0K        2 
MALLOC guard page                   48K       0K       0K       0K       0K       0K       0K       13 
MALLOC metadata                    260K      92K      92K      32K       0K       0K       0K       16 
MALLOC_LARGE                      4360K    4256K    4256K     104K       0K       0K       0K        3         see MALLOC ZONE table below
MALLOC_LARGE (empty)              3988K    2080K    2080K    1908K       0K       0K       0K        2         see MALLOC ZONE table below
MALLOC_LARGE metadata                4K       4K       4K       0K       0K       0K       0K        2         see MALLOC ZONE table below
MALLOC_NANO                       16.0M    2160K    2160K       0K       0K       0K       0K        3         see MALLOC ZONE table below
MALLOC_SMALL                      40.0M     840K     840K     356K       0K       0K       0K        3         see MALLOC ZONE table below
MALLOC_TINY                       8192K     320K     320K      36K       0K       0K       0K        3         see MALLOC ZONE table below
Performance tool data              316K     264K     264K      52K       0K       0K       0K        3         not counted in TOTAL below
STACK GUARD                       56.0M       0K       0K       0K       0K       0K       0K        4 
Stack                             9232K      76K      76K      20K       0K       0K       0K        7 
__DATA                            35.4M    16.6M    16.4M    12.3M       0K       0K       0K      282 
__FONT_DATA                          4K       0K       0K       0K       0K       0K       0K        2 
__LINKEDIT                        96.0M    69.5M       0K       0K       0K       0K       0K      225 
__TEXT                           228.3M    54.4M       4K       4K       0K       0K       0K      225 
__UNICODE                          560K     320K       0K       0K       0K       0K       0K        2 
mapped file                       28.7M    2116K       0K       0K       0K       0K       0K        3 
shared memory                       44K      24K      24K       8K       0K       0K       0K        5 
===========                     ======= ========    =====  ======= ========   ======    =====  ======= 
TOTAL                            562.9M   185.8M    59.3M    17.5M       0K    33.4M       0K      786 
```

我们将Dirty Size和Swapped Size总量相加59.3M + 17.5M = 76.8M，和Debug Navigator给的值已经很相近了，我们再看上面的表格，发现有一行是这么写的`Performance tool data ... not counted in TOTAL below`，`Performance tool data`并没有统计在最下面的TOTAL中，因为这些数据是Debug时提供调用回溯数据用的，所以vmmap默认认为没有价值，没有统计。但是Debug Navigator不这么认为，我们加上`Performance tool data`的内存用量，264K + 52K = 316K = 0.308M，加上之前的76.8M就是77.108M，由于本次并没有使用Instruments进行profile，所以占用的内存会少一些，Debug Navigator显示的刚好是77.1M。至于为什么vmmap显示的数据要比Instruments VM Tracker的要完整，目前我还没有明确的答案。

# shared memory

最后我要提到的时共享内存，共享内存可以提供跨进程访问的能力，不过如果你的App使用了别的进程创建的共享内存，那么Debug Navigator是不会将它计入你自己的内存总量的，不过vmmap会将它加入TOTAL中，所以可能会导致vmmap计算的内存量会大于Debug Navigator统计内存量。由于目前iOS对于shared memory的一些API并不支持，我也没有深入研究，只是在OSX中验证了这一点。

# 总结

最后来总结一下，Debug Navigator其实就是统计了当前进程的所有虚拟内存的Dirty Size + Swapped Size，当然还要剔除掉对第三方共享内存的使用量，当我们发现Debug Navigator的内存量飙高时，不仅仅要去关注Heap上的内存用量，更要关注VM Tracker中那些大Dirty Size的VM Region，这样才能更透彻的了解你的App究竟是怎样使用内存的。