[原文链接](https://github.com/acBool/Blogs/blob/master/Runtime/%E9%80%9A%E8%BF%87Runtime%E6%BA%90%E7%A0%81%E4%BA%86%E8%A7%A3%E5%85%B3%E8%81%94%E5%AF%B9%E8%B1%A1%E7%9A%84%E5%AE%9E%E7%8E%B0.md)

在iOS开发中，Category是经常使用到的一个特性，合理的使用Category能够减少繁琐代码，提高开发效率。在使用Category时，有经验的开发者应该都知道，在Category中是无法添加属性的，如果想在Category中实现属性的效果，需要使用关联对象。关联对象属于Runtime的范畴，本篇文章结合Runtime源码，分析下关联对象的内部实现。

### Category中使用@property
上面提到了在Category中无法添加属性，来验证一下。倘若在Category中添加属性，是会直接编译错误？还是会警告？

定义一个Person类，代码如下：
```
@interface Person : NSObject{
    NSString *_age;
}

- (void)printName;

@end

```
实现文件
```
@implementation Person

- (void)printName
{
    NSLog(@"my name is Person");
}

@end
```
为Person 添加一个Category MyPerson,Category中定义一个属性 personName,代码如下：
```
@interface Person (MyPerson)

@property (nonatomic, copy) NSString *personName;

@end
```
实现文件中暂时为空。

现在我们在Category中添加了@property,编译一下，没有问题，可以编译成功。也就是说，**Category中使用@property不会引起编译错误**。但是呢，Xcode会提示警告，警告信息如下：
```
Property 'personName' requires method 'personName' to be defined - use @dynamic or provide a method implementation in this category

Property 'personName' requires method 'setPersonName:' to be defined - use @dynamic or provide a method implementation in this category
```
大意就是需要为属性personName实现get方法和set方法。

在继续下一步之前，首先需要了解Objective-C中的@property到底是什么：
> @property = 实例变量 + get方法 + set方法

关于@property的更详细介绍，可以参考[这篇文章](https://github.com/acBool/Blogs/blob/master/property/%40property%E4%BB%8B%E7%BB%8D.md)。

也就是说，在普通文件中，定义一个属性，编译器会自动生成实例变量，以及该实例变量对应的get/set方法。但是在Category中，根据Xcode的警告信息，是没有生成get/set方法的。

既然Xcode没有自动生成get/set方法，那么我们来手动实现一下get/set方法。

在Category的实现文件中加入以下代码：
```
- (NSString *)personName
{
    return _personName;
}

- (void)setPersonName:(NSString *)personName
{
    _personName = personName;
}
```
警告信息确实没了，直接提示error，编译不通过，错误信息如下：
```
Use of undeclared identifier '_personName'
```
_personName没有定义。看来在Category中使用@property，编译器不仅不会自动生成set/get方法，连实例变量也不会生成。话说回来，没有实例变量，自然也不会有set/get方法。

正是因为Category中的@property不会生成实例变量，get/set方法，所以如果在程序中使用Category的属性，编译不会有问题，但是在运行期间会直接崩溃。
```
Person *p = [[Person alloc] init];
[p printName];
    
p.personName = @"haha"; // 这里会直接崩溃
```
崩溃信息如下：
```
-[Person setPersonName:]: unrecognized selector sent to instance 0x60000300ab80
```
崩溃原因也是容易理解的，因为根本没有setPersonName方法。
### @property和关联对象结合使用
既然在Category中无法直接使用@property，那有没有什么办法解决呢？答案就是关联对象。

关联对象其实是AssociatedObject的翻译。需要注意的是，关联对象并不是代替了Category中的属性，而是**在Category中@property和关联对象结合使用，以达到正常使用@property的目的**。

文章开头也提到了，关联对象属于Runtime的范畴，因此使用关联对象之前，首先导入runtime头文件
```
#import <objc/runtime.h>
```
然后在实现属性的get/set方法，get/set方法中使用关联对象，代码如下：
```
- (NSString *)personName
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPersonName:(NSString *)personName
{
    objc_setAssociatedObject(self, @selector(personName), personName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
```

现在在程序中使用Category中的属性，可以正常使用：
```
Person *p = [[Person alloc] init];
[p printName];
    
p.personName = @"haha";
NSLog(@"p.personName = %@",p.personName);
```
输出：
```
my name is Person
p.personName = haha
```
这就是关联对象的作用。Category中关联对象和@property结合使用，能够达到在主程序中正常使用Category中属性的目的。
### 关联对象在Runtime中的实现
来看一下关联对象在Runtime中到底是怎么实现的。我们主要通过追踪Runtime开放给我们的接口来探索。上面已经用到了两个接口，分别是：
```
objc_getAssociatedObject
objc_setAssociatedObject
```
除了这两个接口外，还有一个接口：
```
objc_removeAssociatedObjects
```
也就是说，Runtime主要提供了三个方法供我们使用关联对象：
```
// 根据key获取关联对象
id objc_getAssociatedObject(id object, const void *key);
// 以key、value的形式设置关联对象
void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
// 移出对象所有的关联对象
void objc_removeAssociatedObjects(id object);
```
接下来依次分析每个方法。
#### objc_setAssociatedObject
objc_setAssociatedObject方法位于objc-runtime.mm文件中，该方法的实现比较简单，调用了_object_set_associative_reference函数。
```
// 设置关联对象的方法
void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy) {
    _object_set_associative_reference(object, (void *)key, value, policy);
}
```
_object_set_associative_reference函数完成了设置关联对象的操作。在看_object_set_associative_reference函数源码之前，先了解几个结构体代表的含义。
##### ObjcAssociation
ObjcAssociation就是关联对象，在应用层设置、获取关联对象，在Runtime中都被表示成了ObjcAssociation。看一下ObjcAssociation的定义：
```
// ObjcAssociation就是关联对象类
class ObjcAssociation {
    uintptr_t _policy;
    // 值
    id _value;
public:
    // 构造函数
    ObjcAssociation(uintptr_t policy, id value) : _policy(policy), _value(value) {}
    // 默认构造函数，参数分别为0和nil
    ObjcAssociation() : _policy(0), _value(nil) {}
};
```
关联对象中定义了_value和_policy两个变量。_policy之后再说，_value就是关联对象的值，比如上面赋值为@"haha"。
##### AssociationsManager
AssociationsManager可以理解成一个Manager类，看一下AssociationsManager的实现
```
class AssociationsManager {
    // AssociationsManager中只有一个变量AssociationsHashMap
    static AssociationsHashMap *_map;
public:
    // 构造函数中加锁
    AssociationsManager()   { AssociationsManagerLock.lock(); }
    // 析构函数中释放锁
    ~AssociationsManager()  { AssociationsManagerLock.unlock(); }
    // 构造函数、析构函数中加锁、释放锁的操作，保证了AssociationsManager是线程安全的
    
    AssociationsHashMap &associations() {
        // AssociationsHashMap 的实现可以理解成单例对象
        if (_map == NULL)
            _map = new AssociationsHashMap();
        return *_map;
    }
};
```
AssociationsManager中只有一个变量，AssociationsHashMap，通过源码可以看到，AssociationsManager中的AssociationsHashMap的实现可以理解成是单例的。而且AssociationsManager的构造函数和析构函数分别做了加锁、释放锁的操作。也就是说，同一时刻，只能有一个线程操作AssociationsManager中的AssociationsHashMap。

##### AssociationsHashMap
AssociationsHashMap,看名字可以猜到是hashMap类型，那么里面的key、value到底是什么呢？看下AssociationsHashMap的定义：
```
// AssociationsHashMap是字典，key是对象的disguised_ptr_t值，value是ObjectAssociationMap
    class AssociationsHashMap : public unordered_map<disguised_ptr_t, ObjectAssociationMap *, DisguisedPointerHash, DisguisedPointerEqual, AssociationsHashMapAllocator> {
    public:
        void *operator new(size_t n) { return ::malloc(n); }
        void operator delete(void *ptr) { ::free(ptr); }
    };
```
key是对象的DISGUISE()值，value是ObjectAssociationMap。DISGUISE()可以是一个函数，每个对象的DISGUISE()值不同，作为了AssociationsHashMap的key。
##### ObjectAssociationMap
ObjectAssociationMap是map类型，里面也是以key、value的形式存储。看一下ObjectAssociationMap的定义
```
// ObjectAssociationMap是字典，key是从外面传过来的key，例如@selector(hello),value是关联对象，也就是
    // ObjectAssociation
    class ObjectAssociationMap : public std::map<void *, ObjcAssociation, ObjectPointerLess, ObjectAssociationMapAllocator> {
    public:
        void *operator new(size_t n) { return ::malloc(n); }
        void operator delete(void *ptr) { ::free(ptr); }
    };
```
key是从外面传过来的，比如我们上面用到的@selector(personName)，value是上面提到的ObjcAssociation对象，也就是关联对象。终于看到了关联对象，通过下面一整图看一下整个是如何存储的

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE41efd7edc0f3ee0397a8452492be2000/18299)

##### _object_set_associative_reference源码
_object_set_associative_reference函数中根据所传的参数value是否为nil，分成了不同的逻辑。value为nil的逻辑比较简单，我们首先看一下value为nil所做的处理。
###### value = nil

value为nil时的代码：

```
// 初始化一个manager
AssociationsManager manager;
AssociationsHashMap &associations(manager.associations());
// 获取对象的DISGUISE值，作为AssociationsHashMap的key
disguised_ptr_t disguised_object = DISGUISE(object);

// value无值，也就是释放一个key对应的关联对象
AssociationsHashMap::iterator i = associations.find(disguised_object);
if (i !=  associations.end()) {
    ObjectAssociationMap *refs = i->second;
    ObjectAssociationMap::iterator j = refs->find(key);
    if (j != refs->end()) {
        old_association = j->second;
        // 调用erase()方法删除对应的关联对象
        refs->erase(j);
    }
}

// 释放旧的关联对象
if (old_association.hasValue()) ReleaseValue()(old_association);
```
通过代码可以看到，当value'为nil时，Runtime做的操作就是找到原来该key所对应的关联对象，并且将该关联对象删除。也就是说，value为nil，**实际上就是释放一个key对应的关联对象**。
###### value != nil

value不为nil，实际上就是为某个对象添加关联对象。为某个对象添加关联对象，又分为该对象之前已经添加过关联对象和该对象是第一次添加关联对象的逻辑。

1.  该对象第一次添加关联对象
看一下该对象第一次添加关联对象的代码：
```
// 初始化一个manager
AssociationsManager manager;
AssociationsHashMap &associations(manager.associations());
// 获取对象的DISGUISE值，作为AssociationsHashMap的key
disguised_ptr_t disguised_object = DISGUISE(object);

// AssociationsHashMap::iterator 类型的迭代器
AssociationsHashMap::iterator i = associations.find(disguised_object);

// 执行到这里，说明该对象是第一次添加关联对象
 // 初始化ObjectAssociationMap
ObjectAssociationMap *refs = new ObjectAssociationMap;
associations[disguised_object] = refs;
// 赋值
(*refs)[key] = ObjcAssociation(policy, new_value);
// 设置该对象的有关联对象，调用的是setHasAssociatedObjects()方法
object->setHasAssociatedObjects();
```
通过代码可以看到，若该对象是第一次添加关联对象，则先生成新的ObjectAssociationMap，并根据policy、value初始化ObjcAssociation对象，以外部传的key、生成的ObjcAssociation分别作为ObjectAssociationMap的key、value。以DISGUISE(object)、生成的ObjectAssociationMap分别作为AssociationsHashMap的key、value。

2.  该对象不是第一次添加关联对象
若该对象不是第一次添加关联对象，根据原来是否有该key对应的关联对象进行逻辑区分。

    1. 原来有该key对应的关联对象
    代码如下：
    ```
    // 初始化一个manager
    AssociationsManager manager;
    AssociationsHashMap &associations(manager.associations());
    // 获取对象的DISGUISE值，作为AssociationsHashMap的key
    disguised_ptr_t disguised_object = DISGUISE(object);
    
    // AssociationsHashMap::iterator 类型的迭代器
    AssociationsHashMap::iterator i = associations.find(disguised_object);
    
    // 获取到ObjectAssociationMap(key是外部传来的key，value是关联对象类ObjcAssociation)
    ObjectAssociationMap *refs = i->second;
    // ObjectAssociationMap::iterator 类型的迭代器
    ObjectAssociationMap::iterator j = refs->find(key);
    
    // 原来该key对应的有关联对象
    // 将原关联对象的值存起来，并且赋新值
    old_association = j->second;
    j->second = ObjcAssociation(policy, new_value);
    
    // 释放旧的关联对象
    if (old_association.hasValue()) ReleaseValue()(old_association);
    ```
    
    原来有该key所对应的关联对象，所做的处理就是将原来的值存下来，并且赋新的值。最后将原来的值释放。
    
    2. 原来没有该key对应的关联对象
    代码如下：
    ```
    // 初始化一个manager
    AssociationsManager manager;
    AssociationsHashMap &associations(manager.associations());
    // 获取对象的DISGUISE值，作为AssociationsHashMap的key
    disguised_ptr_t disguised_object = DISGUISE(object);
    
    // AssociationsHashMap::iterator 类型的迭代器
    AssociationsHashMap::iterator i = associations.find(disguised_object);
    
    // 获取到ObjectAssociationMap(key是外部传来的key，value是关联对象类ObjcAssociation)
    ObjectAssociationMap *refs = i->second;
    // ObjectAssociationMap::iterator 类型的迭代器
    ObjectAssociationMap::iterator j = refs->find(key);
    
    // 无该key对应的关联对象，直接赋值即可
    // ObjcAssociation(policy, new_value)提供了这样的构造函数
    (*refs)[key] = ObjcAssociation(policy, new_value);
    ```
    原来没有该key所对应的关联对象，直接赋值即可。
##### _object_set_associative_reference流程
看完了_object_set_associative_reference的源码，介绍的比较复杂，其实流程相对来说是比较简单的，整个流程可以用下面的流程图来表示：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCEf73f48ad1393b9321810e0968534cf0d/18379)

