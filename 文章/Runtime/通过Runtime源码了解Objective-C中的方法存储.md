有经验的iOS开发者应该都知道，Objective-C是动态语言，Objective-C中的方法调用严格来说其实是消息传递。举例来说，调用对象A的hello方法
```
[A hello];
```
其实是向A对象发送了@selector(hello)消息。

在上一篇文章[Runtime中的isa结构体](https://github.com/acBool/Blogs/blob/master/Runtime/Runtime%E4%B8%AD%E7%9A%84%20isa%20%E7%BB%93%E6%9E%84%E4%BD%93.md)中提到过，对象的方法是存储在类结构中的，之所以这样设计是出于内存方面的考虑。那么，方法是如何在类结构中存储的？以及方法是在编译期间添加到类结构中，还是在运行期间添加到了类结构中？下面分析一下这几个问题。
### objc_class
首先看一下Objective-C中的类在Runtime源码中是如何表示的：
```
// objc_class继承于objc_object,因此
// objc_class中也有isa结构体
struct objc_class : objc_object {
    isa_t isa;
    Class superclass;
    // 缓存的是指针和vtable,目的是加速方法的调用
    cache_t cache;  
    // class_data_bits_t 相当于是class_rw_t 指针加上rr/alloc标志
    class_data_bits_t bits;  
    // 其他函数
}
```
#### isa
isa是isa_t类型的结构体，里面存储了类的指针以及一些其他的信息。对象的方法是存储在类中的，当调用对象方法时，对象就是通过isa结构体找到自己所属的类，然后在类结构中找到方法。
#### superclass
父类指针。指向该类的父类。
#### cache
根据Runtime源码提供的注释，cache中缓存了指针和vtable，目的是加速方法的调用（关于cache的内部结构，在之后的文章中会介绍）。
#### bits
bits是class_data_bits_t类型的结构体，看一下class_data_bits_t的定义。
##### class_data_bits_t
struct class_data_bits_t {
    // 相当于 unsigned long bits; 占64位
    // bits实际上是一个地址（是一个对象的指针，可以指向class_ro_t，也可以指向class_rw_t）
    uintptr_t bits;
}
单看class_data_bits_t的定义，也看不出来什么有用的信息，里面存储了一个64位的整数（地址）。

再回到类的结构，isa、superclass、cache的作用都很明确，唯独bits现在不知道作什么用。而且isa、superclass、cache中也没有保存类的方法，因此我们有理由相信类的方法存储和bits有关系（因为仅剩这一个了啊）。

看一下苹果官方对bits的注释：
```
class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
```
以及在objc-runtime-new.h中的注释：
```
// class_data_bits_t is the class_t->data field (class_rw_t pointer plus flags)
```
注释提到，bits相当于是class_rw_t指针加上rr/alloc flags。rr/alloc flags先不管，看一下class_rw_t结构体到底是什么。
#### class_rw_t
Runtime中class_rw_t的定义如下：
```
// 类的方法、属性、协议等信息都保存在class_rw_t结构体中
struct class_rw_t {
    uint32_t flags;
    uint32_t version;

    const class_ro_t *ro;
    
    // 方法信息
    method_array_t methods;
    // 属性信息
    property_array_t properties;
    // 协议信息
    protocol_array_t protocols;

    Class firstSubclass;
    Class nextSiblingClass;

    char *demangledName;
}
```
在class_rw_t结构体中看到了方法列表、属性列表、协议列表，这正是我们一直在找的。

需要注意的是，在objc_class结构体中提供了获取class_rw_t 的函数：
```
class_rw_t *data() {
    // 这里的bits就是class_data_bits_t bits;
    return bits.data();
}
```
调用了class_data_bits_t的data()函数，看一下class_data_bits_t里面的data()函数：
```
class_rw_t* data() {
    // FAST_DATA_MASK的值是0x00007ffffffffff8UL
    // bits和FAST_DATA_MASK按位与，实际上就是取了bits中的[3,46]位
    return (class_rw_t *)(bits & FAST_DATA_MASK);
}
```
上文提到过，class_data_bits_t中只有一个64位的变量bits。而class_data_bits_t的data函数，就是将bits和FAST_DATA_MASK进行按位与操作。FAST_DATA_MASK转换成二进制后的值是：
```
0000 0000 0000 0000 0111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1000
```
FAST_DATA_MASK的[3,46]位都为1，其他为是0，因此可以理解成class_rw_t占了class_data_bits_t 中的[3,46]位，其他位置保存了额外的信息。

class_rw_t结构中有一个class_ro_t类型的指针ro,看一下class_ro_t结构体。
#### class_ro_t
class_ro_t的定义如下：
```
// class_ro_t结构体存储了类在编译期就已经确定的属性、方法以及遵循的协议
// 因为在编译期就已经确定了，所以是ro(readonly)的，不可修改
struct class_ro_t {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
#ifdef __LP64__
    uint32_t reserved;
#endif
    const uint8_t * ivarLayout;
    const char * name;
    // 方法列表
    method_list_t * baseMethodList;
    // 协议列表
    protocol_list_t * baseProtocols;
    // 变量列表
    const ivar_list_t * ivars;
    const uint8_t * weakIvarLayout;
    // 属性列表
    property_list_t *baseProperties;
};
```
在class_ro_t结构体中，也定义了方法列表、协议列表、属性列表、变量列表。class_ro_t中的方法列表和class_rw_t中的方法列表有什么区别呢？

实际上，**class_ro_t结构体存储了类在编译期间确定的属性、方法、协议以及变量**。解释一下，Objective-C是动态语言，因此Objective-C的运行需要编译期和运行时系统共同合作，这一点在类的方法的体现的非常明显。

Objective-C代码经过编译之后，会生成类结构，以及根据代码生成类的属性、方法、协议、变量，这些信息在编译期间就能够完全确定，编译期间确定的信息保存在class_ro_t结构体中。因为是在编译期间确定的，所以是只读的，**不可修改，ro,代表readonly**。在运行时，可以往类结构中增加一些额外的方法、协议，比如在Category中写的方法，Category中的方法就是在运行时加入到类结构中的。运行时生成的类的方法、属性、协议保存在class_rw_t结构体中，**rw,代表readwrite,可以修改**。

也就是说，编译之后，运行时未初始化之前，类结构中的class_data_bits_t bits，指向的是class_ro_t结构体，示意图如下：

![image](https://github.com/acBool/picture/blob/master/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-03-21%20%E4%B8%8B%E5%8D%884.04.51.png)

经过运行时初始化之后，class_data_bits_t bits指向正确的class_rw_t结构体，而class_rw_t结构体中的ro指针，指向上面提到的class_ro_t结构体。示意图如下：

![image](https://github.com/acBool/picture/blob/master/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-03-21%20%E4%B8%8B%E5%8D%884.16.51.png)

下面看一下Runtime中是如何实现上述操作的。
#### realizeClass
Runtime中class_data_bits_t指向class_rw_t结构体是通过realizeClass函数实现的。Runtime是按照如下顺序执行到realizeClass函数的：
```
_objc_init->map_images->map_images_nolock->_read_images->realizeClass
```
realizeClass的核心代码如下：
```
// 该方法包括初始化类的read-write数据，并返回真正的类结构
static Class realizeClass(Class cls)
{
    const class_ro_t *ro;
    class_rw_t *rw;
    Class supercls;
    Class metacls;
    bool isMeta;

    if (!cls) return nil;
    // 如果类已经实现了，直接返回
    if (cls->isRealized()) return cls;
    // 编译期间，cls->data指向的是class_ro_t结构体
    // 因此这里强制转成class_ro_t没有问题
    ro = (const class_ro_t *)cls->data();
    if (ro->flags & RO_FUTURE) {
        // rw结构体已经被初始化（正常不会执行到这里）
        // This was a future class. rw data is already allocated.
        rw = cls->data();
        ro = cls->data()->ro;
        cls->changeInfo(RW_REALIZED|RW_REALIZING, RW_FUTURE);
    } else {
        // 正常的类都是执行到这里
        // Normal class. Allocate writeable class data.
        // 初始化class_rw_t结构体
        rw = (class_rw_t *)calloc(sizeof(class_rw_t), 1);
        // 赋值class_rw_t的class_ro_t，也就是ro
        rw->ro = ro;
        rw->flags = RW_REALIZED|RW_REALIZING;
        // cls->data 指向class_rw_t结构体
        cls->setData(rw);
    }
    // 将类实现的方法（包括分类）、属性和遵循的协议添加到class_rw_t结构体中的methods、properties、protocols列表中
    methodizeClass(cls);
    return cls;
}
```
正常的类会执行到else逻辑里面，整个realizeClass函数做的操作如下：
1.  将class->data指向的数据强制转化为class_ro_t结构体，因为编译期间class->data指向的就是class_ro_t结构体，所以这一步的转化是没有问题的
2.  生成一个class_rw_t结构体
3.  将class_rw_t的ro指针指向上一步转化出的class_ro_t结构体
4.  设置class_rw_t的flags值
5.  设置class->data指向class_rw_t结构体
6.  调用methodizeClass函数

realizeClass的逻辑相对来说是比较简单的，这里不做太多的介绍。看一下methodizeClass函数做了哪些操作。
#### methodizeClass
methodizeClass函数的主要作用是赋值类结构class_rw_t结构体里面的方法列表、属性列表、协议列表,包括category中的方法。

methodizeClass函数的主要代码如下：
```
// 设置类的方法列表、协议列表、属性列表，包括category的方法
static void methodizeClass(Class cls)
{
    bool isMeta = cls->isMetaClass();
    auto rw = cls->data();
    auto ro = rw->ro;
    // 将class_ro_t中的methodList添加到class_rw_t结构体中的methodList
    method_list_t *list = ro->baseMethods();
    if (list) {
        prepareMethodLists(cls, &list, 1, YES, isBundleClass(cls));
        rw->methods.attachLists(&list, 1);
    }
    // 将class_ro_t中的propertyList添加到class_rw_t结构体中的propertyList
    property_list_t *proplist = ro->baseProperties;
    if (proplist) {
        rw->properties.attachLists(&proplist, 1);
    }
    // 将class_ro_t中的protocolList添加到class_rw_t结构体中的protocolList
    protocol_list_t *protolist = ro->baseProtocols;
    if (protolist) {
        rw->protocols.attachLists(&protolist, 1);
    }
    // 添加category方法
    category_list *cats = unattachedCategoriesForClass(cls, true /*realizing*/);
    attachCategories(cls, cats, false /*don't flush caches*/);
    if (cats) free(cats);
}
```
至此，类的class_rw_t结构体设置完毕。

在看这一部分代码的时候，我有个问题一直没想明白。我们知道，类的Category可以添加方法，但是是不能添加变量的。通过看Runtime的源码也证明了这一点，因为类的变量是在class_ro_t结构体中保存，class_ro_t结构体在编译期间就已经确定了，是不可修改的，所以运行时不允许添加变量，这没问题。问题是运行时可以添加属性，在methodizeClass函数中有将属性赋值到class_rw_t结构体的操作，而且在处理Category的函数attachCategories中，也有将Category中的属性添加到类属性中的代码：
```
property_list_t **proplists = (property_list_t **)
        malloc(cats->count * sizeof(*proplists));
rw->properties.attachLists(proplists, propcount);
```
在Objective-C中，属性 = get方法 + set方法 + 实例变量。既然不能添加实例变量，那Category支持添加属性的意义又在哪里？如果有了解这一点的，还希望不吝赐教。

到这里，关于方法在类结构体中的存储位置，以及方法是什么时候添加到类结构体中的已经清楚了。然而，上面的结论基本上是通过看Runtime源码以及一些猜测组成的，下面写代码验证一下。
### 代码验证
#### 准备代码
首先定义一个Person类，Person类中只有一个方法say，代码如下：
```
// Person.h

@interface Person : NSObject

- (void)say;

@end

// Person.m
- (void)say
{
    NSLog(@"hello,world!");
}
```
在main.m中获取Person类的地址，代码如下：
```
Class pcls = [Person class];
NSLog(@"p address = %p",pcls);
```
#### 相对地址
在继续下一步之前，先了解一下相对地址的概念。正如上面代码，我们能够打印出Person类的地址。需要注意的是，**这里的地址是相对地址**。所谓相对地址，是指这里的地址不是计算机里面的绝对地址，而是相对程序入口的偏移量。

代码经过编译之后，会为类分配一个地址，这个地址就是相对程序入口的偏移量。程序入口地址+该偏移量，就能够访问到类。**编译运行成功之后，停止运行，不修改任何代码，再次编译，类的地址是不会变的**。用上面的代码来说就是，不修改代码，多次编译，Person类的地址是不会改变的。原因也很容易想到，Person类的地址是相对地址，代码没有改变的情况下，相对地址肯定也是不会变的。
#### objc_class中各变量占用的位数
objc_class结构体如下：
```
struct objc_class : objc_object {
    isa_t isa;
    Class superclass;
    // 缓存的是指针和vtable,目的是加速方法的调用
    cache_t cache;  
    // class_data_bits_t 相当于是class_rw_t 指针加上rr/alloc标志
    class_data_bits_t bits;  
    // 其他函数
}
```
在realizeClass中，我们可以打印出objc_class中isa、superclass、cache所占的位数，代码如下：
```
printf("cache bits = %d\n",sizeof(cls->cache));
printf("super bits = %d\n",sizeof(cls->superclass));
printf("isa bits = %d\n",sizeof(cls->ISA()));
```
不论调用多少次，输出的结果是一致的：
```
cache bits = 16
super bits = 8
isa bits = 8
```
说明isa占8位，superclass占8位，cache占16位。也就是说，**objc_class的地址偏移32位，即可得到bits的地址**。
#### 编译后类的结构
首先运行代码，打印出Person类的地址是：
```
0x1000011e8
```
然后在_objc_init函数里面打断点，如下图：

![image](https://github.com/acBool/picture/blob/master/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-03-22%20%E4%B8%8A%E5%8D%8810.49.55.png)

_objc_init是Runtime初始化的入口函数，断点打在这里，能够确保此时Runtime还未初始化。接下来我们借助lldb来查看编译后类的结构。
```
p (objc_class *)0x1000011e8 // 打印类指针
(objc_class *) $0 = 0x00000001000011e8

p (class_data_bits_t *)0x100001208  // 偏移32位，打印class_data_bits_t指针
(class_data_bits_t *) $1 = 0x0000000100001208

p $1->data()   // 通过data函数获取到class_rw_t结构体，此时的class_rw_t实际上是class_ro_t结构体
(class_rw_t *) $2 = 0x0000000100001150

p (class_ro_t *)$2  // 将class_rw_t强制转换为class_ro_t
(class_ro_t *) $3 = 0x0000000100001150

p *$3  // 打印class_ro_t结构体
(class_ro_t) $5 = {
  flags = 128
  instanceStart = 8
  instanceSize = 8
  reserved = 0
  ivarLayout = 0x0000000000000000 <no value available>
  name = 0x0000000100000f65 "Person"
  baseMethodList = 0x0000000100001130
  baseProtocols = 0x0000000000000000
  ivars = 0x0000000000000000
  weakIvarLayout = 0x0000000000000000 <no value available>
  baseProperties = 0x0000000000000000
}
// 打印出的结构体，变量列表为空，属性列表为空，方法列表不为空，这是符合我们预期的。因为Person类没有属性，没有变量，只有一个方法。

p $5.baseMethodList // 打印class_ro_t的方法列表
(method_list_t *) $6 = 0x0000000100001130

p $6->get(0)  // 打印方法列表中的第一个方法。因为 method_list_t中提供了get(index)函数
(method_t) $7 = {
  name = "say"
  types = 0x0000000100000fa1 "v16@0:8"
  imp = 0x0000000100000d50 (runtimeTest`-[Person say] at Person.m:12)
}

// 如果再尝试获取下一个方法，会提示错误
p $6->get(1)
Assertion failed: (i < count), function get,
```

#### 运行时初始化后类的结构
再来看一下运行时初始化之后类的结构。

在realizeClass中添加如下代码，确保当前初始化的的确是Person类
```
// 这里通过类名来判断
int flag = strcmp("Person",ro->name);
if(flag == 0){
    printf("nname = %s\n",ro->name);
}
```
在else语句之后打断点，此时用lldb调试：
```
// 注意这里不能用编译期间的地址，因为编译和运行属于两个不同的进程
(lldb) p (objc_class *)cls
(objc_class *) $0 = 0x00000001000011e8
(lldb) p (class_data_bits_t *)0x0000000100001208
(class_data_bits_t *) $1 = 0x0000000100001208
(lldb) p $1->data()
(class_rw_t *) $2 = 0x0000000100f5cf00
(lldb) p *$2
(class_rw_t) $3 = {
  flags = 2148007936
  version = 0
  ro = 0x0000000100001150
  methods = {
    list_array_tt<method_t, method_list_t> = {
       = {
        list = 0x0000000000000000
        arrayAndFlag = 0
      }
    }
  }
  properties = {
    list_array_tt<property_t, property_list_t> = {
       = {
        list = 0x0000000000000000
        arrayAndFlag = 0
      }
    }
  }
  protocols = {
    list_array_tt<unsigned long, protocol_list_t> = {
       = {
        list = 0x0000000000000000
        arrayAndFlag = 0
      }
    }
  }
  firstSubclass = nil
  nextSiblingClass = nil
  demangledName = 0x0000000000000000 <no value available>
}
```
此时class_rw_t结构体的ro指针已经设置好了，但是其方法列表现在还是空。

在return 语句上打断点，也就是执行完 methodizeClass(cls)函数之后：
```
(lldb) p *$2
(class_rw_t) $3 = {
  flags = 2148007936
  version = 0
  ro = 0x0000000100001150
  methods = {
    list_array_tt<method_t, method_list_t> = {
       = {
        list = 0x0000000100001130
        arrayAndFlag = 4294971696
      }
    }
  }
  properties = {
    list_array_tt<property_t, property_list_t> = {
       = {
        list = 0x0000000000000000
        arrayAndFlag = 0
      }
    }
  }
  protocols = {
    list_array_tt<unsigned long, protocol_list_t> = {
       = {
        list = 0x0000000000000000
        arrayAndFlag = 0
      }
    }
  }
  firstSubclass = nil
  nextSiblingClass = NSDate
  demangledName = 0x0000000000000000 <no value available>
}
```
注意看class_rw_t中的methods已经有内容了。

打印一下class_rw_t结构体中methods的内容：
```
(lldb) p $3.methods.beginCategoryMethodLists()[0][0]
(method_list_t) $7 = {
  entsize_list_tt<method_t, method_list_t, 3> = {
    entsizeAndFlags = 26
    count = 1
    first = {
      name = "say"
      types = 0x0000000100000fa1 "v16@0:8"
      imp = 0x0000000100000d50 (runtimeTest`-[Person say] at Person.m:12)
    }
  }
}
```
确实是Person的say方法。当尝试打印下一个方法时：
```
(lldb) p $3.methods.beginCategoryMethodLists()[0][1]
(method_list_t) $6 = {
  entsize_list_tt<method_t, method_list_t, 3> = {
    entsizeAndFlags = 128
    count = 8
    first = {
      name = <no value available>
      types = 0x0000000000000000 <no value available>
      imp = 0x0000000100000f65 ("Person")
    }
  }
}
```
结果为空。

符合我们的预期。
#### 添加Category后类的结构
现在给Person类添加一个Category,并且在Category中添加一个方法，再来验证一下。

为Person类添加一个Fly分类,Category代码：
```
@interface Person (Fly)

- (void)fly;

@end

@implementation Person (Fly)

- (void)fly
{
    NSLog(@"I can fly");
}

@end
```

和上面的验证逻辑一样，在realizeClass函数的else分之后和return语句前加断点，当然前提还是当前确实是在初始化Person类。

在else分之之后的打印和之前一致：
```
(lldb) p (objc_class *)cls
(objc_class *) $0 = 0x0000000100001220
(lldb) p (class_data_bits_t *)0x0000000100001240
(class_data_bits_t *) $1 = 0x0000000100001240
(lldb) p (class_rw_t *)$1->data()
(class_rw_t *) $2 = 0x0000000100e58a30
(lldb) p *$2
(class_rw_t) $3 = {
  flags = 2148007936
  version = 0
  ro = 0x0000000100001188
  methods = {
    list_array_tt<method_t, method_list_t> = {
       = {
        list = 0x0000000000000000
        arrayAndFlag = 0
      }
    }
  }
  properties = {
    list_array_tt<property_t, property_list_t> = {
       = {
        list = 0x0000000000000000
        arrayAndFlag = 0
      }
    }
  }
  protocols = {
    list_array_tt<unsigned long, protocol_list_t> = {
       = {
        list = 0x0000000000000000
        arrayAndFlag = 0
      }
    }
  }
  firstSubclass = nil
  nextSiblingClass = nil
  demangledName = 0x0000000000000000 <no value available>
}
```
重点看一下执行完methodizeClass函数之后：
```
(lldb) p *$2
(class_rw_t) $4 = {
  flags = 2148007936
  version = 0
  ro = 0x0000000100001188
  methods = {
    list_array_tt<method_t, method_list_t> = {
       = {
        list = 0x0000000100001108
        arrayAndFlag = 4294971656
      }
    }
  }
  properties = {
    list_array_tt<property_t, property_list_t> = {
       = {
        list = 0x0000000000000000
        arrayAndFlag = 0
      }
    }
  }
  protocols = {
    list_array_tt<unsigned long, protocol_list_t> = {
       = {
        list = 0x0000000000000000
        arrayAndFlag = 0
      }
    }
  }
  firstSubclass = nil
  nextSiblingClass = NSDate
  demangledName = 0x0000000000000000 <no value available>
}
```
class_rw_t结构体的methods有内容，打印一下methods中的内容：
```
(lldb) p $3.methods
(method_array_t) $5 = {
  list_array_tt<method_t, method_list_t> = {
     = {
      list = 0x0000000100001108
      arrayAndFlag = 4294971656
    }
  }
}


(lldb) p $5.list
(method_list_t *) $6 = 0x0000000100001108

// 打印第一个方法
(lldb) p $6->get(0)
(method_t) $8 = {
  name = "say"
  types = 0x0000000100000fa2 "v16@0:8"
  imp = 0x0000000100000cb0 (runtimeTest`-[Person say] at Person.m:12)
}

// 打印第二个方法
(lldb) p $6->get(1)
(method_t) $9 = {
  name = "fly"
  types = 0x0000000100000fa2 "v16@0:8"
  imp = 0x0000000100000e90 (runtimeTest`-[Person(Fly) fly] at Person+Fly.m:12)
}

```
Category中的方法已经成功添加，符合预期。

### 总结
本篇文章主要是分析了对象的方法在类结构中存储的位置，以及方法是在什么时期添加到类结构中的。通过Runtime源码以及代码验证，证实了我们的结论。

在最后，有一些不常用到的知识点再次提一下：
1.  我们在代码中打印的地址是相对地址，不是绝对地址，是相对程序入口的偏移量
2.  在不修改代码的前提下，类的内存地址是不变的
3.  编译和运行属于两个不同的进程

### 参考文章
[深入解析 ObjC 中方法的结构](https://github.com/draveness/analyze/blob/master/contents/objc/%E6%B7%B1%E5%85%A5%E8%A7%A3%E6%9E%90%20ObjC%20%E4%B8%AD%E6%96%B9%E6%B3%95%E7%9A%84%E7%BB%93%E6%9E%84.md)
