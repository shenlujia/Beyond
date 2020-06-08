//
//  ExerciseController.m
//  Demo
//
//  Created by SLJ on 2020/4/11.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ExerciseController.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import "NSObject+MethodSwizzle.h"

@implementation Father

- (void)dealloc
{
    NSLog(@"~dealloc %@", self.from);
}

- (Class)class
{
    return [Father class];
}

+ (Father *)createObject
{
    NSLog(@"-> createObject");
    Father *ret = [[super alloc] init];
    ret.from = @"createObject";
    return ret;
}

- (instancetype)init
{
    self = [super init];
    self.from = @"init";
    return self;
}

+ (Father *)new
{
    NSLog(@"-> new");
    Father *ret = [[super alloc] init];
    ret.from = @"new";
    return ret;
}

+ (Father *)newObject
{
    NSLog(@"-> newObject");
    Father *ret = [[super alloc] init];
    ret.from = @"newObject";
    return ret;
}

+ (Father *)initObject
{
    NSLog(@"-> initObject");
    Father *ret = [[super alloc] init];
    ret.from = @"initObject";
    return ret;
}

@end

    

@implementation Son

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", NSStringFromClass([super class]));
    }
    return self;
}

- (Class) class
{
    return [Son class];
}

@end

@implementation Student

@end

@implementation Sark

- (instancetype)init
{
    if (self = [super init]) {
        _name = @"Lily";
    }
    return self;
}

- (void)speak
{
    NSLog(@"Instance address is %p", self); //  此处如果输出 Instance address is 0x280589860
    // 那么以下该输出什么？？？
    NSLog(@"name address is %p", &_name);
    NSLog(@"fNum address is %p", &_fNum);
    NSLog(@"myStudent address is %p", &_myStudent);
    NSLog(@"age address is %p", &_age);
}

- (void)showYourName
{
    NSLog(@"My name is %@", self.name);
}

@end

@interface ExerciseController ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) dispatch_queue_t gcd_queue;

@end

@implementation NSObject (loadMoreThanOnce)

+ (void)load
{
    NSLog(@"WTF NSObject category load");
}

@end

