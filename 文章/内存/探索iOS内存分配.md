# 前言

在运行iOS（OSX）程序时，左侧的`Debug Navigator`中可以看见当前使用的内存。我们也可以使用Instruments的`Allocations`模板来追踪对象的创建和释放。不知道你是否也曾困惑于`Debug Navigator`显示的内存和`Allocations`显示的总内存对不上号的问题。本篇文章将带你深入了解iOS的内存分配。

# Allocations模版

在Instruments的`Allocations`模板中，可以看到主要统计的是`All Heap & Anonymous VM`的内存使用量。`All Heap`好理解，就是App运行过程中在堆上分配的内存。我们可以通过搜索关键字查看你关注的类在堆上的内存分配情况。那么`Anonymous VM`是什么呢？按照官方描述，它是和你的App进程关联比较大的VM regions。原文如下。



```csharp
interesting VM regions such as graphics- and Core Data-related. Hides mapped files, dylibs, and some large reserved VM regions.
```

# 虚拟内存简介

什么是VM Regions呢？要知道这个首先要了解什么是虚拟内存。当我们向系统申请内存时，系统并不会给你返回物理内存的地址，而是给你一个虚拟内存地址。每个进程都拥有相同大小的虚拟地址空间，对于32位的进程，可以拥有4GB的虚拟内存，64位进程则更多，可达18EB。只有我们开始使用申请到的虚拟内存时，系统才会将虚拟地址映射到物理地址上，从而让程序使用真实的物理内存。下面是一个示意图，我简化了概念。





