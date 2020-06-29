#### 绘制和渲染的流程

![img](https://upload-images.jianshu.io/upload_images/1802898-465c1b3cb2afae4e.jpeg?imageMogr2/auto-orient/strip|imageView2/2/w/700)

绘制和渲染流程

**运行一段动画的过程可以分为6个阶段：**

1> 布局 - 为视图/图层准备层级关系，以及设置图层属性(位置，背景色，边框等等)的阶段。
2> 显示 - 图层的寄宿图片被绘制的阶段。绘制涉及到-drawRect:和-drawLayer:inContext:方法的调用。
3> 准备 - Image decoding, Image conversion(如果图片类型不是GPU所支持的，需要对图片进行转换)。
4> 提交 - Core Animation打包所有的图层和动画，然后通过IPC(进程内通信)发送到渲染服务(render server，一个单独管理动画和图层组合的一个系统进程)。这个步骤是递归的，所以如果layer tree如果比较复杂此步骤代价比较高。

上面4个步骤发生在自己的应用程序内部，动画显示到屏幕之前还有2个步骤的工作：
5> 对所有图层属性计算中间值，设置OpenGL几何形状来执行渲染。
6> 在屏幕上渲染可见的三角形。

前5个阶段都在软件层面处理(通过CPU)，只有最后一个阶段被GPU执行。6个阶段中只有**布局**和**显示**两个阶段是可以被我们控制的，Core Animation框架处理剩下的事务。

#### CPU vs GPU

![img](https://upload-images.jianshu.io/upload_images/1802898-7f903b1bf85f0ada.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/640)

在16.67ms内准备好需要渲染的帧

CPU和GPU在屏幕上显示内容扮演了重要的角色，为了达到60fps，CPU和GPU需要在**1/60=16.67ms**内完成各自的工作。在优化iOS绘制和渲染过程中，需要从CPU和GPU两方面入手，确认是哪一部分达到了性能瓶颈影响了绘制效率。并且在可控制的布局和显示阶段，决定哪些由CPU执行，哪些交给GPU去做。

#### 影响CPU使用率的操作

##### 布局的计算

如果视图层级过于复杂，当视图呈现或者修改的时候，计算图层会消耗一部分时间。（UITableView的动态计算cell高度）

##### 解压图片

图片绘制到屏幕上之前，必须把它扩展成完整的未解压的尺寸。

##### 图片转换

Session 419 WWDC 2014[[3\]](https://link.jianshu.com/?t=https%3A%2F%2Fdeveloper.apple.com%2Fvideos%2Fplay%2Fwwdc2014%2F419%2F)中提到：“If an image is in a color format that the GPU can not directly work with, it will be converted in the CPU.”
也就是说图片的颜色格式不是32bit，那么CPU会先进行颜色格式转换，然后GPU才会进行渲染。最好直接提供32bit颜色格式的图片，避免转换，或者在非主线程中进行格式转换。

可以通过Core Animation Instruments的**Color Copied Images**选项进行图片颜色格式检测。

##### 绘制

###### 使用CALayer进行绘制：

实现了UIView的-drawRect:或者CALayerDelegate的-drawLayer:inContext:方法，为了支持对图层内容的任意绘制，Core Animation必须创建一个**图层宽\*图层高\*4字节**大小的寄宿图，宽高的单位均为**像素**。

CALayer的**contents**属性就对应于寄宿图，寄宿图是通过**backing store**来保存的。如果没有实现-drawRect:方法，CALayer的contents为空的。（通过po CALayer会发现，实现了-drawRect:的CALayer的contents有内容，反之则没有。）

比如在iPhoneX的模拟器上创建一个没有实现drawRect的5000*5000的视图：

```
DrawRectView *drawRectView = [[DrawRectView alloc] initWithFrame:CGRectMake(0, 0, 5000, 5000)];
[self.view addSubview:drawRectView];


(lldb) po 0x604000239700
<CALayer:0x604000239700; 
position = CGPoint (2500 2500); 
bounds = CGRect (0 0; 5000 5000); 
delegate = <DrawRectView: 0x7fb500410ea0; 
frame = (0 0; 5000 5000); 
layer = <CALayer: 0x604000239700>>; 
contents = <CABackingStore 0x7fb500702100 (buffer [15000 15000] BGRX8888)>; opaque = YES; 
allowsGroupOpacity = YES;
opacity = 1; 
rasterizationScale = 3; 
contentsScale = 3>
```

此时使用了内存**41M**；当在DrawRectView中实现一个空的-drawRect:方法时，此时内存还是**41M**；当给drawRectView设置背景颜色后，此时内存暴涨到了**899M**。

###### 使用CATileLayer进行绘制：

在DrawRectView.m中保留-DrawRect:的同时加入如下代码：

```
+ (Class)layerClass {
    return [CATiledLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [(CATiledLayer *)self.layer setTileSize:CGSizeMake(100 * self.contentScaleFactor,
                                                           100 * self.contentScaleFactor)];
    }
    return self;
}

<CATiledLayer:0x6000004257c0; 
position = CGPoint (2500 2500); 
bounds = CGRect (0 0; 5000 5000); 
delegate = <DrawRectView: 0x7fe31bf19e90; 
frame = (0 0; 5000 5000); 
layer = <CATiledLayer: 0x6000004257c0>>; 
contents = <CAImageProvider 0x7fe31bf04940: 15000 x 15000>; 
opaque = YES; 
canDrawConcurrently = YES; 
allowsGroupOpacity = YES; 
opacity = 1; 
tileSize = CGSize (300 300); 
rasterizationScale = 3; 
contentsScale = 3>
```

内存使用率又会降低到**41M**，CATiledLayer中没有寄宿图，contents部分是CAImageProvider。

###### 使用CAShapeLayer进行绘制：

1> **渲染快速**。CAShapeLayer使用了硬件加速，绘制同一图形会比用Core Graphics快很多。
2> **高效使用内存**。一个CAShapeLayer不需要像普通CALayer一样创建一个寄宿图形，所以无论有多大，都不会占用太多的内存。
3> 不会被图层边界剪裁掉。
4> 不会出现像素化。

一旦绘制结束之后，数据通过IPC传到渲染服务。图层每次重绘的时候都需要抹掉分配的内存来重新分配，在此基础上，Core Graphics绘制就会变得十分缓慢，所以提高绘制性能时需要尽量避免去绘制。

##### 像素对齐

建议总是将layer对象的宽高设置成整数，尽管可以设置成浮点数，但是由于会根据layer的bounds来创建位图图片，Core Animation最终会将layer宽高转换成整数[[4\]](https://link.jianshu.com/?t=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Fcontent%2Fdocumentation%2FCocoa%2FConceptual%2FCoreAnimation_guide%2FImprovingAnimationPerformance%2FImprovingAnimationPerformance.html)。

Core Animation Instruments中的**Color Misaligned Images**选项会做出一些标记。
**洋红色**: UIView的frame像素不对齐，即不能换算成整数像素值。
**黄色**：UIImageView的图片像素大小与其frame.size不对齐，图片发生了缩放。

```
UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 400.1000023, 100.222221110000001)];
label.text = @"{{100, 100}, {100.1000023, 400.222221110000001}}";
[self.view addSubview:label];

UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 250, 200, 300)];
imageView.image = [UIImage imageNamed:@"test.png"];
[self.view addSubview:imageView];
```

![img](https://upload-images.jianshu.io/upload_images/1802898-e6ca2c031e03dc27.png?imageMogr2/auto-orient/strip|imageView2/2/w/225)

像素不对齐标记

###### iPhoneX适配遇到的像素对齐问题

如果是使用CATileLayer进行绘制，如果是水平方向等分的方式进行绘制，如下所示：

```
+ (Class)layerClass {
    return [CATiledLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width / 2.0f;
        [(CATiledLayer *)self.layer setTileSize:CGSizeMake(width * self.contentScaleFactor,
                                                           100 * self.contentScaleFactor)];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"%@", NSStringFromCGRect(rect));
}
```

按照我们的期望，-drawRect:中打印的应该是"{{0,0}, {187.5, 100}}和{{187.5,0},{187.5, 100}}"之类的结果，但是真实结果却是这样的：

```
2018-01-25 11:12:34.508418+0800  {{187.33333333333331, 0}, {187.33333333333331, 100}}
2018-01-25 11:12:34.509249+0800  {{374.66666666666663, 300}, {187.33333333333337, 100}}
2018-01-25 11:12:34.509249+0800  {{187.33333333333331, 300}, {187.33333333333331, 100}}
2018-01-25 11:12:34.509921+0800  {{187.33333333333331, 400}, {187.33333333333331, 100}}
2018-01-25 11:12:34.509921+0800  {{374.66666666666663, 400}, {187.33333333333337, 100}}
2018-01-25 11:12:34.510676+0800  {{187.33333333333331, 500}, {187.33333333333331, 100}}
```

可以推测出，设置分块图片的宽度为**375 / 2 \* 3(PixelsPerPoint) = 562.5(像素)**。分块绘制的图片在转换成位图时宽度转换为整数变成**562像素**。在-drawRect:中参数rect对应的分块区域的宽度为：**562 / 3 = 187.33333**，而不是**375/2=187.5**。
由于iPhoneX之前的机型水平分辨率都是偶数，所以水平均分分块绘制不会出现问题。但是iPhoneX的分辨率是1125*2436，水平方向的像素是奇数，所以可能会出现一些奇怪的现象。所以涉及到像素操作的代码要确保最后得到的像素单位是整数。

#### 影响GPU使用率的操作

通过Instruments GPU Driver查看GPU使用率:

![img](https://upload-images.jianshu.io/upload_images/1802898-f729203ca170d656.png?imageMogr2/auto-orient/strip|imageView2/2/w/665)

通过GPU Driver查看GPU使用率

##### 图层混合

layer的混合涉及到颜色的计算，两个layer混合后每个混合后的像素颜色计算公式为：R = S + D * (1 - Sa)，(Source(top)，Destination(lower))。如果Source(top)是不透明的，那么R = S。

如果CALayer上的opaque属性为YES，那么该layer就是不透明，GPU不会做任何合成，只是简单的层拷贝。CALayer上opaque的默认值是NO，UIView的alpha默认为1。

修改opaque属性只是会修改Core Animation的backing store，如果CALayer的contents属性是一张带有alpha通道的图片的话，图片仍然会保留其alpha通道而忽略掉opaque属性的值[CALayer文档]。比如UIImageView虽然有CALayer，但是该图层并没有backing store，而是使用一个CGImageRef作为它的内容，渲染服务会把图片的数据绘制到帧缓冲区[[2\]](https://link.jianshu.com/?t=https%3A%2F%2Fobjccn.io%2Fissue-3-1%2F)。

通过开启Core Animation Instruments的**Color Blended Layers**选项来检测图层混合，发生图层混合会显示红色。

![img](https://upload-images.jianshu.io/upload_images/1802898-6180643b51ff92bd.png?imageMogr2/auto-orient/strip|imageView2/2/w/300)

图层混合检测

##### 离屏渲染

**GPU的屏幕渲染方式有两种：**
1> On-Screen Rendering即当前屏幕渲染，指的是GPU的渲染操作是在当前用于显示的屏幕缓冲区中进行。
2> Off-Screen Rendering即离屏渲染，指的是GPU在当前屏幕缓冲区以外新开辟一个缓冲区进行渲染操作。

**离屏渲染的代价：**
1> 创建新的缓冲区。
2> 上下文切换。离屏渲染的过程中，会发生上下文：从当前屏幕(On-Screen)切换到离屏(Off-Screen)；等到离屏渲染结束以后，将离屏缓冲区的渲染结果显示到屏幕上，又需要将上下文环境从离屏切换到当前屏幕。

**为什么需要离屏渲染？**
一般情况下，OpenGL会将提交到渲染服务(Render Server)的动画直接渲染，但是对于一些复杂的图像动画不能直接进行叠加渲染显示，而是需要根据Command Buffer分通道进行渲染之后再组合，在组合过程中，有些渲染通道不会直接显示，而这些没有直接显示在屏幕上的通道就是Offscreen Render Pass[[3\]](https://link.jianshu.com/?t=https%3A%2F%2Fdeveloper.apple.com%2Fvideos%2Fplay%2Fwwdc2014%2F419%2F)[[6\]](https://www.jianshu.com/p/d74398c50fe1)。

Offscreen Render需要更多的渲染通道，而不同的渲染通道切换需要耗费一定的时间，这个时间内GPU会闲置，当通道达到一定数量，对性能会有较大的影响。

比如，UIBlurEffect的GPU渲染过程[[3\]](https://link.jianshu.com/?t=https%3A%2F%2Fdeveloper.apple.com%2Fvideos%2Fplay%2Fwwdc2014%2F419%2F)：

![img](https://upload-images.jianshu.io/upload_images/1802898-d1705b4f79b78aec.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

UIBlurEffect效果实现

![img](https://upload-images.jianshu.io/upload_images/1802898-8139b8998e58d86e.png?imageMogr2/auto-orient/strip|imageView2/2/w/1092)

通道切换间GPU的闲置

UIBlurEffect需要5个通道才能合成最终的效果图，每一个通道需要上一个通道的输出作为输入。从“通道切换GPU的闲置”这张图能够看到，在16.67ms内，Render的红色部分分成5块，对应着5个通道，由于第一个和最后一个通道对应着全尺寸的图片，所以这两个通道处理的时间比其他3个要多一些，反映在图上也就是宽一些。5个红色Bar中的4个橙色bar是在进行渲染通道的切换，此时GPU处于闲置状态。

**使用shouldRasterize强制触发离屏渲染：**
将CALayer的shouldRasterize设置为YES，会把CALayer对应的位图放入缓存中。
什么情况下适合图层栅格化？
1> 当CALayer的内容是静态的，也就是CALayer内容不会发生变化。
2> 图层结构比较复杂。
3> 使用该图层的地方比较多，存放进缓存中的位图可以多次命中。

#### 参考文献

[1]: iOS核心动画高级技巧
[2]: 绘制像素到屏幕上
[3]: Advanced Graphics and Animations for iOS Apps
[4]: Improving Animation Performance
[5]: 内存恶鬼drawRect
[6]: 深刻理解移动端优化之离屏渲染