@implementation ExerciseController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WEAKSELF;

    {
        NSLog(@"ViewController = %@ , 地址 = %p", self, &self);

        //        NSString *myName = @"halfrost";

        id cls = [Sark class];
        NSLog(@"Sark class = %@ 地址 = %p", cls, &cls);

        void *obj = &cls;
        NSLog(@"===Void *obj = %@ 地址 = %p", obj, &obj);

        [(__bridge id)obj showYourName];

        Sark *sark = [[Sark alloc] init];
        NSLog(@"===Sark instance = %@ 地址 = %p", sark, &sark);

        [sark showYourName];
    }

    {
        Class cls = [Sark class];
        void *obj = &cls;
        [(__bridge id)obj showYourName];
        printf("\n");
    }

    {
        __unused Son *s = [Son new];
        printf("\n");
    }

    {
        BOOL res1 = [[NSObject class] isKindOfClass:[NSObject class]];
        BOOL res2 = [[NSObject class] isMemberOfClass:[NSObject class]];
        BOOL res3 = [[Son class] isKindOfClass:[Son class]];
        BOOL res4 = [[Son class] isMemberOfClass:[Son class]];
        NSLog(@"%d %d %d %d", res1, res2, res3, res4);
        printf("\n");
    }

    {
        Sark *sark = [Sark new];
        Sark *sark2 = [Sark new];
        NSLog(@"sark 地址=%p", &sark);   //  此处如果输出 sark 地址=0x7ffee378c640
        NSLog(@"sark2 地址=%p", &sark2); // 那么 sark2 地址=??
        [sark speak];
        [sark2 speak];
        printf("\n");
    }

    {
        Class cls = [Sark class];
        void *obj = &cls;
        [(__bridge id)obj showYourName];
        printf("\n");
    }

    {
        NSMutableString *mutableStr = [NSMutableString string];
        NSString *immutable = nil;
#define _OBJC_TAG_MASK (1UL << 63)
        char c = 'a';
        do {
            [mutableStr appendFormat:@"%c", c++];
            immutable = [mutableStr copy];
            NSLog(@"%p %@ %@", immutable, immutable, immutable.class);
        } while (((uintptr_t)immutable & _OBJC_TAG_MASK) == _OBJC_TAG_MASK);
        printf("\n");

        NSNumber *number1 = @(0x1);
        NSNumber *number2 = @(0x20);
        NSNumber *number3 = @(0x3F);
        NSNumber *numberFFFF = @(0xFFFFFFFFFFEFE);
        NSNumber *maxNum = @(MAXFLOAT);
        float f1 = 5;
        float f2 = 5.1;
        double d1 = 6;
        double d2 = 6.1;
        NSNumber *f1_n = @(f1);
        NSNumber *f2_n = @(f2);
        NSNumber *d1_n = @(d1);
        NSNumber *d2_n = @(d2);

        NSLog(@"number1 pointer is %p class is %@", number1, number1.class);
        NSLog(@"number2 pointer is %p class is %@", number2, number2.class);
        NSLog(@"number3 pointer is %p class is %@", number3, number3.class);
        NSLog(@"numberffff pointer is %p class is %@", numberFFFF, numberFFFF.class);
        NSLog(@"maxNum pointer is %p class is %@", maxNum, maxNum.class);
        printf("\n");

        NSLog(@"f1_n  %p  %p  %@", &f1_n, f1_n, [f1_n class]);
        NSLog(@"f2_n  %p  %p  %@", &f2_n, f2_n, [f2_n class]);
        NSLog(@"d1_n  %p  %p  %@", &d1_n, d1_n, [d1_n class]);
        NSLog(@"d2_n  %p  %p  %@", &d2_n, d2_n, [d2_n class]);
        printf("\n");
    }
    
    [self test:@"performSelector、NSInvocation内存泄漏" tap:^(UIButton *button) {
        // ARC对于以new,copy,mutableCopy和alloc以及 以这四个单词开头的所有函数，默认认为函数返回值直接持有对象
        @autoreleasepool {
            NSLog(@"performSelector createObject");
            [Father performSelector:@selector(createObject)];
            __unused Father *temp = [Father performSelector:@selector(createObject)];
            
            SEL selector = @selector(createObject);
            NSMethodSignature *signature = [Father methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            invocation.selector = selector;
            invocation.target = [Father class];
            [invocation invoke];
        }
        printf("\n");
        @autoreleasepool {
            NSLog(@"performSelector new");
            [Father performSelector:@selector(new)];
            __unused Father *temp = [Father performSelector:@selector(new)];
        }
        printf("\n");
        @autoreleasepool {
            NSLog(@"performSelector init");
            SEL selctor = @selector(init);
            Father *obj = [Father alloc];
            [obj performSelector:selctor];
        }
        printf("\n");
        @autoreleasepool {
            NSLog(@"performSelector initObject");
            [Father performSelector:@selector(initObject)];
            __unused Father *temp = [Father performSelector:@selector(initObject)];
        }
        printf("\n");
        @autoreleasepool {
            NSLog(@"performSelector newObject");
            [Father performSelector:@selector(newObject)];
            __unused Father *temp = [Father performSelector:@selector(newObject)];
            [Father performSelector:@selector(newObject) withObject:nil afterDelay:0];
            [Father performSelector:@selector(newObject) withObject:nil afterDelay:1];
            
            SEL selector = @selector(newObject);
            NSMethodSignature *signature = [Father methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            invocation.selector = selector;
            invocation.target = [Father class];
            [invocation invoke];
            id ret;
            [invocation getReturnValue:&ret];
        }
        printf("\n");
    }];

    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    self.gcd_queue = dispatch_queue_create("gcd", NULL);
    [self test:@"队列线程" tap:^(UIButton *button) {
        [self.queue addOperationWithBlock:^{
            NSThread *t = [NSThread currentThread];
            if (t.name.length == 0) {
                t.name = @"ns_queue";
            }
            NSLog(@"thread: %@", t);
        }];
        dispatch_async(self.gcd_queue, ^{
            NSThread *t = [NSThread currentThread];
            if (t.name.length == 0) {
                t.name = @"gcd_queue";
            }
            NSLog(@"thread: %@", t);
        });
    }];

    [self test:@"SEL" tap:^(UIButton *button) {
        __strong typeof (weak_self) strong_self = weak_self;
        
        const char *name = [NSString stringWithFormat:@"%@%@", @"viewWillLayoutSubview", @"s"].UTF8String;
        SEL sel = sel_registerName(name);
        const char *out_name = sel_getName(sel);
        SEL sel2 = sel_registerName(out_name);
        const char *out_name2 = sel_getName(sel2);
        assert(strcmp(name, out_name) == 0);
        assert([UIViewController instancesRespondToSelector:sel] == YES);           // OK
        assert([UIViewController instancesRespondToSelector:(SEL)name] == NO);      // ？
        assert([UIViewController instancesRespondToSelector:(SEL)out_name] == YES); // WTF？？？
        assert([UIViewController instanceMethodForSelector:(SEL)name] == _objc_msgForward);

        NSLog(@"====== %p", strong_self);
        NSLog(@"%p %p", &name, name);
        NSLog(@"%p %p", &sel, sel);
        NSLog(@"%p %p", &out_name, out_name);
        NSLog(@"%p %p", &sel2, sel2);
        NSLog(@"%p %p", &out_name2, out_name2);
        NSLog(@"\n");
    }];

    //    // 模拟栈溢出
    //    uint8_t buf[1];
    //    for (int i = 0; i < 200; i++) {
    //        NSLog(@"%d", i);
    //        buf[i] = 0;
    //    }
    //    NSLog(@"aha0");
        
    //    // 模拟load多次调用
    void *libHandleIMD = dlopen("/System/Library/PrivateFrameworks/StoreKitUI.framework/StoreKitUI", RTLD_LAZY);
    NSLog(@"libHandleIMD is %p", libHandleIMD);
    if (!libHandleIMD) {
        printf("error is %s\n", dlerror());
    }
    
    [self test:@"alpha测试" tap:^(UIButton *button) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        view.backgroundColor = UIColor.redColor;
        [self.view addSubview:view];
        
        NSLog(@"alpha=%.1f opaque=%@ || opacity=%.1f opaque=%@", view.alpha, @(view.opaque), view.layer.opacity, @(view.layer.opaque));
        view.alpha = 0.3;
        NSLog(@"alpha=%.1f opaque=%@ || opacity=%.1f opaque=%@", view.alpha, @(view.opaque), view.layer.opacity, @(view.layer.opaque));
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"alpha=%.1f opaque=%@ || opacity=%.1f opaque=%@", view.alpha, @(view.opaque), view.layer.opacity, @(view.layer.opaque));
            [view removeFromSuperview];
            NSLog(@"alpha=%.1f opaque=%@ || opacity=%.1f opaque=%@", view.alpha, @(view.opaque), view.layer.opacity, @(view.layer.opaque));
        });
    }];
}

@end
