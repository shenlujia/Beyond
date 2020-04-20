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

@interface Father : NSObject

@end

@implementation Father

- (Class) class
{
    return [Father class];
}

    @end

    @interface Son : Father

                     @end

                     @implementation Son -
                     (id)init
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

    @interface Student : NSObject @property(nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;
@end

@interface Sark : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) double fNum;
@property (nonatomic, strong) Student *myStudent;
@property (nonatomic, strong) NSNumber *age;

- (void)speak;
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

@implementation ExerciseController

- (void)viewDidLoad
{
    [super viewDidLoad];

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

    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    self.gcd_queue = dispatch_queue_create("gcd", NULL);
    [self test:@"队列线程"
           set:nil
           tap:^(UIButton *button) {
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

    [self test:@"SEL"
           set:nil
           tap:^(UIButton *button) {
               const char *name = [NSString stringWithFormat:@"%@%@", @"viewWillLayoutSubview", @"s"].UTF8String;
               SEL sel = sel_registerName(name);
               const char *out_name = sel_getName(sel);
               assert(strcmp(name, out_name) == 0);
               assert([UIViewController instancesRespondToSelector:sel] == YES);           // OK
               assert([UIViewController instancesRespondToSelector:(SEL)name] == NO);      // ？
               assert([UIViewController instancesRespondToSelector:(SEL)out_name] == YES); // WTF？？？
               assert([UIViewController instanceMethodForSelector:(SEL)name] == _objc_msgForward);

               NSLog(@"======");
               NSLog(@"%p %p", &name, name);
               NSLog(@"%p %p", &sel, sel);
               NSLog(@"%p %p", &out_name, out_name);
               NSLog(@"\n");
           }];
}

@end