##### policy参数
上面已经多次看到了policy参数，policy参数到底代表什么呢？通过上面的介绍，应该可以猜到了policy的作用。在定义一个属性时，需要使用各种各样的修饰符，如nonatomic,copy,strong等，既然关联对象是为了达到和属性相同的效果，那么关联对象是否也应该有对应的修饰符呢？

正是如此，构造关联对象的policy参数，就是类似于属性的修饰符。

我们在应用层设置关联对象时，之前代码用到的值是OBJC_ASSOCIATION_COPY_NONATOMIC，OBJC_ASSOCIATION_COPY_NONATOMIC是枚举类型，其取值有以下几种：
```
typedef OBJC_ENUM(uintptr_t, objc_AssociationPolicy) {
    OBJC_ASSOCIATION_ASSIGN = 0,           /**< Specifies a weak reference to the associated object. */
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, /**< Specifies a strong reference to the associated object. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   /**< Specifies that the associated object is copied. 
                                            *   The association is not made atomically. */
    OBJC_ASSOCIATION_RETAIN = 01401,       /**< Specifies a strong reference to the associated object.
                                            *   The association is made atomically. */
    OBJC_ASSOCIATION_COPY = 01403          /**< Specifies that the associated object is copied.
                                            *   The association is made atomically. */
};
```
根据其注释，可以得出objc_AssociationPolicy与属性修饰符之间的一个对应关系，如下：

