AutoreleasePool对于iOS开发者来说，可以说是"熟悉的陌生人"。熟悉是因为每个iOS程序都被包围在一个autoreleasepool中，陌生是因为整个autoreleasepool是黑盒的，开发者看不到autoreleasepool中发生了什么，而且项目开发中直接用到autoreleasepool的地方不多。本文结合Runtime源码，分析一下AutoreleasePool的内部实现。
### iOS程序入口
我们都知道，iOS程序的入口是main.m文件中的main方法。在Xcode中新建一个iOS项目，Xcode会自动生成main.m文件。main.m文件中只有一个main方法，绝大多数情况下，不需要修改main.m中的代码。

一个典型的main函数：
```
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```
可以看到，main函数的函数体是包含在一个autoreleasepool中的。可惜的是，通过command + 鼠标左键，并不能看到autoreleasepool的定义。不过我们可以使用clang,将main.m文件编译成C++代码，看看autoreleasepool发生了什么。

使用命令：
```
clang -rewrite-objc main.m
```
生成main.cpp文件。

生成的main.cpp文件很大，大概有10w行，不需要关注文件到底有多少行。将文件拖到最下面，看一下main函数变成了什么：
```
int main(int argc, char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_09_mbt6ttpn7_39cpx9j6zg6h440000gp_T_main_f1e080_mi_0);
        return 0;

    }
}
```
整个函数的函数体被包围在了__AtAutoreleasePoool __autoreleasepool中。而且前面有关于@autoreleasepool的注释，因此可以猜测autoreleasepool被表示成了__AtAutoreleasePool。

在main.cpp中搜索一下，看看__AtAutoreleasePool是什么。
```
struct __AtAutoreleasePool {
  __AtAutoreleasePool() {atautoreleasepoolobj = objc_autoreleasePoolPush();}
  ~__AtAutoreleasePool() {objc_autoreleasePoolPop(atautoreleasepoolobj);}
  void * atautoreleasepoolobj;
};
```
__AtAutoreleasePool是一个结构体，结构体中包含构造函数和析构函数。构造函数中调用了
```
atautoreleasepoolobj = objc_autoreleasePoolPush();
```
析构函数中调用了
```
objc_autoreleasePoolPop(atautoreleasepoolobj);
```
于是，关注的重点就成了objc_autoreleasePoolPush和objc_autoreleasePoolPop函数。

objc_autoreleasePoolPush和objc_autoreleasePoolPop函数在Runtime源码中可以找到，位于NSObject.mm文件中。

### AutoreleasePoolPage
看一下Runtime源码中objc_autoreleasePoolPush和objc_autoreleasePoolPop函数的实现。
```
void * objc_autoreleasePoolPush(void)
{
    // 调用了AutoreleasePoolPage中的push方法
    return AutoreleasePoolPage::push();
}

void objc_autoreleasePoolPop(void *ctxt)
{
    // 调用了AutoreleasePoolPage中的pop方法
    AutoreleasePoolPage::pop(ctxt);
}
```
通过源码可以看到分别调用了AutoreleasePoolPage的push方法和pop方法。
#### AutoreleasePoolPage的定义
AutoreleasePoolPage的定义位于NSObject.mm文件中：
```
// AutoreleasePoolPage的大小是4096字节
class AutoreleasePoolPage 
{
#   define EMPTY_POOL_PLACEHOLDER ((id*)1)

    // 哨兵对象
#   define POOL_BOUNDARY nil
    static pthread_key_t const key = AUTORELEASE_POOL_KEY;
    static uint8_t const SCRIBBLE = 0xA3;  // 0xA3A3A3A3 after releasing
    // AutoreleasePoolPage的大小，通过宏定义，可以看到是4096字节
    static size_t const SIZE =
#if PROTECT_AUTORELEASEPOOL
        PAGE_MAX_SIZE;  // must be multiple of vm page size
#else
        PAGE_MAX_SIZE;  // size and alignment, power of 2
#endif
    static size_t const COUNT = SIZE / sizeof(id);

    magic_t const magic;
    // 一个AutoreleasePoolPage中会存储多个对象
    // next指向的是下一个AutoreleasePoolPage中下一个为空的内存地址（新来的对象会存储到next处）
    id *next;
    // 保存了当前页所在的线程(一个AutoreleasePoolPage属于一个线程，一个线程中可以有多个AutoreleasePoolPage)
    pthread_t const thread;
    // AutoreleasePoolPage是以双向链表的形式连接
    // 前一个节点
    AutoreleasePoolPage * const parent;
    // 后一个节点
    AutoreleasePoolPage *child;
    uint32_t const depth;
    uint32_t hiwat;
}
```
除此之外，还定义了很多方法，方法的作用及实现下面会分析。

