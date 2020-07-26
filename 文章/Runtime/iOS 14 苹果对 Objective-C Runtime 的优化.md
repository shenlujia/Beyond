# 概述

Objective-C 是一门古老的语言，诞生于 1984 年，跟随 Apple 一路浮沉，见证了乔布斯创建了 NeXT，也见证了乔布斯重回 Apple 重创辉煌，它用它特立独行的语法，堆砌了 UIKit，AppKit, Foundation 等一个个基石，时间来到 2020 年，面对汹涌的"后浪" Swift，"老前辈" Objective-C 也在发挥着自己的余热，即使面对越来越多阵地失守，唯有“老兵不死，只会慢慢凋亡"才能体现的悲壮。今年，Apple 给 Objective-C Runtime 带来了新的优化，接下来，让我们深入理解这些变化。

# 类数据结构变化

首先我们先来了解一下二进制类在磁盘中的表示

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpkLiaIcQggVqsnjTEYVjaqlJw6LPPuxyialngPuDwiaia5qMdg2uiaLK4Hwg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

首先是类对象本身，包含最常访问的信息：指向元类，超类和方法缓存的指针，在类结构之中有指向包含更多数据的结构体`class_ro_t`的指针，包含了类的名称，方法，协议，实例变量等等编译期确定的信息。其中 ro 表示 read only 的意思。

当类被 Runtime 加载之后，类的结构会发生一些变化，在了解这些变化之前，我们需要知道2个概念：
**Clean Memory：**加载后不会发生更改的内存块，`class_ro_t`属于`Clean Memory`，因为它是只读的。
**Dirty Memory：**运行时会进行更改的内存块，类一旦被加载，就会变成`Dirty Memory`，例如，我们可以在 Runtime 给类动态的添加方法。

这里要明确，`Dirty Memory`比`Clean Memory`要昂贵得多。因为它需要更多的内存信息，并且只要进程正在运行，就必须保留它。对于我们来说，越多的`Clean Memory`显然是更好的，因为它可以节约更多的内存。我们可以通过分离出永不更改的数据部分，将大多数类数据保留为`Clean Memory`，如何怎么做的呢？
在介绍优化方法之前，我们先来看一下，在类加载之后，类的结构会变成如何呢？

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpvgWXA5uYj6WRjJFiaYsK0icEib3vGibgVExKKWiaV41FkjCiaXvyJa4tchaw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

在类加载到 Runtime 中后会被分配用于读取/写入数据的结构体`class_rw_t`。

> **Tips：**`class_ro_t`是只读的，存放的是编译期间就确定的字段信息；而`class_rw_t`是在 runtime 时才创建的，它会先将`class_ro_t`的内容拷贝一份，再将类的分类的属性、方法、协议等信息添加进去，之所以要这么设计是因为 Objective-C 是动态语言，你可以在运行时更改它们方法，属性等，并且分类可以在不改变类设计的前提下，将新方法添加到类中。

事实证明，`class_rw_t`会占用比`class_ro_t`占用更多的内存，在 iPhone 中，我们在系统测量了大约 30MB 的这些`class_rw_t`结构。应该如何优化这些内存呢？通过测量实际设备上的使用情况，我们发现大约 10％ 的类实际会存在动态的更改行为，如动态添加方法，使用 Category 方法等。因此，我们能可以把这部分动态的部分提取出来，我们称之为`class_rw_ext_t`，所以，结构会变成这个样子。

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpyFr3tl9pmCI2GDjuX3mfJUlHY8G5gyib5SR9LTjiaibDWd8LeHmKuz5mA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

经过拆分，可以把 90% 的类优化为`Clean Memory`，在系统层面，取得效果是节省了大约 14MB 的内存，使内存可用于更有效的用途。

> **Tips：**`head xxxxx | egrep 'class_rw|COUNT’` 你可以使用此命令来查看 `class_rw_t` 消耗的内存。xxxx可以替换为需要测量的 App 名称。如：`head Mail | egrep 'class_rw|COUNT’\'`查看 Mail 应用的使用情况。

# 相对方法地址

现在，我们来看看 Runtime 的第二处的变化，方法地址的优化。

