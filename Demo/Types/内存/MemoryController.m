//
//  MemoryController.m
//  Demo
//
//  Created by SLJ on 2020/6/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "MemoryController.h"

@interface MemoryTestObj : NSObject

@end

@implementation MemoryTestObj

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
}

@end

@interface MemoryController ()

@property (atomic, strong) NSObject *test_obj;

@end

@implementation MemoryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WEAKSELF;
    
    /*
     Run Loop 会在每次 loop 到尾部时销毁 Autorelease Pool。
     GCD 的 dispatched blocks 会在一个 Autorelease Pool 的上下文中执行，这个 Autorelease Pool 不时的就被销毁了（依赖于实现细节）。NSOperationQueue 也是类似。
     其他线程则会各自对他们对应的 Autorelease Pool 的生命周期负责。
     */
    
    [self test:@"NSError autorelease crash" tap:^(UIButton *button, NSDictionary *userInfo) {
        /*
         某些类的方法会隐式地使用自己的 Autorelease Pool，在这种时候使用 __autoreleasing 类型要特别小心。
         比如 NSDictionary 的 enumerateKeysAndObjectsUsingBlock 方法
         */
        NSDictionary *data = @{@"123":@"5"};
        NSError *error = nil;
        [weak_self p_test_autorelease_no_crash:data error:&error];
        [weak_self p_test_autorelease_crash:data error:&error];
    }];
    
    [self test:@"weak autorelease" tap:^(UIButton *button, NSDictionary *userInfo) {
        weak_self.test_obj = [[MemoryTestObj alloc] init];
        __weak id weak_obj = weak_self.test_obj;
        NSLog(@"weak = %p", weak_obj);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"GCD start");
            weak_self.test_obj = nil;
            NSLog(@"GCD finish");
        });
        sleep(1);
        NSLog(@"weak = %p", weak_obj);
    }];
}

- (void)p_test_autorelease_crash:(NSDictionary *)data error:(NSError **)error
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wblock-capture-autoreleasing"
    
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        *error = [NSError errorWithDomain:@"SLJError" code:-1 userInfo:nil];
    }];
    
#pragma clang diagnostic pop
}

- (void)p_test_autorelease_no_crash:(NSDictionary *)data error:(NSError **)error
{
    __block NSError *temp = nil;
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        temp = [NSError errorWithDomain:@"SLJError" code:-1 userInfo:nil];
    }];
    if (error) {
        *error = temp;
    }
}

@end