![img](https:////upload-images.jianshu.io/upload_images/2949750-33b8d070d84d1f15.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/730)

111516112448_.pic.jpg

进程A和B都拥有1到4的虚拟内存。系统通过虚拟内存到物理内存的映射，让A和B都可以使用到物理内存。上图中物理内存是充足的，但是如果A占用了大部分内存，B想要使用物理内存的时候物理内存却不够该怎么办呢？在OSX上系统会将不活跃的内存块写入硬盘，一般称之为`swapping out`。iOS上则会通知App，让App清理内存，也就是我们熟知的Memory Warning。

# 内存分页

系统会对虚拟内存和物理内存进行分页，虚拟内存到物理内存的映射都是以页为最小粒度的。在OSX和早期的iOS系统中，物理和虚拟内存都按照4KB的大小进行分页。iOS近期的系统中，基于A7和A8处理器的系统，物理内存按照4KB分页，虚拟内存按照16KB分页。基于A9处理器的系统，物理和虚拟内存都是以16KB进行分页。系统将内存页分为三种状态。

1. 活跃内存页（active pages）- 这种内存页已经被映射到物理内存中，而且近期被访问过，处于活跃状态。
2. 非活跃内存页（inactive pages）- 这种内存页已经被映射到物理内存中，但是近期没有被访问过。
3. 可用的内存页（free pages）- 没有关联到虚拟内存页的物理内存页集合。

当可用的内存页降低到一定的阀值时，系统就会采取低内存应对措施，在OSX中，系统会将非活跃内存页交换到硬盘上，而在iOS中，则会触发Memory Warning，如果你的App没有处理低内存警告并且还在后台占用太多内存，则有可能被杀掉。

# VM Region

为了更好的管理内存页，系统将一组连续的内存页关联到一个VMObject上，VMObject主要包含下面的属性。

- Resident pages - 已经被映射到物理内存的虚拟内存页列表
- Size - 所有内存页所占区域的大小
- Pager - 用来处理内存页在硬盘和物理内存中交换问题
- Attributes - 这块内存区域的属性，比如读写的权限控制
- Shadow - 用作（copy-on-write）写时拷贝的优化
- Copy - 用作（copy-on-write）写时拷贝的优化
  我们在Instruments的`Anonymous VM`里看到的每条记录都是一个VMObject或者也可以称之为`VM Region`。

# 堆（heap）和 VM Region

那么堆和VM Region是什么关系呢？按照前面的说法，应该任何内存分配都逃不过虚拟内存这套流程，堆应该也是一个VM Region才对。我们应该怎样才能知道堆和VM Region的关系呢？Instruments中有一个VM Track模版，可以帮助我们清楚的了解他们的关系。我创建了一个空的Command Line Tool App。





![img](https:////upload-images.jianshu.io/upload_images/2949750-0a1a9b7d7110b2c4.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/900)



使用下面的代码。



```csharp
int main(int argc, const char * argv[]) {
    NSMutableSet *objs = [NSMutableSet new];
    @autoreleasepool {
        for (int i = 0; i < 1000; ++i) {
            CustomObject *obj = [CustomObject new];
            [objs addObject:obj];
        }
        sleep(100000);
    }
    return 0;
}
```

`CustomObject`是一个简单的OC类，只包含一个long类型的数组属性。



```css
@interface CustomObject() {
    long a[200];
}
@end
```

运行Profile，选择Allocation模版，进入后再添加VM Track模版，这里不知道为什么Allocation模版自带的VM Track不工作，只能自己手动加一个了。





![img](https:////upload-images.jianshu.io/upload_images/2949750-6a97c8e54c65aaf4.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)



我们在`All Heap & Anonymous VM`下可以看到，`CustomObject`有1000个实例，点击`CustomObject`右边的箭头，查看对象地址。



![img](https:////upload-images.jianshu.io/upload_images/2949750-cfa715fd10304761.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1076)





第一个地址是`0x7faab2800000`。我们切换到最底下的VM Track，将模式调整为Regions Map。



![img](https:////upload-images.jianshu.io/upload_images/2949750-3575f195f3421b3a.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1172)





然后找到Address Range为`0x7faab2800000`开头的Region，我们发现这个Region的Type是MALLOC_SMALL。点击箭头看详情，你将会看到这个Region中的内存页列表。



![img](https:////upload-images.jianshu.io/upload_images/2949750-1bc0e00832c65ea0.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)





可能你已经发现了，截图中的内存页Swapped列下都是被标记的，因为我测试的是Mac上的App，所以当内存页不活跃时会被交换到硬盘上。这也就验证了我们在上面提到的交换机制。如果我们将`CustomObject`的尺寸变大，比如作如下变动。



```css
@interface CustomObject() {
    long a[20000];
}
@end
```

内存上会有什么变化呢？答案是`CustomObject`会被移动到MALLOC_LARGE内存区。



![img](https:////upload-images.jianshu.io/upload_images/2949750-7d86e5af9b5bd87f.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)





所以总的来说，堆区会被划分成很多不同的VM Region，不同类型的内存分配根据需求进入不同的VM Region。除了MALLOC_LARGE和MALLOC_SMALL外，还有MALLOC_TINY， MALLOC metadata等等。具体什么样的内存分配进什么样的VM Region，我自己也还在探索中。

# VM Region Size

我们在VM Track中可以看到，一个VM Region有4种size。

- Dirty Size
- Swapped Size
- Resident Size
- Virtual Size
  `Virtual Size`顾名思义，就是虚拟内存大小，将一个VM Region的结束地址减去起始地址就是这个值。`Resident Size`指的是实际使用物理内存的大小。`Swapped Size`则是交换到硬盘上的大小，仅OSX可用。`Dirty Size`根据官方的解释我的理解是如果一个内存页想要被复用，必须将内容写到硬盘上的话，这个内存页就是Dirty的。下面是官方对`Dirty Size`的解释。`secondary storage`可以理解为硬盘。



```undefined
The amount of memory currently being used that must be written to secondary storage before being reused.
```

所以一般来说app运行过程中在堆上动态分配的内存页都是Dirty的，加载动态库或者文件内存映射产生的内存页则是非Dirty的。综上，我们可以总结出，
`Virtual Size >= Resident Size + Swapped Size >= Dirty Size + Swapped Size`，

# malloc 和 calloc

我们除了使用NSObject的alloc分配内存外，还可以使用c的函数malloc进行内存分配。malloc的内存分配当然也是先分配虚拟内存，然后使用的时候再映射到物理内存，不过malloc有一个缺陷，必须配合memset将内存区中所有的值设置为0。这样就导致了一个问题，malloc出一块内存区域时，系统并没有分配物理内存。然而，调用memset后，系统将会把malloc出的所有虚拟内存关联到物理内存上，因为你访问了所有内存区域。我们通过代码来验证一下。在main方法中，创建一个1024*1024的内存块，也就是1M。



```cpp
void *memBlock = malloc(1024 * 1024);
```



![img](https:////upload-images.jianshu.io/upload_images/2949750-d6e7534675a6ce20.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)



我们发现MALLOC_LARGE中有一块虚拟内存大小为1M的VM Region。因为我们没有使用这块内存，所以其他Size都是0。现在我们加上memset再观察。



```cpp
void *memBlock = malloc(1024 * 1024);
memset(memBlock, 0, 1024 * 1024);
```



![img](https:////upload-images.jianshu.io/upload_images/2949750-bad975ed1bbe903d.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/1200)



现在`Resident Size`，`Dirty Size`也是1M了，说明这块内存已经被映射到物理内存中去了。为了解决这个问题，苹果官方推荐使用calloc代替malloc，calloc返回的内存区域会自动清零，而且只有使用时才会关联到物理内存并清零。

# malloc_zone_t 和 NSZone

相信大家对NSZone并不陌生，`allocWithZone`或者`copyWithZone`这2个方法大家应该也经常见到。那么Zone究竟是什么呢？Zone可以被理解为一组内存块，在某个Zone里分配的内存块，会随着这个Zone的销毁而销毁，所以Zone可以加速大量小内存块的集体销毁。不过NSZone实际上已经被苹果抛弃。你可以创建自己的NSZone，然后使用`allocWithZone`将你的OC对象在这个NSZone上分配，但是你的对象还是会被分配在默认的NSZone里。我们可以用heap工具查看进程的Zone分布情况。首先使用下面的代码让`CustomObject`使用新的NSZone。



```objectivec
void allocCustomObjectsWithCustomNSZone() {
    static NSMutableSet *objs = nil;
    if (objs == nil) { objs = [NSMutableSet new]; }
    
    NSZone *customZone = NSCreateZone(1024, 1024, YES);
    NSSetZoneName(customZone, @"Custom Object Zone");
    for (int i = 0; i < 1000; ++i) {
        CustomObject *obj = [CustomObject allocWithZone:customZone];
        [objs addObject:obj];
    }
}
```

代码创建了1000个`CustomObject`对象，并且尝试使用新建的Zone。我们用heap工具看看结果。首先使用Activity Monitor找到进程的PID，在命令行中执行



```undefined
heap PID
```

执行的结果大致如下。



```objectivec
......

Process 25073: 3 zones
Zone DefaultMallocZone_0x1004c9000: Overall size: 196992KB; 13993 nodes malloced for 160779KB (81% of capacity); largest unused: [0x102800000-171072KB]
Zone Custom Object Zone_0x1004fe000: Overall size: 1024KB; 1 nodes malloced for 1KB (0% of capacity); largest unused: [0x102200000-1024KB]
Zone GFXMallocZone_0x1004d8000: Overall size: 0KB
All zones: 13994 nodes malloced - 160779KB

Zone DefaultMallocZone_0x1004c9000: 13993 nodes - Sizes: 160KB[1000] 64.5KB[1] 16.5KB[1] 13.5KB[1] 4.5KB[3] 2KB[3] 1.5KB[12] 1KB[1] 704[1] 576[13] 528[4] 512[2] 480[1] 464[1] 448[2] 432[1] 400[1] 384[2] 368[1] 352[1] 336[2] 320[1] 272[8] 256[1] 240[4] 208[10] 192[5] 176[3] 160[5] 144[28] 128[48] 112[43] 96[83] 80[519] 64[3044] 48[5415] 32[3640] 16[82] 

Zone Custom Object Zone_0x1004fe000: 1 nodes - Sizes: 32[1] 

Zone GFXMallocZone_0x1004d8000: 0 nodes

All zones: 13994 nodes malloced - Sizes: 160KB[1000] 64.5KB[1] 16.5KB[1] 13.5KB[1] 4.5KB[3] 2KB[3] 1.5KB[12] 1KB[1] 704[1] 576[13] 528[4] 512[2] 480[1] 464[1] 448[2] 432[1] 400[1] 384[2] 368[1] 352[1] 336[2] 320[1] 272[8] 256[1] 240[4] 208[10] 192[5] 176[3] 160[5] 144[28] 128[48] 112[43] 96[83] 80[519] 64[3044] 48[5415] 32[3641] 16[82] 

Found 523 ObjC classes
Found 56 CFTypes

-----------------------------------------------------------------------
Zone DefaultMallocZone_0x1004c9000: 13993 nodes (164637440 bytes) 

    COUNT     BYTES       AVG   CLASS_NAME                                       TYPE    BINARY
    =====     =====       ===   ==========                                       ====    ======
    12771    779136      61.0   non-object                                                                 
     1000 163840000  163840.0   CustomObject                                     ObjC    VMResearch        
       49      2864      58.4   CFString                                         ObjC    CoreFoundation    
       21      1344      64.0   pthread_mutex_t                                  C       libpthread.dylib  
       20      1280      64.0   CFDictionary                                     ObjC    CoreFoundation    
       18      2368     131.6   CFDictionary (Value Storage)                     C       CoreFoundation    
       16      2304     144.0   CFDictionary (Key Storage)                       C       CoreFoundation    
        8       512      64.0   CFBasicHash                                      CFType  CoreFoundation    
        7       560      80.0   CFArray                                          ObjC    CoreFoundation    
        6       768     128.0   CFPrefsPlistSource                               ObjC    CoreFoundation    
        6       480      80.0   OS_os_log                                        ObjC    libsystem_trace.dylib
        5       160      32.0   NSMergePolicy                                    ObjC    CoreData          
        4       384      96.0   NSLock                                           ObjC    Foundation        

......

-----------------------------------------------------------------------
Zone Custom Object Zone_0x1004fe000: 1 nodes (32 bytes) 

    COUNT     BYTES       AVG   CLASS_NAME                                       TYPE    BINARY
    =====     =====       ===   ==========                                       ====    ======
        1        32      32.0   non-object                                                                 

-----------------------------------------------------------------------
Zone GFXMallocZone_0x1004d8000: 0 nodes (0 bytes) 
```

一共有3个zone，`Zone Custom Object Zone_0x1004fe000: 1 nodes (32 bytes)`就是我们创建的NSZone，不过它里面只有一个节点，共32bytes，如果你不设置Zone的name，它会是0bytes。所以我们可以推导出这32bytes是用来存储Zone本身的信息的。我们创建的1000个`CustomObject`其实在`Zone DefaultMallocZone_0x1004c9000`里，也就是系统默认创建的NSZone。如果你真的想用Zone内存机制，可以使用malloc_zone_t。通过下面的代码可以在自定义的zone上malloc内存块。



```cpp
void allocCustomObjectsWithCustomMallocZone() {
    malloc_zone_t *customZone = malloc_create_zone(1024, 0);
    malloc_set_zone_name(customZone, "custom malloc zone");
    for (int i = 0; i < 1000; ++i) {
        malloc_zone_malloc(customZone, 300 * 4096);
    }
}
```

再次使用heap工具查看。我只截取了custom malloc zone的内容。有1001个node，也就是1000个malloc_zone_malloc出来的内存块加上zone本身的信息所占的内存块。



```objectivec
-----------------------------------------------------------------------
Zone custom malloc zone_0x1004fe000: 1001 nodes (1228800032 bytes) 

    COUNT     BYTES       AVG   CLASS_NAME                                       TYPE    BINARY
    =====     =====       ===   ==========                                       ====    ======
     1001 1228800032 1227572.4   non-object  
```

我们可以使用`malloc_destroy_zone(customZone)`一次性释放上面分配的所有内存。

# 总结

本文主要介绍了iOS （OSX）系统中VM的相关原理，以及如何使用VM Track模板来分析VM Regions，本文只是关注了MALLOC相关的几个VM Region，还有其他专用的一些VM Region，通过研究他们的内存分配，可以有针对性的对内存进行优化，这就是接下来要做的事情。