每个类都包含一个方法列表，以便 Runtime 可以查找和消息发送。结构大概如下图所示：

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0Irpw28jKXK4nmCdDhk694HhicUPZpcGlZtwY5wHIgOV7pXibfe24Fud28Eg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

方法包含了3部分的内容：

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpxMQ7pW8VmqBFj5TLVCgvwNI1DPpMvTCv22NRchLRiaMEGwvRbV9qqVg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

- Selector：方法名称或选择器。选择器是字符串，但是它们是唯一的
- 方法类型编码：方法类型编码标识（详情可以查看参考链接）
- IMP：方法实现的函数指针

在 64 位系统中，它们占用了 24 字节的空间

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpM7qwnV4tK2luDG8NJ28hDHXDSOdEL7t7e4F7ndkDxwrFGCeicTvcZVA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

了解了方法的结构之后，我们来看下进程中内存的简化视图

![img](https://mmbiz.qpic.cn/mmbiz_jpg/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpZziacM0th9EGBK0wvHfgfZNpBmlG62A9DQkmDfLIiav4Sfv2hiaMksoVw/640?wx_fmt=jpeg&wxfrom=5&wx_lazy=1&wx_co=1)

这是一个 64 位的地址空间，其中各种块分别表示了栈，堆以及各种库。我们把焦点放在 AppKit 库中的`init`方法。

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpmJEicr6TtME60CY5vfuau8bXDibrI8JONRTzu04URt9DBNpgDFf1dNicw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

如图所示，图中的3个地址分别为方法的 3 个部分的表示的绝对地址，我们知道，库的地址取决于动态链接库加载之后的位置，ASLR（Address space layout randomization 地址空间布局随机化）的存在，动态链接器需要修正真实的指针地址，这也是一种代价。由于方法实现地址不会脱离当前库的地址范围的特性存在，所以实际上，方法列表并不需要使用 64 位的寻址范围空间。他们只需要能够在自己的库地址中查找引用函数地址即可，这些函数将始终在附近。所以我们可以使用 32 位相对偏移来代替绝对 64 位地址。

现在我们地址将变成这样

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpKRkS0AVWXy8Yj1Sf6VIjic8aibzLOMYfb7OVB4HQ8MAcSUNmNvbbeDzA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

这么做有几个优点：

1. 无论将库加载到内存中的任何位置，偏移量始终是相同的，因此从加载后不需要进行修正指针地址。
2. 它们可以保存在只读存储器中，这会更加的安全。
3. 使用 32 位偏移量在 64 位平台上所需的内存量减少了一半。在 iPhone 中我们可以节省约 40MB 的内存大小。

优化后，指针所需的内存占用量可以减少一半。

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrplWiaBT0eWXM5dNrfczNRoibSPFrZ7d739EqOEicoK3PNT1WqgF1PzYtXw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

相对方法地址会引发另外一个问题，那就是在`Method Swizzling`如何处理呢？众所皆知，`Method Swizzling`替换的是 2 个方法函数指针指向，方法函数实现可以在任意地方实现，使用了相对偏移地址了之后，这样就无法工作了。
针对`Method Swizzling`我们使用全局映射表来解决这个问题，在映射表中维护`Swizzles`方法对应的实现函数指针地址。由于`Method Swizzling`的操作并不常见，所以这个表不会变得很大，新的`Method Swizzling`机制如下图。

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0Irp0y4AXAttm6jcpO4PrWVdO3wY9nxQ2jMSnsVoH0T6qC6Veib206OJ4HQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

# Tagged Pointer 格式的变化

接下来我们会深入了解 Tagged Pointer 在 ARM CPU 下的格式变化
首先，让我们先来了解下 Tagged Pointer 是什么
**Tagged Pointer：**一种特殊标记的对象，Tagged Pointer 通过在其最后一个 bit 位设置为特殊标记位，并且把数据直接保存在指针本身中。Tagged Pointer 是一个"伪"对象，使用 Tagged Pointer 有 3 倍的访问速度提升，100 倍的创建、销毁速度提升。

> **Tips：**Advances in Objective-C

在我们查看对象指针时，在 64 位系统中，我们会看到 16 进制地址如`0x00000001003041e0`，我们把它转换为二进制表示如下图

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpQNcFtwyeLzyEvd9RUw049ScbHicmyia844HdDOLaAqd9nd7qrtosiaOzQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

在 64 位系统中，我们有 64 位可以表示一个对象指针，但是我们通常没有真正使用到所有这些位，由于内存对齐要求的存在，低位始终为0，对象必须始终位于指针大小倍数的地址中。高位也始终为0。实际上我们只是用中间这一部分的位。

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpCVg39Wh6IGnkwDfDYDrspGFoq9IVGtlG3AQvasHaWaa0v0jappia6og/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

因此，我们可以把最低位设置为 1，表示这个对象是一个 Tagged Pointer 对象。设置为 0 则表示为正常的对象

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpvmMlX43rtEvJMjTvGIO6WbUgzn1os0M99rDIcPFublDxov7eBjbZfA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

在设置为 1 表示为 Tagged Pointer 对象之后，在最低位之后的 3 位，我们给他赋予类型意义，由于只有 3 位，所以它可以表示 7 种数据类型

```
OBJC_TAG_NSAtom            = 0,
OBJC_TAG_1                 = 1,
OBJC_TAG_NSString          = 2,
OBJC_TAG_NSNumber          = 3,
OBJC_TAG_NSIndexPath       = 4,
OBJC_TAG_NSManagedObjectID = 5,
OBJC_TAG_NSDate            = 6,
OBJC_TAG_7                 = 7
```

在剩余的字段中，我们可以赋予他所包含的数据。在 Intel 中，我们 Tagged Pointer 对象的表示如下

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpAnN3CFoNCWwmVmqh7N5Q6ymWOEJoo7XUgWv6cdvTPZfW8zNdnR6Brg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

`OBJC_TAG_7`类型的 Tagged Pointer 是个例外，它可以将接下来后 8 位作为它的扩展类型字段，基于此我们可以多支持 256 种类型的 Tagged Pointer，如 UIColors 或 NSIndexSets 之类的对象。

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0Irp9JJ73ic920lokn5h37W37pJ1lVGHR7qydIhsjjLdPA4vLIHaicT6VdOw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

上文中，我们介绍的是在 Intel 中 Tagged Pointer 的表示，在 ARM64 中，我们情况有些变化。

![img](https://mmbiz.qpic.cn/mmbiz_png/deSLfic6WeGWWWIckdSAMcfNficNQQ0IrpQXrrfF1U3biaYetrmvA5ONJB9FZZBmKg48CKUib9g3y4asUUC1icpbs9g/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

我们使用最高位代表 Tagged Pointer 标识位，最低位 3 位标识 Tagged Pointer 的类型，接下去的位来表示包含的数据（可能包含扩展类型字段），为什么我们使用高位指示 ARM上 的 Tagged Pointer，而不是像 Intel 一样使用低位标记？

它实际是对 objc_msgSend 的微小优化。我们希望 msgSend 中最常用的路径尽可能快。最常用的路径表示普通对象指针。我们有两种不常见的情况：Tagged Pointer 指针和 nil。事实证明，当我们使用最高位时，可以通过一次比较来检查两者。与分别检查 nil 和 Tagged Pointer 指针相比，这会为 msgSend 中的节省了条件分支。

# 总结

在 2020 年中，Apple 针对 Objective-C 做了三项优化

- 类数据结构变化：节约了系统更多的内存。
- 相对方法地址：节约了内存，并且提高了性能。
- Tagged Pointer 格式的变化：提高了 msgSend 性能。

通过优化，希望大家可以享受 iPhone 更好，更快的使用体验。

> **Tips：**
> 类结构的数据变更会在最新的 Runtime 版本中体现，实测 MacOS 10.5.5 中已经存在。
> 相对方法地址的优化在 Xcode developmentTarget > 14 时会自动进行处理。
> Tagged Pointer 的变化则会在 iOS 14, MacOS Big Sur, iPadOS 14 上生效。

# 参考链接

TypeEncodeing https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
Lets build Tagged Pointers https://www.mikeash.com/pyblog/friday-qa-2012-07-27-lets-build-tagged-pointers.html
Advances in Objective-C https://developer.apple.com/videos/play/wwdc2013/404/