在上面的定义中，我已经加了些注释。通过注释可以得到：
1. 一个AutoreleasePoolPage的大小是4096字节（和操作系统中一页的大小一致）。
2. parent指针和child指针特别有意思，指向的同样是AutoreleasePoolPage，如果对数据结构比较熟悉的话，看到类似的定义，应该可以联想到双向链表或者树结构。实际上也正是如此，下面我们会提到AutoreleasePoolPage组成的双向链表。
3. thread表示当前AutoreleasePoolPage所属的线程。
4. next指针指向了下一个空的地址。一个AutoreleasePoolPage中可以存储多个对象地址，新来的对象地址会存放到next处，然后next移动到下一个地址。这样的操作有没有联想到哪种数据结构？是不是和栈的top指针特别类似？

对AutoreleasePoolPage的定义有了基本的了解之后，来看一下push方法和pop方法。
#### AutoreleasePoolPage::push方法
AutoreleasePoolPage中的push方法，经过简化之后如下：
```
static inline void *push() 
{
    id *dest;
    // POOL_BOUNDARY其实就是nil
    dest = autoreleaseFast(POOL_BOUNDARY);
    return dest;
}
```
push方法中主要调用了autoreleaseFast方法，所传入的参数是POOL_BOUNDARY，也就是nil。看你一下autoreleaseFast方法的实现。
```
static inline id *autoreleaseFast(id obj)
{
    // hotPage就是当前正在使用的AutoreleasePoolPage
    AutoreleasePoolPage *page = hotPage();
    if (page && !page->full()) {
        // 有hotPage且hotPage不满，将对象添加到hotPage中
        return page->add(obj);
    } else if (page) {
        // 有hotPage但是hotPage已满
        // 使用autoreleaseFullPage初始化一个新页，并将对象添加到新的AutoreleasePoolPage中
        return autoreleaseFullPage(obj, page);
    } else {
        // 无hotPage
        // 使用autoreleaseNoPage创建一个hotPage,并将对象添加到新创建的page中
        return autoreleaseNoPage(obj);
    }
}
```
我在代码中已经加入了注释，再来看一下里面涉及到的一些方法。
##### hotPage方法
```
// 获取正在使用的AutoreleasePoolPage
static inline AutoreleasePoolPage *hotPage() 
{
    AutoreleasePoolPage *result = (AutoreleasePoolPage *)
        tls_get_direct(key);
    if ((id *)result == EMPTY_POOL_PLACEHOLDER) return nil;
    if (result) result->fastcheck();
    return result;
}
```
hotPage可以理解成当前正在使用的page。上面也提到了，AutoreleasePoolPage中有parent和child指针，实际上AutoreleasePool就是由一个个AutoreleasePoolPage组成的双向链表。这里得到的hotPage可以理解成链表最末尾的结点。

