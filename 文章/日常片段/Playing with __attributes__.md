## 前言

在一些代码中我们经常能看见如下的一些函数修饰符：

```
__attribute__((constructor)) static void foo(void) {
    //...
}
void f(void)__attribute__((availability(macosx,introduced=10.4,deprecated=10.6,obsoleted=10.7)));
```

## 起源

GNU C中，我们可以使用函数属性（`Function attribute`）为我们的函数定义特定的编译器优化、编译器检查、内存管理、代码生成、调用返回转换。
比如：`noreturn`用于指定该函数没有返回值。`format`用于指定函数参数中存在打印编码风格的参数。

很多属性是平台相关的，比如很多平台支持`interrupt`,但具体使用时必须遵从特定平台的寄存器使用规范。

`__declspec(dllimport) `就是一个常见的在Windows下用于声明从动态库引入函数的声明。

函数属性使用`__attribute__`作为声明关键字，其后用双括号`(())`指定一个特定的属性，使用逗号`,`间隔多个属性。具体可参见[Attribute Syntax](https://gcc.gnu.org/onlinedocs/gcc/Attribute-Syntax.html#Attribute-Syntax)

## 常用的函数属性

### constructor

其修饰的函数将在装载Binary的时候调用，在macos 的call stack如下：

```
    frame #1: 0x00007fff5fc12d0b dyld`ImageLoaderMachO::doModInitFunctions(ImageLoader::LinkContext const&) + 265
    frame #2: 0x00007fff5fc12e98 dyld`ImageLoaderMachO::doInitialization(ImageLoader::LinkContext const&) + 40
    frame #3: 0x00007fff5fc0f891 dyld`ImageLoader::recursiveInitialization(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 305
    frame #4: 0x00007fff5fc0f718 dyld`ImageLoader::processInitializers(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 138
    frame #5: 0x00007fff5fc0f989 dyld`ImageLoader::runInitializers(ImageLoader::LinkContext const&, ImageLoader::InitializerTimingList&) + 75
    frame #6: 0x00007fff5fc02245 dyld`dyld::initializeMainExecutable() + 187
    frame #7: 0x00007fff5fc05c19 dyld`dyld::_main(macho_header const*, unsigned long, int, char const**, char const**, char const**, unsigned long*) + 2669
    frame #8: 0x00007fff5fc01276 dyld`dyldbootstrap::start(macho_header const*, int, char const**, long, macho_header const*, unsigned long*) + 512
    frame #9: 0x00007fff5fc01036 dyld`_dyld_start + 54
```

多个constructor函数调用顺序由声明顺序决定

### destructor

同理在程序结束时调用。

### constructor && destructor with `PRIORITY`

语法：`__attribute__((destructor (PRIORITY)))`
`PRIORITY`越小，优先级越高，越早调用
如：

```
void begin_0 (void) __attribute__((constructor (101)));
void end_0 (void) __attribute__((destructor (101)));
void begin_1 (void) __attribute__((constructor (102)));
void end_1 (void) __attribute__((destructor (102)));
void begin_2 (void) __attribute__((constructor (103)));
void end_2 (void) __attribute__((destructor (103)));
```

运行结果：

```
begin_0 ()
begin_1 ()
begin_2 ()
end_2 ()
end_1 ()
end_0 ()
```

### returns_nonnull

告知编译器返回值绝不为NULL

### alias ("target")

为函数定义别名

### objc_boxable

OC可能你经常会看到@(100)等用法。不用奇怪，就是这个Function attributes
使用示例：

```
struct __attribute__((objc_boxable)) some_struct {
  int i;
};
union __attribute__((objc_boxable)) some_union {
  int i;
  float f;
};
typedef struct __attribute__((objc_boxable)) _some_struct some_struct;

some_struct ss;
NSValue *boxed = @(ss);
```

### objc_requires_super

很多OC的class允许子类重载父类方法，但需要在重载的方法中调用父类方法。如：`-[UIViewController viewDidLoad]`,`-[UITableViewCell prepareForReuse]`等。 对于这样的情况，`objc_requires_super`就能派上用场。在父类的方法声明时使用该属性，能够使子类重载方法时必须调用父类方法。

```
- (void)foo __attribute__((objc_requires_super));
```

`Foundation framework`已经定义好了一个宏`NS_REQUIRES_SUPER`让开发者使用这个属性：

```
- (void)foo NS_REQUIRES_SUPER;
```

### overloadable

使C下的方法调用类似C++中的overload：

```
float __attribute__((overloadable)) tgsin(float x) { return sinf(x); }
double __attribute__((overloadable)) tgsin(double x) { return sin(x); }
long double __attribute__((overloadable)) tgsin(long double x) { return sinl(x); }
```

调用`tgsin`时会根据参数`x`类型决定调用对应的方法。具体参见C++99标准。不在此赘述。

### objc_runtime_name

改变Class或者Protocol的运行时名称。
(水平有限，暂时不知道有何方便之处)

```
__attribute__((objc_runtime_name("MyLocalName")))
@interface Message
@end
```

### objc_method_family

先来看一段代码：

```
@interface MyObject: NSObject
@property (nonatomic) newValue;
@end
```

编译出现error如下：
`Property follows Cocoa naming convention for returning 'owned' objects`
`Explicitly declare getter '-newValue' with '__attribute__((objc_method_family(none)))' to return an 'unowned' object`

在支持ARC后，clang有一些对于内存管理的命名规范。

> You take ownership of an object if you create it using a method whose name begins with “alloc”, “new”, “copy”, or “mutableCopy”

所以，如果方法名以`alloc`, `new`, `copy`, `mutableCopy`开头的函数都会被作为生成新对象的函数对返回对象`retainCount`自增1.
解决办法为,在property后加入 `__attribute__((objc_method_family(none)))`

其他用法：

```
__attribute__((objc_method_family(X)))
```

X可以是`none`, `alloc`, `copy`, `init`, `mutableCopy`, `new`其中之一。放在property或者函数后面。

当然你也可以使不满足编译器命名规则的方法成为生成新对象的方法，如：

```
- (id) createObject __attribute__((objc_method_family(new)));
```

## visibility

`__attribute__((visibility("visibility_type")))`
当我们并不希望暴露一个方法时，一般情况使用`static`关键字来修饰函数。这样编译时该方法就不会被输出到符号表里。详细可参见这篇[博文](http://blog.csdn.net/on_1y/article/details/24290985)

LLVM和GCC其实也提供了类似的`attribute`

使用示例：

```
__attribute__((visibility("default"))) void foo1(int x, int y);
__attribute__((visibility("hidden"))) int foo2(int x);
__attribute__((visibility("protected"))） void foo3(int x, int y);
```

- `default`意味着该方法对其他模块是可见的。
- 而`hidden`表明该方法符号不会被放到动态符号表里，所以其他模块（可执行文件或者动态库）不可以通过符号表访问该方法。(但在运行时使用函数指针可对其进行调用，visibility是个编译时的特性，正如你在运行时可以修改const修饰的变量一样)
- `protected`则表示该方法将会被放置到动态符号表，对其他模块可见。但该符号对其所在模块是绑定的，即其他模块不可重载该符号。
- `internal`,跟`hidden`相似。除非特别指定，否则意味着不能从模块调用该方法。

### -fvisibility

既然说到了visibility，那顺带说一下这个flag，这个flag在调用gcc或者llvm时指定。表示编译时的对所有方法的默认visibility的选择（除非显式指定方法的visibility）。

> ```
> -fvisibility=default|internal|hidden|protected
> ```

一般来说隐藏方法使用`static`就够了。但此attribute为大型工程项目提供了一种可能性，即可以使某些模块整体隐藏所有接口，只暴露特别指定的方法。

### 其他

此外gcc的编译器还可以像如下这样使用：

```
#pragma GCC visibility push(hidden)
void method1() {...}
void method2() {...}
...
#pragma GCC visibility pop
```

即表示在`push`与`pop`之间声明的所有方法，其可见性都按照指定的进行编译。

### **private_extern**

这个关键字也有static相同的作用

## objc_designated_initializer

### 使用方法

```
@interface MyObject:NSObject
- (instancetype)init __attribute__((objc_designated_initializer));
@end
```

在iOS中也可以写成

```
- (instancetype)init NS_DESIGNATED_INITIALIZER;
```

该属性可以指定类的初始化方法。指定初识化方法并不是对使用者。而是对内部的现实。譬如，下面这种情况

### 实例讲解

```
@interface MyObject:NSObject
- (instancetype)initMyObject NS_DESIGNATED_INITIALIZER;
- (instancetype)initMyObjectNonDesignated;
@end

@implementation MyObject        //[8] 产生warning
- (instancetype)initMyObject{
    self = [super init];//[1] 没有warning
    return self;
}

- (instancetype)initMyObjectNonDesignated
{
    self = [self initMyObject];
    return self;
}
@end

@interface DerivedObject:MyObject
- (instancetype)initMyObject2;
- (instancetype)initMyObject3;
- (instancetype)initMyObject4 NS_DESIGNATED_INITIALIZER;
- (instancetype)initMyObject5;
- (instancetype)initMyObject6 NS_DESIGNATED_INITIALIZER;
- (instancetype)initMyObject7;
@end

@implementation DerivedObject   //[9] 产生warning
- (instancetype)initMyObject2{
    self = [super init];//[2] 产生warning
    return self;
}

- (instancetype)initMyObject3{
    self = [self initMyObjectNonDesignated];//[3] 没有warning
    return self;
}

- (instancetype)initMyObject4{
    self = [super initMyObject];//[4] 没有warning
    return self;
}

- (instancetype)initMyObject5{
    self = [self init];//[5] 没有warning
    return self;
}

- (instancetype)initMyObject6{
    self = [self initMyObject4];//[6] 产生warning
    return self;
}

- (instancetype)initMyObject7{
    self = [self initMyObject];//[7] 没有warning
    return self;
}
@end
```

解释一下：

- 如果是DESIGNATED_INITIALIZER的初始化方法，就必须调用`父类`的DESIGNATED_INITIALIZER方法。

> [1]没有warning，因为`NSObject`的`init`也是DESIGNATED_INITIALIZER。[4]也同样正确，父类的`initMyObject`是DESIGNATED_INITIALIZER。所以[6]就不正确了，因为initMyObject4同样是DESIGNATED_INITIALIZER。

- 如果不是DESIGNATED_INITIALIZER的初始化方法,但是该类拥有DESIGNATED_INITIALIZER初始化方法，那么：

1. 必须调用该类的DESIGNATED_INITIALIZER方法或者非DESIGNATED_INITIALIZER方法。
2. 不可以调用父类的任何初始化方法。

> [2]调用的父类的方法 不正确，改成[5]这样就对了 [3]调用的该类的方法（从父类继承过来的），正确
> [7]也调用的该类的方法(从父类继承过来，但会产生其他问题，见下面解释)

- 如果一个类拥有DESIGNATED_INITIALIZER初始化方法，那它必须覆盖实现父类定义的DESIGNATED_INITIALIZER初始化方法。

> [8] [9]都是因为没有覆盖实现父类的DESIGNATED_INITIALIZER方法

> 注：对于非DESIGNATED_INITIALIZER，llvm把它称为`Convenience intializer`。

### 总述

这个attribute的目的其实是在初始化类的实例时，无论调用关系如何复杂，必须调用一次该类的`Designated intializer`(可以有多个),对于 `Designated intializer`，必须调用父类的`Designated intializer`。对于父类的父类这个规则亦然，对`Designated intializer`的调用一直要到根类。

对于上述例子，调用触发顺序应该为：

```
DerivedObject Convenience intializer`-> 若干次其他`DerivedObject Convenience intializer` -> `DerivedObject Designated intializer` -> `MyObject Designated intializer` -> `NSObject Designated intializer
```

### 其他

其实llvm还漏了一些细节，看上述代码：

```
- (instancetype)initMyObject3{
    self = [self initMyObjectNonDesignated];//[3] 没有warning，如果改成super 就有warning
    return self;
}
```

居然没有Warning!这样的话在类会跳过该类的`Designated intializer`。Holy High!从上述的解释来看，对`Convenience intializer`，llvm是没有要求所有的`Convenience intializer`必须调用`Designated intializer`，但这个attribute的设计思路要求终归要调用一次该类的`Designated intializer`。

对于上述情况，我能想到的解释就是llvm还没智能到能分析较为复杂的情况。如不考虑继承。一个类的`Convenience intializer`总会有一个会调用`Designated intializer`，不然就会有循环调用的可能，所以基于这个假设，llvm没有对`Convenience intializer`调用`Convenience intializer`的情况抛出Warning，但却漏了继承过来的`Convenience intializer`情况。

当然这只是我的猜测。