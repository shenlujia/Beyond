//
//  MemoryController.m
//  Demo
//
//  Created by SLJ on 2020/6/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "MemoryController.h"
#import <mach/vm_map.h>
#import "MacroHeader.h"
#import "NSObject+Dealloc.h"
#import <mach/mach.h>

@interface MemoryTestObj : NSObject
{
    NSInteger a[1024];
}

@property (nonatomic, strong) void (^block)(void);
@property (nonatomic, strong) MemoryTestObj *leak_obj;

@end

@implementation MemoryTestObj

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
}

+ (MemoryTestObj *)autoreleaseObj
{
    MemoryTestObj *obj = [[MemoryTestObj alloc] init];
    return obj;
}

- (void)emptyFunc
{
    
}

@end

@interface MemoryController ()

@property (atomic, strong) NSObject *test_obj;
@property (nonatomic, strong) MemoryTestObj *leak_test_obj;

@end

static void *s_leakObj = NULL;

@implementation MemoryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WEAKSELF
    
    [self test:@"Profile Leaks 能检测泄漏" tap:^(UIButton *button, NSDictionary *userInfo) {
        MemoryTestObj *leakObj1 = [MemoryTestObj new];
        MemoryTestObj *leakObj2 = [MemoryTestObj new];
        leakObj1.leak_obj = leakObj2;
        leakObj2.leak_obj = leakObj1;
    }];
    
    [self test:@"Profile Leaks 不能检测泄漏" tap:^(UIButton *button, NSDictionary *userInfo) {
        MemoryTestObj *leakObj1 = [MemoryTestObj new];
        MemoryTestObj *leakObj2 = [MemoryTestObj new];
        leakObj1.leak_obj = leakObj2;
        leakObj2.leak_obj = leakObj1;
        s_leakObj = (__bridge void *)(leakObj1);
    }];
    
    [self test:@"Profile Leaks 不能检测泄漏" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s p_test_fail_check_leak];
    }];
    
    [self test:@"Profile Allocations image" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"memory_test_1" ofType:@"jpg"];
        __block UIImage *obj = [UIImage imageWithContentsOfFile:path];
        SS_MAIN_DELAY(100, ^{
            obj = nil;
        })
    }];
    
    [self test:@"Profile Allocations imageView" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"memory_test_1" ofType:@"jpg"];
        UIImage *obj = [UIImage imageWithContentsOfFile:path];
        UIImageView *view = [[UIImageView alloc] initWithImage:obj];
        view.frame = CGRectMake(100, 100, 100, 100);
        [weak_s.view addSubview:view];
        SS_MAIN_DELAY(20, ^{
            [view removeFromSuperview];
        })
    }];
    
    [self test:@"Profile Allocations malloc" tap:^(UIButton *button, NSDictionary *userInfo) {
        void *p = malloc(1024 * 1024);
        SS_MAIN_DELAY(5, ^{
            free(p);
        });
    }];
    
    [self test:@"Profile Allocations new" tap:^(UIButton *button, NSDictionary *userInfo) {
        int len = 1024 * 1024;
        void *p = malloc(len);
        __block NSData *data = [NSData dataWithBytesNoCopy:p length:len];
        SS_MAIN_DELAY(5, ^{
            data = nil;
        })
    }];
    
    [self test:@"Profile Allocations 分配虚拟内存" tap:^(UIButton *button, NSDictionary *userInfo) {
        vm_address_t address;
        vm_size_t size = 100 * 1024 * 1024;
        kern_return_t ret = vm_allocate((vm_map_t)mach_task_self(), &address, size, VM_MAKE_TAG(200) | VM_FLAGS_ANYWHERE);
        assert(ret == 0);
        // Resident=0  dirty=0  VirtualSize=100M  物理内存不占用
        SS_MAIN_DELAY(10, ^{
            // Resident=10M  dirty=10M  VirtualSize=100M  写了10M 实际占用10M
            for (int i = 0; i < 10 * 1024 * 1024; ++i) {
              *((char *)address + i) = 0xab;
            }
            SS_MAIN_DELAY(10, ^{
                vm_deallocate((vm_map_t)mach_task_self(), address, size);
            })
        })
    }];
    
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
        [weak_s p_test_autorelease_no_crash:data error:&error];
        [weak_s p_test_autorelease_crash:data error:&error];
    }];
    
    [self test:@"weak autorelease" tap:^(UIButton *button, NSDictionary *userInfo) {
        weak_s.test_obj = [[MemoryTestObj alloc] init];
        __weak id weak_obj = weak_s.test_obj;
        NSLog(@"weak = %p", weak_obj);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"GCD start");
            weak_s.test_obj = nil;
            NSLog(@"GCD finish");
        });
        sleep(1);
        NSLog(@"weak = %p", weak_obj);
    }];
}

- (void)p_test_fail_check_leak
{
    MemoryTestObj *leakObj = [MemoryTestObj new];
    leakObj.block = ^ {
        NSLog(@"%@", self);
    };
    _leak_test_obj = leakObj;
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