获取hotPage的方法是tls_get_direct(key)，key是AutoreleasePoolPage结构中定义的
```
static pthread_key_t const key = AUTORELEASE_POOL_KEY;
```
##### setHotPage方法
```
static inline void setHotPage(AutoreleasePoolPage *page) 
{
    if (page) page->fastcheck();
    tls_set_direct(key, (void *)page);
}
```
将某个page设置成hotPage。
##### full方法
```
// 是否已满
bool full() { 
    return next == end();
}
```
判断当前的AutoreleasePoolPage是否已满。判断标准是next等于AutoreleasePoolPage的尾地址。上面已经提到了，AutoreleasePoolPage的大小是4096字节，既然大小是固定的，那么肯定有满的一刻，full方法就是用来做这个得。
##### add方法
```
// 将对象添加到AutoreleasePoolPage中
id *add(id obj)
{
    id *ret = next;  // faster than `return next-1` because of aliasing
    // next = obj; next++;
    // 也就是将obj存放在next处，并将next指向下一个位置
    *next++ = obj;
    return ret;
}
```
add方法所做的操作也比较简单，就是将当前对象存放在next指向的位置，并且将next指向下一个位置。可以理解成一个栈，next指针类似于栈的top指针。
##### autoreleaseFullPage方法
```
// 新建一个AutoreleasePoolPage，并将obj添加到新的AutoreleasePoolPage中
// 参数page是新AutoreleasePoolPage的父节点
static __attribute__((noinline))
id *autoreleaseFullPage(id obj, AutoreleasePoolPage *page)
{
    do {
        // 如果page->child存在，那么使用page->child
        if (page->child) page = page->child;
        // 否则的话，初始化一个新的AutoreleasePoolPage
        else page = new AutoreleasePoolPage(page);
    } while (page->full());
    // 将找到的合适的page设置成hotPage
    setHotPage(page);
    // 将对象添加到hotPage中
    return page->add(obj);
}
```
autoreleaseFullPage所做的操作有三步：
1. 首先找到一个合适的AutoreleasePoolPage，这里合适的page指的是不满的page。具体找的过程是从传过来的参数page的child开始找，如果page->child存在，则判断page->child是否是合适的page；如果page->child不存在，则初始化一个新的AutoreleasePoolPage,这里使用的是AutoreleasePoolPage的构造函数，传入的page是新的AutoreleasePoolPage的父节点。
2. 将找到的AutoreleasePoolPage对象设置成hotPage
3. 调用add方法，将对象添加到找到的page中

##### autoreleaseNoPage方法
```
// AutoreleasePool中还没有AutoreleasePoolPage
static __attribute__((noinline))
id *autoreleaseNoPage(id obj)
{
    // 初始化一个AutoreleasePoolPage
    // 当前内存中不存在AutoreleasePoolPage,则从头开始构建AutoreleasePoolPage,也就是其parent为nil
    AutoreleasePoolPage *page = new AutoreleasePoolPage(nil);
    // 将初始化的AutoreleasePoolPage设置成hotPage
    setHotPage(page);
    
    // Push a boundary on behalf of the previously-placeholder'd pool.
    // 添加一个边界对象（nil）
    if (pushExtraBoundary) {
        page->add(POOL_BOUNDARY);
    }
    
    // Push the requested object or pool.
    // 将对象添加到AutoreleasePoolPage中
    return page->add(obj);
}
```
autoreleaseNoPage方法处理的是当前autoreleasePool中还没有autoreleasePoolPage的情况。既然没有，需要新建一个AutoreleasePoolPage,且该page的父指针指向空，然后将该page设置成hotPage。之后向该page中先是添加了POOL_BOUNDARY，然后在把对象obj添加到page中。

关于为什么需要添加POOL_BOUNDARY的原因，后面会说到。

现在已经把autoreleaseFast方法中涉及到的方法都弄明白了，再来看一下autoreleaseFast方法做的操作。
```
static inline id *autoreleaseFast(id obj)
{
    // hotPage就是当前正在使用的AutoreleasePoolPage
    AutoreleasePoolPage *page = hotPage();
    if (page && !page->full()) {
        // 有hotPage且hotPage不满，将对象添加到hotPage中
        return page->add(obj);
    } else if (page) {
        // 有hotPage但是hotPage已满
        // 使用autoreleaseFullPage初始化一个新页，并将对象添加到新的AutoreleasePoolPage中
        return autoreleaseFullPage(obj, page);
    } else {
        // 无hotPage
        // 使用autoreleaseNoPage创建一个hotPage,并将对象添加到新创建的page中
        return autoreleaseNoPage(obj);
    }
}
```
autoreleaseFast方法首先找到hotPage，也就是当前的page，之后分为三种情况：
1.  如果hotPage存在，且hotPage还不满，则将对象添加到hotPage中
2.  如果hotPage存在，但是hotPage已满，则调用autoreleaseFullPage方法
    autoreleaseFullPage方法上面已经说了，做的操作就是从page开始找，找到一个不满的page，将找到的page设置成hotPage,并且将对象添加到找到的page中。
3.  如果hotPage不存在，则调用autoreleaseNoPage方法
    autoreleaseNoPage方法上面说了，做的操作就是新建一个AutoreleasePoolPage,并且将对象添加到新建的AutoreleasePoolPage中。

