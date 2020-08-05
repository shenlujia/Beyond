有一定经验的iOS开发者，或多或少的都听过Runtime。Runtime，也就是运行时，是Objective-C语言的特性之一。日常开发中，可能直接和Runtime打交道的机会不多。然而，"发消息"、"消息转发"这些名词开发者应该经常听到，这些名词所用到的技术基础就是Runtime。了解Runtime，有助于开发者深入理解Objective-C这门语言。

在具体了解Runtime之前，先提一个问题，什么是动态语言？
### Objective-C是一门动态语言
使用Objective-C做iOS开发的同学一定都听说过一句话：Objective-C是一门动态语言。动态语言，肯定是和静态语言相对应的。那么，静态语言有哪些特性，动态语言又有哪些特性？

回顾一下大学时期，学的第一门语言C语言，学习C语言的过程中从来没听说过运行时，也没听说过什么静态语言，动态语言。因此我们有理由相信，C语言是一门静态语言。

事实上也确实如此，C语言是一门静态语言，Objective-C是一门动态语言。然而，还是说不出静态语言和动态语言到底有什么区别……
#### 静态语言和动态语言
静态语言，可以理解成在编译期间就确定一切的语言。以C语言来举例，C语言编译后会成为一个可执行文件。假设我们在C代码中写了一个hello函数，并且在主程序中调用了这个hello函数。倘若在编译期间，hello函数的入口地址相对于主程序入口地址的偏移量是0x0000abcdef(不要在意这个值，只是用来举例)，那么在执行该程序时，执行到hello函数时，一定执行的是相对主程序入口地址偏移量为0x0000abcdef的代码块。也就是说，**静态语言，在编译期间就已经确定一切，运行期间只是遵守编译期确定的指令在执行**。

作为对比，再看一下动态语言，以经常用到的Objective-C为例。假设在Objective-C中写了hello方法，并且在主程序中调用了hello方法，也就是发送hello消息。在编译期间，只能确定要向某个对象发送hello消息，但是**具体执行哪个内存块的代码是不确定的，具体执行的代码需要在运行期间才能确定**。

到这里，静态语言和动态语言的区别已经很明显了。静态语言在编译期间就已经确定一切，而动态语言编译期间只能确定一部分，还有一部分需要在运行期间才能确定。也就是说，动态语言成为一个可执行程序并能够正确的执行，除了需要一个编译器外，还需要一套运行时系统，用于确定到底执行哪一块代码。Objective-C中的运行时系统内就是Runtime。

### Runtime源码
Runtime源码是一套用C语言实现的API，整套代码是开源的，可以从[苹果开源网站](https://opensource.apple.com/)上下载Runtime源码。默认下载的Runtime源码是不能编译的，通过修改配置和导入必要的头文件，可以编译成功Runtime源码。我在[github](https://github.com/acBool/RuntimeSourceCode)上放了编译成功的Runtime源码，且有我在看Runtime源码时的一些注释，本篇文章中的代码也是基于此Runtime源码。

由于Runtime源码代码量比较大，一篇文章介绍完Runtime源码是不可能的。因此这篇文章主要介绍Runtime中的isa结构体，作为Runtime的入门。
### isa结构体
有经验的iOS开发者可能都听过一句话：在Objective-C语言中，类也是对象，且每个对象都包含一个isa指针，isa指针指向该对象所属的类。不过现在Runtime中的对象定义已经不是这样了，现在使用的是isa_t类型的结构体。每一个对象都有一个isa_t类型的结构体isa。之前的isa指针作用是指向该对象的类，那么isa结构体作为isa指针的替代者，是如何完成这个功能的呢？

在解决这个问题之前，我们先来看一下Runtime源码中对象和类的定义。
#### objc_object
看一下Runtime中对id类型的定义
```
typedef struct objc_object *id;
```
这里的id也就是Objective-C中的id类型，代表任意对象，类似于C语言中的 void *。可以看到，*id实际上是一个指向结构体objc_object的指针。

再来看一下objc_object的定义，该定义位于objc-private.h文件中：
```
struct objc_object {
    // isa结构体
private:
    isa_t isa;
}
```
结构体中还包含一些public的方法。可以看到，对象结构体（objc_object）中的第一个变量就是isa_t 类型的isa。关于isa_t具体是什么，后续再介绍。

Objective-C语言中最主要的就是对象和类，看完了对象在Runtime中的定义，再看一下类在Runtime中的定义。
#### objc_class
Runtime中对于Class的定义
```
typedef struct objc_class *Class;
```
Class实际上是一个指向objc_class结构体的指针。

看一下结构体objc_class的定义，objc_class的定义位于objc-runtime-new.h文件中
```
struct objc_class : objc_object {
    // Class ISA;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
}
```
结构体中还包含一些方法。

注意，objc_class是继承于objc_object的，因此objc_class中也包含isa_t类型的isa。objc_class的定义可以理解成下面这样：
```
struct objc_class {
    isa_t isa;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
}
```
#### isa的作用
上面也提到了，isa能够使该对象找到自己所属的类。为什么对象需要知道自己所属的类呢？这主要是因为对象的方法是存储在该对象所属的类中的。

这一点是很容易理解的，一个类可以有多个对象，倘若每个对象都含有自己能够执行的方法，那对于内存来说是灾难级的。

在向对象发送消息，也就是实例方法被调用时，对象通过自己的isa找到所属的类，然后在类的结构中找到对应方法的实现（关于在类结构中如何找到方法的实现，后续的文章再介绍）。

我们知道，Objective-C中区分类方法和实例方法。实例方法是如何找到的我们了解了，那么类方法是如何找到的呢？类结构体中也有isa，类对象的isa指向哪里呢？
##### 元类（metaClass）
为了解决类方法调用，Objective-C引入了元类（metaClass），类对象的isa指向该类的元类，一个类对象对应一个元类对象。

元类对象也是类对象，既然是类对象，那么元类对象中也有isa，那么元类的isa又指向哪里呢？总不能指向元元类吧……这样是无穷无尽的。

Objective-C语言的设计者已经考虑到了这个问题，所有元类的isa都指向一个元类对象，该元类对象就是 meta Root Class,可以理解成根元类。关于实例对象、类、元类之间的关系，苹果官方给了一张图，非常清晰的表明了三者的关系，如下

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE4999da2f7afe116629d8cf0167527423/17422)

