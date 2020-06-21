## 动因

上次写代码时需要深入了解Block。发现`Block is nothing but a struct`。今天又拾一下牙慧，汇总一下资料。顺便记录几个源码中的发现

## 值得读的参考

最好的文档
[Clang](http://clang.llvm.org/docs/Block-ABI-Apple.html)
中文的话，这篇也够了,讲得比较细：
[谈Objective-C block的实现](http://blog.devtang.com/2013/07/28/a-look-inside-blocks/)
这篇也讲解得不错：
[Block技巧与底层解析](http://www.jianshu.com/p/51d04b7639f1#)

另外跟本文无关的，这个人的Blog很不错，很多底层知识。
[mikeash](https://www.mikeash.com/)

[源码](http://opensource.apple.com/source/libclosure/libclosure-65/):
[Block_private.h](http://opensource.apple.com/source/libclosure/libclosure-65/Block_private.h)
[runtime.c](http://opensource.apple.com/source/libclosure/libclosure-65/runtime.c)

## 参考代码写在前面

```
enum { // Flags from BlockLiteral
    BLOCK_DEALLOCATING =      (0x0001),  // runtime
    BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    BLOCK_IS_GC =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
    BLOCK_HAS_EXTENDED_LAYOUT=(1 << 31)  // compiler
};

#define BLOCK_DESCRIPTOR_1 1
struct Block_descriptor_1 {
    uintptr_t reserved;
    uintptr_t size;
};

#define BLOCK_DESCRIPTOR_2 1
struct Block_descriptor_2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    void (*copy)(void *dst, const void *src);
    void (*dispose)(const void *);
};

#define BLOCK_DESCRIPTOR_3 1
struct Block_descriptor_3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
    const char *layout;     // contents depend on BLOCK_HAS_EXTENDED_LAYOUT
};

struct Block_layout {
    void *isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved; 
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 *descriptor;
    // imported variables
};
```

## Block中的isa

这也是为什么Block能当做id类型的参数进行传递。

但如Clang文档中所述:

```
The isa field is set to the address of the external _NSConcreteStackBlock, which isa block of uninitialized memory supplied in libSystem, or _NSConcreteGlobalBlock ifthis is a static or file level Block literal.
```

首先_NSConcreteStackBlock是外部的，是libSystem提供的地址，`a block of uninitialized memory`，实际情况是(模拟器)：

```
(lldb) p &_NSConcreteStackBlock
(void *(*)[32]) $25 = 0x00000001108dc050

(lldb) p _NSConcreteStackBlock
(void *[32]) $26 = {
  [0] = 0x00000001108dc0d0
  [1] = 0x000000010e2e6000
  [2] = 0x00007f8b88d0d100
  [3] = 0x0000000400000007
  [4] = 0x00007f8b8aa00310
  [5] = 0x0000000000000000
  [6] = 0x0000000000000000
  [7] = 0x0000000000000000
  [8] = 0x0000000000000000
  [9] = 0x0000000000000000
  [10] = 0x0000000000000000
  [11] = 0x0000000000000000
  [12] = 0x0000000000000000
  [13] = 0x0000000000000000
  [14] = 0x0000000000000000
  [15] = 0x0000000000000000
  [16] = 0x000000010de91198
  [17] = 0x000000010e2e5fd8
  [18] = 0x000000010db4cf70
  [19] = 0x0000000000000000
  [20] = 0x00007f8b8aa00350
  [21] = 0x0000000000000000
  [22] = 0x0000000000000000
  [23] = 0x0000000000000000
  [24] = 0x0000000000000000
  [25] = 0x0000000000000000
  [26] = 0x0000000000000000
  [27] = 0x0000000000000000
  [28] = 0x0000000000000000
  [29] = 0x0000000000000000
  [30] = 0x0000000000000000
  [31] = 0x0000000000000000
}
```

分析之后的结果是这样的：

- 所有`stack Block`的`isa`都指向_NSConcreteStackBlock，runtime的时候已经初始化了。何时初始化未知。
- _NSConcreteStackBlock是个数组，size为32
- 水平有限，没看出规律。应该是被平分成两部分，第二部分从`_NSConcreteStackBlock[16]`开始
- 元素都是Class（废话），如`__NSStackBlock__`,`__NSStackBlock`
- `_NSConcreteGlobalBlock`类似
- 代码也说明了这一点：

```
BLOCK_EXPORT void * _NSConcreteMallocBlock[32]
    __OSX_AVAILABLE_STARTING(__MAC_10_6, __IPHONE_3_2);
BLOCK_EXPORT void * _NSConcreteAutoBlock[32]
    __OSX_AVAILABLE_STARTING(__MAC_10_6, __IPHONE_3_2);
BLOCK_EXPORT void * _NSConcreteFinalizingBlock[32]
    __OSX_AVAILABLE_STARTING(__MAC_10_6, __IPHONE_3_2);
BLOCK_EXPORT void * _NSConcreteWeakBlockVariable[32]
    __OSX_AVAILABLE_STARTING(__MAC_10_6, __IPHONE_3_2);
```

## 关于flags

除了标示Block的类型，还用作reference counting:
`volatile int32_t flags; // contains ref count`
因为最低位被`BLOCK_DEALLOCATING`使用了，所以ref count每次+2

## 关于invoke

看代码:

```
id b = ^(int n, double d, char* s){
    NSLog(@"%d %lf %s",n, d, s);
};
    
((__bridge struct Block_layout*)(b))->invoke((__bridge void *)(b),1,2.345,"hello");
```

官方解释：

```
The invoke function pointer is set to a function that takes the Block structure asits first argument and the rest of the arguments (if any) to the Block and executes the Block compound statement.
```

## Runtime Helper Functions

源码的注释这样说的：

> A Block can reference four different kinds of things that require help when the Block is copied to the heap.
> 1) C++ stack based objects
> 2) References to Objective-C objects
> 3) Other Blocks
> 4) __block variables
>
> In these cases helper functions are synthesized by the compiler for use in Block_copy and Block_release, called the copy and dispose helpers. The copy helper emits a call to the C++ const copy constructor for C++ stack based objects and for the rest calls into the runtime support function _Block_object_assign. The dispose helper has a call to the C++ destructor for case 1 and a call into _Block_object_dispose for the rest.

简单来说，当Block引用了 `1) C++ 栈上对象` `2）OC对象` `3) 其他block对象` `4) __block修饰的变量`，并被拷贝至堆上时则需要copy/dispose辅助函数。辅助函数由编译器生成。
除了case 1，其他三种case都会分别调用下面的函数：

```
void _Block_object_assign(void *destAddr, const void *object, const int flags);
void _Block_object_dispose(const void *object, const int flags);
```

`_Block_object_assign`(或者`_Block_object_dispose`)会根据flags的值来决定调用相应类型的`copy helper`(或者`dispose helper`)
例如：

```
switch (os_assumes(flags & BLOCK_ALL_COPY_DISPOSE_FLAGS)) {
      case BLOCK_FIELD_IS_OBJECT:
        _Block_retain_object(object);
        _Block_assign((void *)object, destAddr);
        break;
      ...
}
```

上述代码中`_Block_retain_object` `_Block_assign`以SPI的形式提供给runtime 和 CoreFoundation进行注入。