### 背景

Objective-C的动态性可以让我们干很多事情。比如[method swizzling](http://nshipster.com/method-swizzling/).
但`method swizzling`有很多负面影响，特别是引入第三方组件后. 如果希望在运行时检测，method是否被swizzling呢？

最近在翻看clang文档时发现可以使用这样一种方法：

### 代码

```
static inline bool is_sel_same(const char *func, SEL _cmd)
{
    char buff[256] = {'\0'};
    if (strlen(func) > 2) {
        char* s = strstr(func, " ") + 1;
        char* e = strstr(func, "]");
        memcpy(buff, s, sizeof(char) * (e - s) );
        return strcmp(buff, sel_getName(_cmd)) == 0;
    }
    return false;
}

#define ALERT_IF_METHOD_REPLACED assert(!is_sel_same(__PRETTY_FUNCTION__, _cmd));
```

### 解释

`__PRETTY_FUNCTION__`是一个编译器的宏，在编译期就由编译器决定了，以`-[MyObject dosth]`为例，在该方法内`__PRETTY_FUNCTION__`为"-[MyObject dosth]".而`_cmd`是方法的隐藏参数，是动态的，同样以`-[MyObject dosth]`为例，`_cmd`为"dosth"，如果我们执行了一下代码：

```
Method ori_method = class_getInstanceMethod([MyObject class], @selector(dosth));
Method replace_method = class_getInstanceMethod([MyObject class], @selector(dosth2));
method_exchangeImplementations(ori_method, replace_method);
```

那么在原来的`-[MyObject dosth]`函数体中，`_cmd`为"dosth2"，而`__PRETTY_FUNCTION__`保持不变。

利用上述特性，前文提到的宏就可以工作了。如下述代码：

```
Method ori_method = class_getInstanceMethod([MyObject class], @selector(dosth));
Method replace_method = class_getInstanceMethod([MyObject class], @selector(dosth2));
method_exchangeImplementations(ori_method, replace_method);

- (void) dosth
{
    ALERT_IF_METHOD_REPLACED;
}

- (void) dosth2
{
    [self dosth2];
}
```

### 总结

然而一般情况下此方法，并没有什么卵用╮(╯_╰)╭　
因为但凡重要的方法，一般是系统方法，如`-[UIViewController viewDidLoad]`,因为无法在该函数体使用上述宏，所以无法检测是否有swizzle。此外如果在`dosth2`中并没有调用`dosth2`,那么也没有效果。

但话分两头，在一些大型项目中，使用此方法可用于检测关键方法是否被二方库三方库Hook。另外，为了防止App中关键方法被恶意注入，此方法也很是有参考价值的。

### 一些参考

这里有一篇讲如何获取当前Method的IMP,[戳这里](http://www.cocoawithlove.com/2008/02/imp-of-current-method.html).试了一下，年代比较久远。可用性已经不太好了。╮(╯_╰)╭　
不过。在作者的实现使用了`__builtin_return_address(0)`,获取当前栈的返回地址。这是值得习得的小技能。

### 后话

后面会继续找一些优雅的检测系统方法被`method swizzling`的情形。IMP相关的东西比较有意思。持续发现中。