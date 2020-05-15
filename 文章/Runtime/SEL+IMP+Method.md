### SEL

SEL又叫选择器，是表示一个方法的`selector`的指针，其定义如下：

```
typedef struct objc_selector *SEL;
```

`objc_selector`结构体的详细定义没有在`<objc/runtime.h>`头文件中找到。方法的`selector`用于表示运行时方法的名字。Objective-C在编译时，会依据每一个方法的名字、参数序列，生成一个唯一的整型标识(`Int`类型的地址)，这个标识就是`SEL`。如下代码所示：

```
SEL sel1 = @selector(method1);
NSLog(@"sel : %p", sel1);
```

上面的输出为：

```
2014-10-30 18:40:07.518 RuntimeTest[52734:466626] sel : 0x100002d72
```

两个类之间，不管它们是父类与子类的关系，还是之间没有这种关系，只要方法名相同，那么方法的SEL就是一样的。每一个方法都对应着一个`SEL`。所以在Objective-C同一个类(及类的继承体系)中，不能存在2个同名的方法，即使参数类型不同也不行。相同的方法只能对应一个`SEL`。这也就导致Objective-C在处理相同方法名且参数个数相同但类型不同的方法方面的能力很差。如在某个类中定义以下两个方法：

```
- (void)setWidth:(int)width;
- (void)setWidth:(double)width;
```

这样的定义被认为是一种编译错误，所以我们不能像C++, C#那样。而是需要像下面这样来声明：

```
-(void)setWidthIntValue:(int)width;
-(void)setWidthDoubleValue:(double)width;
```

当然，不同的类可以拥有相同的`selector`，这个没有问题。不同类的实例对象执行相同的`selector`时，会在各自的方法列表中去根据`selector`去寻找自己对应的`IMP`。

工程中的所有的`SEL`组成一个`Set`集合，Set的特点就是唯一，因此SEL是唯一的。因此，如果我们想到这个方法集合中查找某个方法时，只需要去找到这个方法对应的SEL就行了，SEL实际上就是根据方法名`hash`化了的一个字符串，而对于字符串的比较仅仅需要比较他们的地址就可以了，可以说速度上无语伦比！！但是，有一个问题，就是数量增多会增大hash冲突而导致的性能下降（或是没有冲突，因为也可能用的是`perfect hash`）。但是不管使用什么样的方法加速，如果能够将总量减少（多个方法可能对应同一个`SEL`），那将是最犀利的方法。那么，我们就不难理解，为什么`SEL`仅仅是函数名了。

本质上，`SEL`只是一个指向方法的指针（准确的说，只是一个根据方法名`hash`化了的`KEY`值，能唯一代表一个方法），它的存在只是为了加快方法的查询速度。这个查找过程我们将在下面讨论。

我们可以在运行时添加新的`selector`，也可以在运行时获取已存在的`selector`，我们可以通过下面三种方法来获取SEL:

1. `sel_registerName`函数
2. Objective-C编译器提供的`@selector()`
3. `NSSelectorFromString()`方法

### IMP

`IMP`实际上是一个函数指针，指向方法实现的首地址。其定义如下：

```
id (*IMP)(id, SEL, ...)
```

这个函数使用当前`CPU`架构实现的标准的C调用约定。第一个参数是指向`self`的指针(如果是实例方法，则是类实例的内存地址；如果是类方法，则是指向元类的指针)，第二个参数是方法选择器(`selector`)，接下来是方法的实际参数列表。

前面介绍过的`SEL`就是为了查找方法的最终实现`IMP`的。由于每个方法对应唯一的`SEL`，因此我们可以通过`SEL`方便快速准确地获得它所对应的`IMP`，查找过程将在下面讨论。取得`IMP`后，我们就获得了执行这个方法代码的入口点，此时，我们就可以像调用普通的C语言函数一样来使用这个函数指针了。

通过取得`IMP`，我们可以跳过Runtime的消息传递机制，直接执行`IMP`指向的函数实现，这样省去了Runtime消息传递过程中所做的一系列查找操作，会比直接向对象发送消息高效一些。

### Method

介绍完`SEL`和`IMP`，我们就可以来讲讲`Method`了。`Method`用于表示类定义中的方法，则定义如下：

```
typedef struct objc_method *Method;

struct objc_method {
    SEL method_name                	OBJC2_UNAVAILABLE;	// 方法名
    char *method_types                	OBJC2_UNAVAILABLE;
    IMP method_imp             			OBJC2_UNAVAILABLE;	// 方法实现
}
```

我们可以看到该结构体中包含一个`SEL`和`IMP`，实际上相当于在`SEL`和`IMP`之间作了一个映射。有了SEL，我们便可以找到对应的`IMP`，从而调用方法的实现代码。具体操作流程我们将在下面讨论。

#### objc_method_description

`objc_method_description`定义了一个Objective-C方法，其定义如下：

```
struct objc_method_description { SEL name; char *types; };
```