![image](https://note.youdao.com/yws/public/resource/bba39d75a3d87a96f65a409a0b99df90/xmlnote/WEBRESOURCE0ef15ad4719412220808f28834237008/18400)

这也是为何我们之前的代码，设置关联对象时，使用OBJC_ASSOCIATION_COPY_NONATOMIC的原因。

关于各种属性修饰符之间的区别，以及什么情景下使用哪种修饰符，可以参考[这篇文章](https://github.com/acBool/Blogs/blob/master/property/%40property%E4%BB%8B%E7%BB%8D.md)。
#### objc_getAssociatedObject
objc_getAssociatedObject方法位于objc-runtime.mm文件中，该方法的实现比较简单，内部直接调用了_object_get_associative_reference函数，代码如下：
```
// 获取关联对象的方法
id objc_getAssociatedObject(id object, const void *key) {
    return _object_get_associative_reference(object, (void *)key);
}
```
##### _object_get_associative_reference函数
获取关联对象的操作都在函数_object_get_associative_reference中。其主要流程是，获取对象的DISGUISE()值，根据该值获取到ObjectAssociationMap。根据外部所传的key，在ObjectAssociationMap中找到key所对应的ObjcAssociation对象，然后得到ObjcAssociation的value。代码如下：
```
id value = nil;
AssociationsManager manager;
// 获取到manager中的AssociationsHashMap
AssociationsHashMap &associations(manager.associations());
// 获取对象的DISGUISE值
disguised_ptr_t disguised_object = DISGUISE(object);
AssociationsHashMap::iterator i = associations.find(disguised_object);

// 获取ObjectAssociationMap
ObjectAssociationMap *refs = i->second;
ObjectAssociationMap::iterator j = refs->find(key);

// 获取到关联对象ObjcAssociation
ObjcAssociation &entry = j->second;
// 获取到value
value = entry.value();

// 返回关联对像的值
return value;
```

#### objc_removeAssociatedObject
objc_removeAssociatedObject位于objc-runtime.mm文件中。注意，**objc_removeAssociatedObject函数的作用是移除某个对象的所有关联对象**。倘若想要移除对象某个key所对应的关联对象，需要**使用objc_setAssociatedObject函数，value传nil**。

objc_removeAssociatedObject的实现比较简单，内部调用了_object_remove_associations函数，代码如下：
```
// 移除对象object的所有关联对象
void objc_removeAssociatedObjects(id object) 
{
    if (object && object->hasAssociatedObjects()) {
        _object_remove_assocations(object);
    }
}
```
##### _object_remove_associations函数
_object_remove_associations函数的逻辑也比较简单，根据对象的DISGUISE()值找到ObjectAssociationMap,然后将该map中的所有值删除。删除时需要先将值存起来，然后再删除，_object_remove_associations函数中使用了vector来存储值。之后再将找到的ObjectAssociationMap删除，代码如下：
```
// 声明了一个vector
vector< ObjcAssociation,ObjcAllocator<ObjcAssociation> > elements;

AssociationsManager manager;
AssociationsHashMap &associations(manager.associations());
// 获取对象的DISGUISE值
disguised_ptr_t disguised_object = DISGUISE(object);
AssociationsHashMap::iterator i = associations.find(disguised_object);

ObjectAssociationMap *refs = i->second;
for (ObjectAssociationMap::iterator j = refs->begin(), end = refs->end(); j != end; ++j) {
    elements.push_back(j->second);
}
// remove the secondary table.
delete refs;
associations.erase(i);

for_each(elements.begin(), elements.end(), ReleaseValue());
```
### 总结
至此，关于关联对象的使用、在Runtime源码中的实现已经全部介绍完毕。实际上，日常的工作中是很难涉及到关联对象的内部实现的。只要掌握Runtime提供给我们的三个接口，使用Category以及关联对象就足以胜任工作项目。不过，对于想要了解Runtime源码的同学来说，掌握关联对象在Runtime源码中的实现，是有很大帮助的。

### 关于Category的面试题
关联对象常常和Category结合使用，因此，最后再介绍几道和Category相关的面试题。

#### Category方法和类方法同名
我们知道，可以在category中为类添加方法，以达到扩展类功能的目的。那么，如果category中的方法名和类中的方法名重复，会发生什么呢？

写代码验证一下：
```
// Student类

@interface Student : NSObject <NSCopying>

- (void)printName;

@end


@implementation Student

- (void)printName
{
    NSLog(@"my name is student");
}


@end

```

Student (Test)类：
```
@interface Student (Test)

- (void)printName;

@end



@implementation Student (Test)

- (void)printName
{
    NSLog(@"my name is studentTest");
}

@end
```
执行代码如下：
```
Student *news = [[Student alloc] init];
[news printName];
```
此时输出的是：
```
my name is studentTest
```
说明执行的是category中的方法。

那么，原来的方法是被覆盖了嘛？

其实，原来的方法并没有被覆盖。了解过Runtime源码的同学应该都知道，无论是类，还是category,在runtime中都用结构体来表示。类表示成结构体后，包含实例方法列表、类方法列表、实例变量列表等信息。category中的方法经过处理后，也被添加到了对应的方法列表中，而且是添加到了原方法位置的前面。

以例子来说，Student类的实例方法列表中有两个printName方法，位于前面的是category中的printName,位于后面的是类的printName。Runtime在寻找方法时，匹配到第一个方法，就不再向后寻找，所以执行的是category中的printName方法。

##### 如何执行原来的方法？
上述情况下，如何执行原来的方法呢？因为原来的方法还存在，所以只需要找到原来的方法即可。

通过Runtime API可以获得一个类的所有方法列表，依次遍历方法列表，对比方法名，位于最后的就是我们所需要的方法。获取方法列表的API是：
```
Class currentClass = [MyClass class];
unsigned int methodCount;
Method *methodList = class_copyMethodList(currentClass, &methodCount);
```

##### 有多个category的情况
如果有多个category，且每个category都有printName方法，那么到底执行哪个方法呢？

验证一下，再加一个category,如下：
```
@interface Student (Test2)

- (void)printName;

@end



@implementation Student (Test2)

- (void)printName
{
    NSLog(@"my name is studentTest 2");
}

@end
```
由上面可知，执行的肯定是category中的方法。不过到底是执行Test还是Test2，是由编译顺序决定的。编译顺序靠后，则所添加的方法在方法列表中越靠前。

如下：

![image](https://github.com/acBool/picture/blob/master/截屏2020-06-24%20下午3.19.20.png?raw=true)

此时的执行结果是：
```
my name is studentTest 2
```

#### category和+load方法
+load方法的调用时机在main函数执行之前，当类被加载的时候。且无论类是否在项目中用到，其+load方法都会被调用。

那么，当类和category中都实现了+load方法，其调用顺序是什么呢？
```
+ (void)load
{
    NSLog(@"student load called");
}


+ (void)load
{
    NSLog(@"student test 1 load called");
}


+ (void)load
{
    NSLog(@"student test 2 load called");
}
```
打印如下：
```
student load called
student test 1 load called
student test 2 load called
```
可知，类的+load方法调用时机要早于category。

不同category的+load方法的调用时机，和类的载入顺序有关，越早被加载，其+load方法的调用时机也越早。

![image](https://github.com/acBool/picture/blob/master/截屏2020-06-24%20下午3.19.20.png?raw=true)

本例中，Student+Test载入的时机早于Student+Test2，所以其+load方法的调用时机也更早。

至于为什么类的+load方法调用时机早于category，可以在dyld和runtime源码中找到答案，由于内容较多，这里不再介绍。

#### category和extension的区别
虽然在写法上，extension看起来像一个匿名的category,但实质上两者有本质的区别。

extension中的内容，在编译期被加入到类中，extension就是类的一部分。必须有类的源码，才能为类添加extension。因此，无法为系统类添加extension。

category是由运行时所决定的。为类添加category，无须知道类的源码，可以为系统类添加category。

另外一个区别是，extension可以添加实例变量，而category无法添加实例变量。因为运行期，对象的内存布局已经确定，如果此时再添加实例变量，会破坏类的内存布局，影响非常大。


### 参考文章
[关联对象 AssociatedObject 完全解析](https://github.com/acBool/analyze/blob/master/contents/objc/%E5%85%B3%E8%81%94%E5%AF%B9%E8%B1%A1%20AssociatedObject%20%E5%AE%8C%E5%85%A8%E8%A7%A3%E6%9E%90.md)