#### isa结构体定义
了解了isa的作用，现在来看一下isa的定义。isa是isa_t类型，isa_t也是一个结构体，其定义在objc-private.h中：
```
union isa_t {
    isa_t() { }
    isa_t(uintptr_t value) : bits(value) { }

    Class cls;
    // 相当于是unsigned long bits;
    uintptr_t bits;
#if defined(ISA_BITFIELD)
    struct {
        ISA_BITFIELD;  // defined in isa.h
    };
#endif
};
```
ISA_BITFIELD的定义在 isa.h文件中：
```
uintptr_t nonpointer        : 1;                                         \
uintptr_t has_assoc         : 1;                                         \
uintptr_t has_cxx_dtor      : 1;                                         \
uintptr_t shiftcls          : 44; /*MACH_VM_MAX_ADDRESS 0x7fffffe00000*/ \
uintptr_t magic             : 6;                                         \
uintptr_t weakly_referenced : 1;                                         \
uintptr_t deallocating      : 1;                                         \
uintptr_t has_sidetable_rc  : 1;                                         \
uintptr_t extra_rc          : 8
```
注意：这里的代码都是x86_64架构下的，arm64架构下和x86_64架构下有区别，但是不影响我们理解isa_t结构体。

将isa_t结构体中的ISA_BITFIELD使用isa.h文件中的ISA_BITFIELD替换，isa_t的定义可以表示如下：
```
union isa_t {
    isa_t() { }
    isa_t(uintptr_t value) : bits(value) { }

    Class cls;
    // 相当于是unsigned long bits;
    uintptr_t bits;
#if defined(ISA_BITFIELD)
    struct {
        uintptr_t nonpointer        : 1; 
        uintptr_t has_assoc         : 1;
        uintptr_t has_cxx_dtor      : 1;
        uintptr_t shiftcls          : 44;
        uintptr_t magic             : 6;
        uintptr_t weakly_referenced : 1;
        uintptr_t deallocating      : 1;
        uintptr_t has_sidetable_rc  : 1;
        uintptr_t extra_rc          : 8;
    };
#endif
};
```
注意isa_t是联合体，也就是说isa_t中的变量，cls、bits和内部的结构体全都位于同一块地址空间。

本篇文章主要分析下isa_t中内部结构体中各个变量的作用
```
struct {
    uintptr_t nonpointer        : 1; 
    uintptr_t has_assoc         : 1;
    uintptr_t has_cxx_dtor      : 1;
    uintptr_t shiftcls          : 44;
    uintptr_t magic             : 6;
    uintptr_t weakly_referenced : 1;
    uintptr_t deallocating      : 1;
    uintptr_t has_sidetable_rc  : 1;
    uintptr_t extra_rc          : 8;
};
```
该结构体共占64位，其内存分布如下：

