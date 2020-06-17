> ## 0. iOS内存基本原理
>
> 在接触iOS开发的时候，我们都知道“引用计数”的概念，也知道ARC和MRR，但其实这仅仅是对堆内存上对象的内存管理。用WWDC某Session里的话说，这其实只是内存管理的冰山一角。
>
> 在内存管理方面，其实iOS和其它操作系统总体上来说是大同小异的，大的框架原理基本相似，小的细节有所创新和不同。
>
> 和其它操作系统上运行的进程类似，iOS App进程的地址空间也分为代码区、数据区、栈区和堆区等。进程开始时，会把mach-o文件中的各部分，按需加载到内存当中。
>
> 而对于一般的iPhone，实际物理内存都在1G左右，对于超大的内存需求怎么办呢？其实这也是和其它操作系统一样的道理，都由系统内核维护一套虚拟内存系统。但这里需要注意的是iOS的虚存系统原则略有不同，最截然不同的地方就是当物理内存紧张情况时的处理。
>
> 当物理内存紧张时，iOS会把可以通过重新映射来加载的内容直接清理出内存，对于不可再生的数据，iOS需要App进程配合处理，向各进程发送内存警告要求配合释放内存。对于不能及时释放足够内存的，直接Kill掉进程，必要时时甚至是前台运行的App。
>
> 如上所述，iOS在外存没有交换区，没有内存页换出的过程。
>
> ## 1. malloc基本原理
>
> 在iOS App进程地址空间的各个区域中，最灵活的就要属堆区了，它为进程动态分配内存，也是我们经常和内存打交道的地方。
>
> 通常，我们会在需要新对象的时候，进行 [NSObject alloc]调用，而释放对象时需要release（ARC会自动帮你做到这些）。
>
> 而这些alloc、release方法的调用，通常最终都会走到libsystem_malloc.dylib的malloc()和free()函数这里。libsystem_malloc.dylib是iOS内核之外的一个内存库，我们App进程需要的内存，先回请求到这里，但最终libsystem_malloc.dylib也都会向iOS的系统内核发起申请，映射实际内存到App进程的地址空间上。
>
> 从苹果公开的malloc源码上来看，malloc的原理大致如下：
>
> malloc内存分配基于malloc zone，并将内存分配按大小分为nano、tiny、small、large几种类型，申请时按需进行最适分配
> malloc在首次调用时，初始化default zone，在64位情况下，会初始化default zone为nano zone，同时初始化一个scalable zone作为helper zone，nano zone负责nano大小的分配，scalable zone则负责tiny、small和large内存的分配
> 每次malloc时，根据传入的size参数，优先交给nano zone做分配处理，如果大小不在nano范围，则转交给helper zone处理。
>
> [![screenshot](http://img1.tbcdn.cn/L1/461/1/a0410f1886ba4b52f1b7369c69a56f74e3f0a94b)](https://yq.aliyun.com/go/articleRenderRedirect?url=http%3A%2F%2Fimg1.tbcdn.cn%2FL1%2F461%2F1%2Fa0410f1886ba4b52f1b7369c69a56f74e3f0a94b)
> （截图自[http://www.tinylab.org/memory-allocation-mystery-%C2%B7-malloc-in-os-x-ios/）](https://yq.aliyun.com/go/articleRenderRedirect?url=http%3A%2F%2Fwww.tinylab.org%2Fmemory-allocation-mystery-%C2%B7-malloc-in-os-x-ios%2F%EF%BC%89)
>
> 下面分别对nano zone和scalable zone上分配内存的源码做简要解读（由于苹果Open source的代码是针对OS X的特定版本，具体细节可能与iOS上有所不同，如地址空间分布）。
>
> ## 2. nano malloc
>
> 在支持64位的条件按下，malloc优先考虑nano malloc，负责对256B以下小内存分配，单位是16B。
>
> nano zone分配内存的地址空间范围是0x00006nnnnnnnnnnn（OSX上64位情况），将地址空间从大到小一次分为Magazine、Band和Slot几个级别。
>
> - Magazine范围对应于CPU，CPU0对应Mag0，CPU1对应Mag1，依次类推；
> - Band范围为2M，连续内存分配当内存不够时以Band为单位向内核请求;
> - Slot则对应于每个Band中128K大小的范围，每个Band都分为16个Slot，分别对应于16B、32B、...256B大小，支持它们的内存分配
>
> 分配过程：
>
> - 确定当前cpu对应的mag和通过size参数计算出来的slot，去对应metadata的链表中取已经被释放过的内存区块缓存，如果取到检查指针地址是否有问题，没有问题就直接返回；
> - 初次进行nano malloc时，nano zone并没有缓存，会直接在nano zone范围的地址空间上直接分配连续地址内存；
> - 如当前Band中当前Slot耗尽则向系统申请新的Band（每个Band固定大小2M，容纳了16个128k的槽），连续地址分配内存的基地址、limit地址以及当前分配到的地址由meta data结构维护起来，而这些meta data则以Mag、Slot为维度（Mag个数是处理器个数，Slot是16个）的二维数组形式，放在nanozone_t的meta_data字段中。
>
> 当App通过free()释放内存时：malloc库会检查指针地址，如果没有问题，则以链表的形式将这些区块按大小存储起来。这些链表的头部放在meta_data数组中对应的[mag][slot]元素中。
>
> 其实从缓存获取空余内存和释放内存时都会对指向这篇内存区域的指针进行检查，如果有类似地址不对齐、未释放/多次释放、所属地址与预期的mag、slot不匹配等情况都会以报错结束。
>
> 下图是我根据个人理解梳理出来的一个关系图，图中标出了nanozone_t、meta_data_t等相关结构的关键字段画了出来（OSX）。
>
> [![screenshot](http://img1.tbcdn.cn/L1/461/1/4960742425dc6b93cf39f56546db2203a9a0a231)](https://yq.aliyun.com/go/articleRenderRedirect?url=http%3A%2F%2Fimg1.tbcdn.cn%2FL1%2F461%2F1%2F4960742425dc6b93cf39f56546db2203a9a0a231)
>
> 除了分配和释放，系统内存吃紧时，nano zone需将cache的内存区块还给系统，这主要是通过对各个slot对应的meta data上挂着的空闲链表上内存区块回收来完成。
>
> ## 3. scalable zone上内存分配简要分析
>
> 对于超出nano大小范围或者不支持nano分配的，直接会在scalable zone（下文简称szone）上分配内存。由于szone上的内存分配比起nano分配要较为复杂，细节繁多，下面仅作简要介绍，感兴趣的同学可以直接阅读源码。
>
> 在szone上分配的内存包括tiny、small和large三大类，其中tiny和small的分配、释放过程大致相同，large类型有自己的方式管理。
>
> 而tiny、small的方式也依然遵循nano分配中的原则，新内存从系统申请并分配，free后按照大小以特定的形式缓存起来，供后续分配使用。这里的分配在region上进行，region和nano malloc里的band概念极为相似，但不同的是地址空间未必连续，而且每个region都有自己的位图等描述信息。和nano，一样每个cpu有一个magazine，除此之外还分配了一个index为-1的magazine作为后备之用。
>
> 下面是一个简图。
>
> [![screenshot](http://img1.tbcdn.cn/L1/461/1/c50505c7577e0d883c3a33c21c1a0763ae408350)](https://yq.aliyun.com/go/articleRenderRedirect?url=http%3A%2F%2Fimg1.tbcdn.cn%2FL1%2F461%2F1%2Fc50505c7577e0d883c3a33c21c1a0763ae408350)
>
> 以tiny的情况为例，分配时：
>
> - 确定当前线程所在处理器的magazine index，找到对应的magazine结构。
> - 优先查看上次最后释放的区块是否和此次请求的大小刚好相等（都是对齐之后的slot大小），如果是则直接返回。
> - 如果不是，则查找free list中当前请求大小区块的空闲缓存列表，如果有返回，并整理列表。
> - 如果没有，则在free list找比当前申请区块大的，而且最接近的缓存，如果有返回，并把剩余大小放到free list中另外的链表上。（这里需要注意的是，在一般情况下，free list分为64个槽，0-62上挂载区块的大小都是按16B为单位递增，63为所有更大的内存区块挂载的地方）
> - 上面几项都不行，就在最后一个region的尾部或者首部（如果支持内部ALSR）找空闲区域分配。
> - 如果还是不行，说明所有现有region都没空间可用了，那么从一个后备magazine中取出一个可用region，完整地拿过来放到当前magazine，再走一遍上面的步骤。
> - 如果这都不成，那只能向内核申请一块新的region区域，挂载到当前的magazine下并分配内存。
> - 要是再不行就没招了，系统也给不到内存，就报错返回。
>
> free时：
>
> - 检查指针指向地址是否有问题。
> - 如果last free指针上没有挂载内存区块，则放到last free上就OK了。
> - 如果有last free，置换内存，并把last free原有内存区块挂载到free list上（在挂载的free list前，会先根据region位图检查前后区块是否能合并成更大区块，如果能会合并成一个）。
> - 合并后所在的region如果空闲字节超过一定条件，则将把此region放到后备的magazine中（-1）。
> - 如果整个region都是空的，则直接还给系统内核，一了百了。
>
> 而large的情况，malloc以页为单位申请和分配内存，不区分magazine，szone统一维护一个hash table管理已申请的内存。而且由于内存区域都比较庞大，只缓存总量2G的区块，分为16个元素，每个最大为128M。large相关的结构相对简单，就不特意画图了。