至此，AutoreleasePoolPage的push方法介绍完毕。
#### AutoreleasePoolPage::pop方法
AutoreleasePoolPage::pop方法的代码经过简化之后如下：
```
static inline void pop(void *token) 
{
    AutoreleasePoolPage *page;
    id *stop;
    page = pageForPointer(token);
    stop = (id *)token;
    page->releaseUntil(stop);
}
```
同理，还是先看一下里面调用到的方法的实现。不过，在介绍pop内部调用的方法之前，先来看一下pop方法中的参数到底是什么。

在文章开始处，我们是从clang重写之后的main.cpp文件引入到Runtime源码的，现在再回过去看一下main.cpp文件中的__AtAutoreleasePool结构体：
```
struct __AtAutoreleasePool {
  __AtAutoreleasePool() {atautoreleasepoolobj = objc_autoreleasePoolPush();}
  ~__AtAutoreleasePool() {objc_autoreleasePoolPop(atautoreleasepoolobj);}
  void * atautoreleasepoolobj;
};
```
objc_autoreleasePoolPop中的参数是atautoreleasepoolobj，而atautoreleasepoolobj是objc_autoreleasePoolPush方法返回的。也就是说，AutoreleasePoolPage中pop方法的参数是AutoreleasePoolPage中push方法返回的，比较拗口，可以多理解一下。那么，AutoreleasePoolPage中push方法返回的是什么呢？

上面已经介绍过push方法了，push方法内部分为了三种情况，无论哪种情况，最终都调用了add方法，并且返回了add方法的返回值。add方法的实现如下：
```
id *add(id obj)
{
    id *ret = next;  // faster than `return next-1` because of aliasing
    // next = obj; next++;
    // 也就是将obj存放在next处，并将next指向下一个位置
    *next++ = obj;
    return ret;
}
```
add方法返回的就是所要添加对象在AutoreleasePoolPage中的地址。

而在push方法中，添加的对象是哨兵对象POOL_BOUNDARY,所以，在pop方法中，参数也是哨兵对象POOL_BOUNDARY。
##### pageForPointer方法
pageForPointer的代码如下：
```
static AutoreleasePoolPage *pageForPointer(const void *p) 
{
    // 调用了pageForPointer方法
    return pageForPointer((uintptr_t)p);
}

// 根据内存地址，获取指针所在的AutoreleasePage的首地址
static AutoreleasePoolPage *pageForPointer(uintptr_t p) 
{
    AutoreleasePoolPage *result;
    // 偏移量
    uintptr_t offset = p % SIZE;
    result = (AutoreleasePoolPage *)(p - offset);
    result->fastcheck();
    return result;
}
```
pageForPointer方法的作用是根据指针位置，找到该指针位于哪个AutoreleasePoolPage，并返回找到的AutoreleasePoolPage(之前已经提到了，AutoreleasePool是由一个个AutoreleasePoolPage组成的双向链表，不止一个AutoreleasePoolPage)。
##### releaseUntil方法
releaseUntil方法的代码如下：
```
// 释放对象
// 这里需要注意的是，因为AutoreleasePool实际上就是由AutoreleasePoolPage组成的双向链表
// 因此，*stop可能不是在最新的AutoreleasePoolPage中，也就是下面的hotPage，这时需要从hotPage
// 开始，一直释放，直到stop，中间所经过的所有AutoreleasePoolPage,里面的对象都要释放
void releaseUntil(id *stop) 
{
    // 释放AutoreleasePoolPage中的对象，直到next指向stop
    while (this->next != stop) {
        // hotPage可以理解为当前正在使用的page
        AutoreleasePoolPage *page = hotPage();

        // fixme I think this `while` can be `if`, but I can't prove it
        // 如果page为空的话，将page指向上一个page
        // 注释写到猜测这里可以使用if，我感觉也可以使用if
        // 因为根据AutoreleasePoolPage的结构，理论上不可能存在连续两个page都为空
        while (page->empty()) {
            page = page->parent;
            setHotPage(page);
        }
        // obj = page->next; page->next--;
        id obj = *--page->next;
        memset((void*)page->next, SCRIBBLE, sizeof(*page->next));

        // POOL_BOUNDARY为nil，是哨兵对象
        if (obj != POOL_BOUNDARY) {
            // 释放obj对象
            objc_release(obj);
        }
    }
    // 重新设置hotPage
    setHotPage(this);
}
```
代码中我已经加了注释，releaseUntil做的操作就是持续释放AutoreleasePoolPage中的对象，直到next = stop。