![image](https://github.com/acBool/picture/blob/master/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-03-19%20%E4%B8%8A%E5%8D%8811.08.14.png)

在了解内个结构体各个变量的作用前，先通过Runtime代码看一下isa结构体是如何初始化的。
#### isa结构体初始化
isa结构体初始化定义在objc_object结构体中，看一下官方提供的函数和注释：
```
// initIsa() should be used to init the isa of new objects only.
// If this object already has an isa, use changeIsa() for correctness.
// initInstanceIsa(): objects with no custom RR/AWZ
// initClassIsa(): class objects
// initProtocolIsa(): protocol objects
// initIsa(): other objects
void initIsa(Class cls /*nonpointer=false*/);
void initClassIsa(Class cls /*nonpointer=maybe*/);
void initProtocolIsa(Class cls /*nonpointer=maybe*/);
void initInstanceIsa(Class cls, bool hasCxxDtor);
```
官方提供的有类对象初始化isa,协议对象初始化isa，实例对象初始化isa，其他对象初始化isa，分别对应不同的函数。

看下每个函数的实现：
```
inline void objc_object::initIsa(Class cls)
{
    initIsa(cls, false, false);
}

inline void objc_object::initClassIsa(Class cls)
{
    if (DisableNonpointerIsa  ||  cls->instancesRequireRawIsa()) {
        initIsa(cls, false/*not nonpointer*/, false);
    } else {
        initIsa(cls, true/*nonpointer*/, false);
    }
}

inline void objc_object::initProtocolIsa(Class cls)
{
    return initClassIsa(cls);
}

inline void objc_object::initInstanceIsa(Class cls, bool hasCxxDtor)
{
    assert(!cls->instancesRequireRawIsa());
    assert(hasCxxDtor == cls->hasCxxDtor());

    initIsa(cls, true, hasCxxDtor);
}
```
可以看到，无论是类对象，实例对象，协议对象，还是其他对象，初始化isa结构体最终都调用了
```
inline void objc_object::initIsa(Class cls, bool nonpointer, bool hasCxxDtor)
```
函数，只是所传的参数不同而已。

最终调用的initIsa函数的代码，经过简化后如下：
```
inline void objc_object::initIsa(Class cls, bool nonpointer, bool hasCxxDtor) 
{ 
    if (!nonpointer) {
        isa.cls = cls;
    } else {
        // 实例对象的isa初始化直接走else分之
        // 初始化一个心得isa_t结构体
        isa_t newisa(0);
        // 对新结构体newisa赋值
        // ISA_MAGIC_VALUE的值是0x001d800000000001ULL，转化成二进制是64位
        // 根据注释，使用ISA_MAGIC_VALUE赋值，实际上只是赋值了isa.magic和isa.nonpointer
        newisa.bits = ISA_MAGIC_VALUE;
        newisa.has_cxx_dtor = hasCxxDtor;
        // 将当前对象的类指针赋值到shiftcls
        // 类的指针是按照字节（8bits）对齐的，其指针后三位都是没有意义的0，因此可以右移3位
        newisa.shiftcls = (uintptr_t)cls >> 3;
        // 赋值。看注释这个地方不是线程安全的？？
        isa = newisa;
    }
}
```
初始化实例对象的isa时，传入的nonpointer参数是true，所以直接走了else分之。在else分之中，对isa的bits分之赋值ISA_MAGIC_VALUE。根据注释，这样代码实际上只是对isa中的magic和nonpointer进行了赋值，来看一下为什么。

ISA_MAGIC_VALUE的值是0x001d800000000001ULL，转化成二进制就是0000 0000 0001 1101 1000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0000 0001,将每一位对应到isa内部的结构体中，看一下对哪些变量产生了影响：

![image](https://github.com/acBool/picture/blob/master/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-03-19%20%E4%B8%8A%E5%8D%8811.54.59.png)

可以看到将nonpointer赋值为1；将magci赋值为110111；其他的仍然都是0。所以说只赋值了isa.magci和isa.nonpointer。

##### nonpointer
在文章开头也提到了，在Objective-C语言中，类也是对象，且每个对象都包含一个isa指针，现在改为了isa结构体。nonpointer作用就是区分这两者。

1.  如果nonpointer为1，代表不是isa指针，而是isa结构体。虽然不是isa指针，但是通过isa结构体仍然能获得类指针（下面会分析）。
2.  如果nonpointer为0，代表当前是isa指针，访问对象的isa会直接返回类指针。

##### magic
magic的值调试器会用到，调试器根据magci的值判断当前对象已经初始过了，还是尚未初始化的空间。

##### has_cxx_dtor
接下来就是对has_cxx_dtor进行赋值。has_cxx_dtor表示当前对象是否有C++的析构函数（destructor）,如果没有，释放时会快速的释放内存。
##### shiftcls
在函数
```
inline void objc_object::initIsa(Class cls, bool nonpointer, bool hasCxxDtor) 
```
中，参数cls就是类的指针。而
```
newisa.shiftcls = (uintptr_t)cls >> 3;
```
shiftcls存储的到底是什么呢？

实际上，shiftcls存储的就是当前对象类的指针。之所以右移三位是出于节省空间上的考虑。

在Objective-C中，类的指针是按照字节(8 bits)对齐的，也就是说类指针地址转化成十进制后，都是8的倍数，也就是说，类指针地址转化成二进制后，后三位都是0。既然是没有意义的0，那么在存储时就可以省略，用节省下来的空间存储一些其他信息。

在objc-runtime-new.mm文件的
```
static __attribute__((always_inline)) id _class_createInstanceFromZone(Class cls, size_t extraBytes, void *zone, 
                              bool cxxConstruct = true, 
                              size_t *outAllocatedSize = nil)
```
函数，类初始化时会调用该函数。可以在该函数中打印类对象的地址
```
if (!cls) return nil;
// 这里可以打印类指针的地址,类指针地址最后一位是十六进制的8或者0，说明
// 类指针地址后三位都是0
printf("cls address = %p\n",cls);
```
打印出的部分信息如下：
```
cls address = 0x7fff83bca218
cls address = 0x7fff83bcab28
cls address = 0x7fff83bc5290
cls address = 0x7fff83717f58
cls address = 0x7fff83717f58
cls address = 0x100b15140
cls address = 0x7fff83717fa8
cls address = 0x7fff837164c8
cls address = 0x7fff837164c8
cls address = 0x7fff83716e78
cls address = 0x100b15140
cls address = 0x7fff837175a8
cls address = 0x7fff837175a8
cls address = 0x7fff83717fa8
```
可以看到类对象的地址最后一位都是8或者0，说明类对象确实是按照字节对齐，后三位都是0。因此在赋值shiftcls时，右移三位是安全的，不会丢失类指针信息。

我们可以写代码验证一下对象的isa和类对象指针的关系。代码如下：
```
#import <Foundation/Foundation.h>
#import "objc-runtime.h"

// 把一个十进制的数转为二进制
NSString * binaryWithInteger(NSUInteger decInt){
    NSString *string = @"";
    NSUInteger x = decInt;
    while(x > 0){
        string = [[NSString stringWithFormat:@"%lu",x&1] stringByAppendingString:string];
        x = x >> 1;
    }
    return string;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 把对象转为objc_object结构体
        struct objc_object *object = (__bridge struct objc_object *)([NSObject new]);
        NSLog(@"binary = %@",binaryWithInteger(object->isa));
        // uintptr_t实际上就是unsigned long
        NSLog(@"binary = %@",binaryWithInteger((uintptr_t)[NSObject class]));
    }
    return 0;
}
```
打印出isa的内容是：1011101100000000000000100000000101100010101000101000001，NSObject类对象的指针是：100000000101100010101000101000000。首先将isa的内容补充至64位
```
0000 0101 1101 1000 0000 0000 0001 0000 0000 1011 0001 0101 0001 0100 0001
```
取第4位到第47位之间的内容，也就是shiftcls的值：
```
000 0000 0000 0001 0000 0000 1011 0001 0101 0001 0100 0
```
将类对象的指针右移三位，即去除后三位的0，得到
```
100000000101100010101000101000
```
和上面的shiftcls对比：
```
                 10 0000 0001 0110 0010 1010 0010 1000
0000 0000 0000 0010 0000 0001 0110 0010 1010 0010 1000
```
可以确认：**shiftcls中的确包含了类对象的指针**。
##### 其他位
上面已经介绍了nonpointer、magic、shiftcls、has_cxx_dtor，还有一些其他位没有介绍，这里简单了解一下。

1. has_assoc: 表示对象是否含有关联引用(associatedObject)
2. weakly_referenced: 表示对象是否含有弱引用对象
3. deallocating: 表示对象是否正在释放
4. has_sidetable_rc: 表示对象的引用计数是否太大，如果太大，则需要用其他的数据结构来存
5. extra_rc：对象的引用计数大于1，则会将引用计数的个数存到extra_rc里面。比如对象的引用计数为5，则extra_rc的值为4。

extra_rc和has_sidetable_c可以一起理解。extra_rc用于存放引用计数的个数，extra_rc占8位，也就是最大表示255，当对象的引用计数个数超过257时，has_sidetable_rc的值应该为1。

### 总结
至此，isa结构体的介绍就完了。需要提醒的是，上面的代码是运行在macOS上，也就是x86_64架构上的，isa结构体也是基于x86_64架构的。在arm64架构上，isa结构体中变量所占用的位数和x86_64架构是不一样的，但是表示的含义是一样的。理解了x86_64架构下的isa结构体，相信对于理解arm架构下的isa结构体，应该不是什么难事。

### 参考文章
[从 NSObject 的初始化了解 isa](https://github.com/draveness/analyze/blob/master/contents/objc/%E4%BB%8E%20NSObject%20%E7%9A%84%E5%88%9D%E5%A7%8B%E5%8C%96%E4%BA%86%E8%A7%A3%20isa.md)
