## 探究ARC

`ARC`即OC的自动引用计数技术，通过在编译阶段自动添加引用计数，达到自动管理引用计数的目的。使用ARC可以做到接近垃圾回收的代码编写体验，同时拥有引用计数的性能与效率。

参考资料：[OBJECTIVE-C AUTOMATIC REFERENCE COUNTING (ARC)](https://clang.llvm.org/docs/AutomaticReferenceCounting.html#arc-runtime-objc-retainautorelease)

分析方式，通过`clang`将代码编译，分析`llvm`的中间语言，通过以下命令将代码编译成中间语言：

```
clang -S -fobjc-arc -emit-llvm main.m -o main.ll
```

### 自动添加release

对于一段代码中有声明强引用的对象，如 ：

```
main(){
	id a;
}
```

我们对这段代码进行编译，结果为：

```
; Function Attrs: nounwind ssp uwtable
define i32 @main(i32, i8**) #3 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca i8*, align 8
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  store i8* null, i8** %6, align 8
  store i32 0, i32* %3, align 4
  call void @objc_storeStrong(i8** %6, i8* null) #4
  %7 = load i32, i32* %3, align 4
  ret i32 %7
}
```

`alloca`函数申请内存地址，而`store`表示将值存到指定地址。 函数的最后调用了函数`objc_storeStrong`,我们查阅`clang`文档得知这个函数的实现如下：

```
void objc_storeStrong(id *object, id value) {
  id oldValue = *object;
  value = [value retain];
  *object = value;
  [oldValue release];
}
```

分析代码，这里传入的`object`为`&a`，而`value`为`null`，所以这个函数实际操作为：对`null`进行了`retain`，而对`a`进行了`release`。即释放了`a`对象。

这里我们可以总结，在`__strong`类型的变量的作用域结束时，自动添加`release`函数进行释放。

### 自动添加retain

然后研究赋值语句的实现：

```
id a;
__strong id b = a;
```

这里编译的结果为 ：

```
define i32 @main(i32, i8**) #3 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca i8*, align 8
  %7 = alloca i8*, align 8
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  store i8* null, i8** %6, align 8
  %8 = load i8*, i8** %6, align 8
  %9 = call i8* @objc_retain(i8* %8) #4
  store i8* %9, i8** %7, align 8
  store i32 0, i32* %3, align 4
  call void @objc_storeStrong(i8** %7, i8* null) #4
  call void @objc_storeStrong(i8** %6, i8* null) #4
  %10 = load i32, i32* %3, align 4
  ret i32 %10
}
```

最后调用了两个`objc_storeStrong`进行`release`操作。而其中赋值操作之前被arc添加了函数`objc_retain`,这个函数如其名称所示，实现就是进行`retain`。

如果我们将`b`变量的声明改为`__autoreleasing`，我们会发现编译结果中与上述不同的地方如下：

```
%9 = call i8* @objc_retainAutorelease(i8* %8) #4
```

在赋值之前，调用了函数`objc_retainAutorelease`，这个函数的实现为：

```
id objc_retainAutorelease(id value) {
  return objc_autorelease(objc_retain(value));
}
```

即对一个变量先进行一次`retain`，再添进行`autorelease`。

如果我们将变量`b`的声明改为`__weak`，我们会发现编译结果中与上述不同的地方如下：

```
%9 = call i8* @objc_initWeak(i8** %7, i8* %8) #4
store i32 0, i32* %3, align 4
call void @objc_destroyWeak(i8** %7) #4
```

在为`weak`对象赋值时，调用`objc_initWeak`函数，而在`weak`对象超过作用域时，使用`objc_destroyWeak`进行释放。

最后，我们将变量`b`的声明改为`__unsafe_unretained`,会发现编译结果中，只有`store`对指针进行赋值，并没有其他相关函数的添加，所以`unsafe_unretained`只是单纯的保存指针，不考虑引用计数相关的内存管理问题。

ARC会自动的在赋值语句之前执行一些 引用计数相关的函数，这也就是`ARC`实现的主要原理。

### retain和release的优化

`ARC`对于以`new`,`copy`,`mutableCopy`和`alloc`以及 以这四个单词开头的所有函数，默认认为函数返回值直接持有对象。这是ARC中必须要遵守的命名规则。即对于函数 ：

```
+ (instancetype)creatO {
	id a = [[self alloc] init];
	return a;
}
+ (instancetype)newO {
	id a = [[self alloc] init];
	return a;
}
```

在函数`creatO`中，函数的返回的对象最后一步会自动添加上`autorelease`。而在函数`newO`中，返回的结果就是不带有`autorelease`，是直接持有的对象。

同样，在指针赋值操作上，两者也不同：

```
int main(){
	id a = [Hello newO];
	id b = [Hello creatO];
}
```

这里，赋值前不会对`[Hello newO]`进行操作，因为外面是一个`strong`的指针，而返回的对象已经持有引用计数的。

而对`[Hello creatO]`的返回值需要`retain`，因为函数返回的对象进行了一次`retain`和`autorelease`后，引用计数为0，所以需要进行持有操作。

而ARC对于`id a = [Hello creatO];`这个赋值操作进行了优化，对函数返回处的`autorelease`和赋值处的`retain`进行了优化，对于返回值，使用`objc_autoreleaseReturnValue`函数,对于赋值时使用`objc_retainAutoreleasedReturnValue`函数。

`objc_autoreleaseReturnValue`处理函数返回值，如果在此次调用堆栈后面对这个函数操作的对象执行了`objc_retainAutoreleasedReturnValue`函数，则这里会跳过`autorelease`操作，否则执行`autorelease`操作。

`objc_retainAutoreleasedReturnValue`在赋值处持有返回对象，如果调用堆栈前面有进行`objc_autoreleaseReturnValue`的标记，则跳过`retain`操作，否则执行`retain`操作。

`ARC`还对内存调用函数进行了优化，即`ARC`相关的函数不通过`Objective-C`的消息派发机制，而是直接调用底层的`C`函数。而且`ARC`是在编译器自动添加引用计数函数调用，而不是运行时判断。综上所示，因为这些原因，所以`ARC`性能要优于手动引用计数。

### weak实现

`weak`指针的实现借助`Objective-C`的运行时特性，`runtime`通过 `objc_storeWeak`, `objc_destroyWeak`和 `objc_moveWeak`等方法，直接修改`__weak`对象，来实现弱引用。

`objc_storeWeak`函数，将附有`__weak`标识符的变量的地址注册到`weak`表中，`weak`表是一份与引用计数表相似的散列表。

而该变量会在释放的过程中清理`weak`表中的引用，变量释放调用以下函数：

1. dealloc
2. _objec_rootDealloc
3. object_dispose
4. objc_destructInstance
5. objc_clear_deallocating

在最后的`objc_clear_deallocating`函数中，从`weak`表中找到弱引用指针的地址，然后置为`nil`,并从`weak`表删除记录。

### 1.performSelector内存泄露

当我们直接使用`performSelector:`执行一个传入的`SEL`时，编译器会抛出异常

```
performSelector may cause a leak because its selector is unknown 
```

现在我们了解`ARC`的原理后，就可以解释原因了。

对于函数`performSelector:`，其返回值是`id`，对于以下函数：

```
Hello *b;
b = [a performSelector:sel];
```

我们知道`b`会对`performSelector:`返回的结果调用`retain`操作,在b对象离开作用域时进行一次`release`操作。

而如果`selector`是以 `new`,`copy`,`mutableCopy`和`alloc`开头的，则返回的对象是带有一个引用计数的，则在调用函数处进行了一次`retain` 和`release`后，该对象还是拥有一个引用计数，在`ARC`下就发生了内存泄露。

### 2.注意NSInvocation的返回值

使用`NSInvocation`时，我们通过`- (void)getReturnValue:(void *)retLoc;`获取返回值。但是观察函数声明和函数描述，苹果说，这个函数由于不知道返回值的类型，所以只进行指针赋值，不进行对象的内存管理操作。所以结合`ARC`时我们就要考虑如何避免内存问题。

```
Hello *a = [[Hello alloc] init];
SEL sel = @selector(newO);
NSMethodSignature *signature = [Hello methodSignatureForSelector:sel];
NSInvocation *invoc = [NSInvocation invocationWithMethodSignature:signature];
__strong id returnValue;
invoc.selector = sel;
invoc.target = a;
[invoc invoke];
[invoc getReturnValue:&returnValue];
```

首先当被调用函数是以`new`，`copy`,`mutableCopy`和`alloc`开头的特殊函数时，函数返回的的对象持有引用计数，所以我们设置`returnValue`的类型是`__strong`，这样在这个`returnValue`的作用域结束时，会进行`release`，内存处理正常。

当被调用函数是普通函数时，函数内部最后执行了`autorelease`导致引用计数为0时。所以我们一定要设置`returnValue`的类型为

```
__autoreleasing id returnValue;
```

因为如果设置为`__strong`，则会在`returnValue`的作用域结束时，对这个引用计数为0的对象再进行一次`release`，导致内存问题。

### 3. 对象指针的指针中的__autoreleasing

在函数声明中，对于输出参数是指针的指针的类型，中间一般会自动声明为`__autoreleasing`，如可以在很多函数声明中有NSError参数时，看到如下形式：

```
-(BOOL)performOperationWithError:(NSError * __autoreleasing *)error;
```

虽然苹果的官方文档中没有说明这样做的原因，但是我们查看[clang官方文档](http://clang.llvm.org/docs/AutomaticReferenceCounting.html#indirect-parameters)，可以知道`clang`编译器默认对这种回写参数的对象指针的指针，隐式地添加了`__autoreleasng` 。`clang`文档中是这么说的 ：

> If a function or method parameter has type T*, where T is an ownership-unqualified retainable object pointer type, then: 1.if T is const-qualified or Class, then it is implicitly qualified with __unsafe_unretained; 2.otherwise, it is implicitly qualified with __autoreleasing.

即对于函数回写参数是 对象的指针的指针类型时 ，隐式地添加描述符，

- 如果这个对象是`Class`，则使用`__unsafe_unretained`
- 其他情况，则添加`__autoreleasing` .

在苹果的官方文档中，介绍了ARC中如此处理这种函数，对于原有程序 ：

```
NSError *error;
BOOL OK = [myObject performOperationWithError:&error];
if (!OK) {
	// Report the error.
	// ...
```

ARC会自动添加一个中间变量，改写成 ：

```
NSError * __strong error;
NSError * __autoreleasing tmp = error;
BOOL OK = [myObject performOperationWithError:&tmp];
error = tmp;
if (!OK) {
	// Report the error.
	// ...
```

所以 `NSError * __autoreleasing *` 这种形式是 `Clang`编译器决定的。