回过头来再来看一下pop方法：
```
static inline void pop(void *token) 
{
    AutoreleasePoolPage *page;
    id *stop;
    page = pageForPointer(token);
    stop = (id *)token;
    page->releaseUntil(stop);
}
```
pop方法中主要做了两步：
1. 根据token，也就是哨兵对象找到该哨兵对象所处的page
2. 从hotPage开始，一直删除到第一步找到的page.next==stop（哨兵对象）的位置

至此，关于AutoreleasePoolPage以及其中的关键方法就全部介绍完毕了。如果到这里，关于AutoreleasePool、AutoreleasePoolPage、哨兵对象还有点蒙的话，不要着急，继续往下看。
### AutoreleasePool和AutoreleasePoolPage的关系
实际上，Runtime中并没有AutoreleasePool结构的定义，AutoreleasePool是由AutoreleasePoolPage组成的双向链表，如下图：

![image](https://github.com/acBool/picture/blob/master/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7%202019-04-26%20%E4%B8%8B%E5%8D%885.52.57.png)

在autoreleasepool的开始处，会调用AutoreleasePoolPage的push方法；在autoreleasepool的结束处，会调用AutoreleasePoolPage的pop方法。在AutoreleasePoolPage的push方法中，会往AutoreleasePoolPage中插入哨兵对象，之后的对象依次插入到AutoreleasePoolPage中。如下表示：
```
AutoreleasePoolPage::push(); // 这里会向AutoreleasePoolPage中插入哨兵对象
*** // 开发者自己写的代码，代码中的对象会依次插入到AutoreleasePoolPage中
***
AutoreleasePoolPage::pop(nil);
```
当AutoreleasePoolPage满之后，会新建一个AutoreleasePoolPage，继续将对象添加到新的AutoreleasePoolPage中。

通过上面的介绍，可以知道，AutoreleasePool由多个AutoreleasePoolPage组成，且AutoreleasePool的开始处必定是一个哨兵对象。到这里，哨兵对象的作用也就清楚了，哨兵对象是用来分隔不同的AutoreleasePool的。

当调用AutoreleasePoolPage::pop(nil)方法时，会从某个autoreleasepool开始，一直释放到参数哨兵对象所属的autoreleasepool。可以是同一个autoreleasepool，也可以不是同一个autoreleasepool,当不是同一个autoreleasepool时，可以理解成是嵌套autoreleasepool释放。

到这里，AutoreleasePool、AutoreleasePoolPage、哨兵对象之间的关系应该就理解了。
### 关于AutoreleasePool的一些面试题
AutoreleasePool在面试中出现的频率也非常高，接下来分享几道关于AutoreleasePool的面试题。
#### AutoreleasePool和线程的关系
确切地说，应该是AutoreleasePoolPage和线程的关系。AutoreleasePool是由AutoreleasePoolPage组成的双向链表，根据AutoreleasePoolPage的定义，每一个AutoreleasePoolPage都属于一个特定的线程。也就是说，一个线程可以有多个AutoreleasePoolPage，但是一个AutoreleasePoolPage只能属于一个线程。
#### AutoreleasePool和Runloop的关系
Runloop,即运行循环。从直观上看，RunLoop和AutoreleasePool似乎没什么关系，其实不然。在一个完整的RunLoop中，RunLoop开始的时候，会创建一个AutoreleasePool，在RunLoop运行期间，autorelease对象会加入到自动释放池中。在RunLoop结束之前，AutoreleasePool会被销毁，也就是调用AutoreleasePoolPage::pop方法，在该方法中，自动释放池中的所有对象会收到release消息。正常情况下，AutoreleasePool中的对象发送完release消息后，引用计数应该为0，会被释放，如果引用计数不为0，则发生了内存泄露。
#### AutoreleasePool中对象什么时候释放？
其实上面已经说过了，AutoreleasePool销毁时，AutoreleasePool中的所有对象都会发送release消息，对象会释放。那么，AutoreleasePool什么时候销毁呢？分两种情况：
1.  一种情况就是上面提到的，当前RunLoop结束之前，AutoreleasePool会销毁。这种情况适用于系统自动生成的AutoreleasePool。
2.  第二种情况是开发者自己写的AutoreleasePool，常见于for循环中，将循环体包在一个AutoreleasePool中。这种情况下，在AutoreleasePool作用域之后（也就是大括号），AutoreleasePool会销毁。
