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
#import "SDWebImageDecoder.h"

#define SELBuild(a) [a string]
#define SSSEL [PrivateSELBuilder head]

@interface PrivateSELBuilder : NSObject

@property (nonatomic, strong, readonly) NSString *s;
@property (nonatomic, strong, readonly) PrivateSELBuilder *next;
@property (nonatomic, strong, readonly) PrivateSELBuilder *end;

+ (instancetype)head;

- (NSString *)string;

@end

@implementation PrivateSELBuilder

+ (instancetype)head
{
    return [PrivateSELBuilder object:@""];
}

- (NSString *)string
{
    NSString *next = [self.next string];
    if (next) {
        return [NSString stringWithFormat:@"%@%@", self.s, next];
    }
    return self.s;
}

+ (instancetype)object:(NSString *)s
{
    PrivateSELBuilder *obj = [[PrivateSELBuilder alloc] init];
    obj->_s = s;
    return obj;
}

- (PrivateSELBuilder *)A
{
    [self append:@"A"];
    return self;
}

- (void)append:(NSString *)s
{
    PrivateSELBuilder *end = self.end;
    if (!end) {
        end = self;
    }
    end->_next = [PrivateSELBuilder object:s];
    _end = end->_next;
}

- (PrivateSELBuilder *)B
{
    [self append:@"B"];
    return self;
}

@end

static UIColor * kRandomColor()
{
    CGFloat r = (arc4random() % 256) / 255.0;
    CGFloat g = (arc4random() % 256) / 255.0;
    CGFloat b = (arc4random() % 256) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@interface MemoryDeallocObj : NSProxy

@end

@implementation MemoryDeallocObj

- (void)dealloc
{
    NSLog(@"~%@ %@", NSStringFromClass([self class]), [NSThread currentThread]);
}

@end

@interface MemoryDrawRectView : UIView

@end

@implementation MemoryDrawRectView

- (void)drawRect:(CGRect)rect
{
    
}

@end

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
@property (nonatomic, strong) UILabel *label;

@end

static void *s_leakObj = NULL;

@implementation MemoryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *s = SELBuild(SSSEL.A.B.A);
    
    WEAKSELF
    const CGFloat scale = UIScreen.mainScreen.scale;
    
    [self add_navi_right_item:@"push" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIViewController *c = [[MemoryController alloc] init];
        [weak_s.navigationController pushViewController:c animated:YES];
    }];
    [self add_navi_right_item:@"dealloc" tap:^(UIButton *button, NSDictionary *userInfo) {
        __unused MemoryDeallocObj *obj1 = [MemoryDeallocObj alloc];
        __block MemoryDeallocObj *obj2 = [MemoryDeallocObj alloc];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            obj2 = nil;
        });
    }];

    weak_s.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    [weak_s.view addSubview:weak_s.label];
    weak_s.label.textAlignment = NSTextAlignmentCenter;
    weak_s.label.numberOfLines = -1;
    weak_s.label.textColor = UIColor.redColor;
    [weak_s p_printMempry];
    
    /*
     CG内存不会显示在debug navigator里面
     text内存一般为1M maskToBounds、attributedText、textColor无关；如果有透明度的背景色，2M(老版本4M)
     */
    
    [self test:nil tap:nil];
    
    [self test:@"Profile Leaks 能检测泄漏 1" tap:^(UIButton *button, NSDictionary *userInfo) {
        int size = 1024 * 1024;
        void *p = malloc(size);
        SS_MAIN_DELAY(10, ^{
            memset(p, 1, size / 10);
        });
    }];
    
    [self test:@"Profile Leaks 能检测泄漏 2" tap:^(UIButton *button, NSDictionary *userInfo) {
        MemoryTestObj *leakObj1 = [MemoryTestObj new];
        MemoryTestObj *leakObj2 = [MemoryTestObj new];
        leakObj1.leak_obj = leakObj2;
        leakObj2.leak_obj = leakObj1;
    }];
    
    [self test:@"Profile Leaks 不能检测泄漏 1" tap:^(UIButton *button, NSDictionary *userInfo) {
        MemoryTestObj *leakObj1 = [MemoryTestObj new];
        MemoryTestObj *leakObj2 = [MemoryTestObj new];
        leakObj1.leak_obj = leakObj2;
        leakObj2.leak_obj = leakObj1;
        s_leakObj = (__bridge void *)(leakObj1);
    }];
    
    [self test:@"Profile Leaks 不能检测泄漏 2" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s p_test_fail_check_leak];
    }];
    
    [self test:@"text nobkg CA+1M" tap:^(UIButton *button, NSDictionary *userInfo) {
        CGFloat scale = UIScreen.mainScreen.scale;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024 / scale, 1024 / scale)];
        label.text = @"WTF";
        label.textColor = [UIColor colorWithRed:0.1 green:0.2 blue:0.3 alpha:0.6];
        [weak_s.view addSubview:label];
    }];
    
    [self test:@"text bkg CA+1M" tap:^(UIButton *button, NSDictionary *userInfo) {
        CGFloat scale = UIScreen.mainScreen.scale;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024 / scale, 1024 / scale)];
        label.text = @"WTF";
        label.alpha = 0.5;
        [weak_s.view addSubview:label];
    }];
    
    [self test:@"text alpha CA+1M" tap:^(UIButton *button, NSDictionary *userInfo) {
        CGFloat scale = UIScreen.mainScreen.scale;
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024 / scale, 1024 / scale)];
        view.text = @"WTF";
        view.alpha = 0.5;
        [weak_s.view addSubview:view];
        SS_MAIN_DELAY(1, ^{
            NSLog(@"%@", view.layer.contents);
        })
    }];
    
    [self test:@"text bkg_alpha CA+2M(老版本4M)" tap:^(UIButton *button, NSDictionary *userInfo) {
        CGFloat scale = UIScreen.mainScreen.scale;
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024 / scale, 1024 / scale)];
        view.text = @"WTF";
        view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.1];
        [weak_s.view addSubview:view];
        SS_MAIN_DELAY(1, ^{
            NSLog(@"%@", view.layer.contents);
        })
    }];
    
    [self test:@"text clip CA+1M" tap:^(UIButton *button, NSDictionary *userInfo) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024 / scale, 1024 / scale)];
        label.text = @"WTF";
        label.layer.cornerRadius = 5;
        label.clipsToBounds = YES;
        [weak_s.view addSubview:label];
    }];
    
    [self test:@"image只加载 +0M" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"memory_test_1" ofType:@"jpg"];
        __block UIImage *obj = [UIImage imageWithContentsOfFile:path];
        SS_MAIN_DELAY(20, ^{
            obj = nil;
        })
    }];
    
    [self test:@"image提前解码 CG+4M" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"memory_test_1" ofType:@"jpg"];
        UIImage *temp = [UIImage imageWithContentsOfFile:path];
        __block UIImage *obj = [UIImage decodedImageWithImage:temp];
        SS_MAIN_DELAY(20, ^{
            obj = nil;
        })
    }];
    
    [self test:@"image提前解码+显示 CG+4M CA+4M" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"memory_test_1" ofType:@"jpg"];
        UIImage *temp = [UIImage imageWithContentsOfFile:path];
        UIImage *obj = [UIImage decodedImageWithImage:temp];
        UIImageView *view = [[UIImageView alloc] initWithImage:obj];
        view.frame = CGRectMake(100, 100, 100, 100);
        [weak_s.view addSubview:view];
    }];
    
    [self test:@"image显示 新版本会缓存(ImageIO+4M) CA+4M" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"memory_test_1" ofType:@"jpg"];
        UIImage *obj = [UIImage imageWithContentsOfFile:path];
        UIImageView *view = [[UIImageView alloc] initWithImage:obj];
        view.frame = CGRectMake(100, 100, 10, 10);
        [weak_s.view addSubview:view];
    }];
    
    [self test:@"image显示 缓存和path无关和内容有关(ImageIO+4M) CA+4M" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"memory_test_1" ofType:@"jpg"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSString *to_path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        to_path = [to_path stringByAppendingPathComponent:NSDate.date.description];
        [data writeToFile:to_path atomically:YES];
        UIImage *obj = [UIImage imageWithContentsOfFile:to_path];
        UIImageView *view = [[UIImageView alloc] initWithImage:obj];
        view.frame = CGRectMake(100, 100, 10000, 10000);
        [weak_s.view addSubview:view];
        view.alpha = 0.3;
        SS_MAIN_DELAY(1, ^{
            NSLog(@"%@", view.layer.contents);
        })
    }];
    
    [self test:@"无drawRect 有背景色 0M" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 1024 / scale, 1024 / scale)];
        view.backgroundColor = [kRandomColor() colorWithAlphaComponent:0.1];
        [weak_s.view addSubview:view];
        SS_MAIN_DELAY(1, ^{
            NSLog(@"%@", view.layer.contents);
        })
    }];
    
    [self test:@"有drawRect 无背景色 0M" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = [[MemoryDrawRectView alloc] initWithFrame:CGRectMake(100, 100, 1024 / scale, 1024 / scale)];
        [weak_s.view addSubview:view];
        SS_MAIN_DELAY(1, ^{
            NSLog(@"%@", view.layer.contents);
        })
    }];
    
    [self test:@"有drawRect 有背景色 4M" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = [[MemoryDrawRectView alloc] initWithFrame:CGRectMake(100, 100, 1024 / scale, 1024 / scale)];
        [weak_s.view addSubview:view];
        view.backgroundColor = kRandomColor();
        SS_MAIN_DELAY(1, ^{
            NSLog(@"%@", view.layer.contents);
        })
    }];
    
    [self test:@"有drawRect 有alpha背景色 1M" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = [[MemoryDrawRectView alloc] initWithFrame:CGRectMake(100, 100, 1024 / scale, 1024 / scale)];
        [weak_s.view addSubview:view];
        view.backgroundColor = [kRandomColor() colorWithAlphaComponent:0.1];
        SS_MAIN_DELAY(1, ^{
            NSLog(@"%@", view.layer.contents);
        })
    }];
    
    [self test:@"malloc 100M 裸读10M 写10M 实际占用20M" tap:^(UIButton *button, NSDictionary *userInfo) {
        int len = 100 * 1024 * 1024;
        void *address = malloc(len);
        // Resident=0  dirty=0  VirtualSize=100M  物理内存不占用
        SS_MAIN_DELAY(5, ^{
            // Resident=10M  dirty=10M  VirtualSize=100M  裸读10M 写10M 实际占用20M
            for (int i = 0; i < 10 * 1024 * 1024; ++i) {
                *((char *)address + i) = 0xab;
            }
            for (int i = 10 * 1024 * 1024; i < 20 * 1024 * 1024; ++i) {
              __unused int v = *((char *)address + i);
            }
            SS_MAIN_DELAY(5, ^{
                free(address);
            })
        })
    }];
    
    [self test:@"vm_deallocate 100M 裸读10M 写10M 实际占用20M" tap:^(UIButton *button, NSDictionary *userInfo) {
        vm_address_t address;
        vm_size_t size = 100 * 1024 * 1024;
        kern_return_t ret = vm_allocate((vm_map_t)mach_task_self(), &address, size, VM_MAKE_TAG(200) | VM_FLAGS_ANYWHERE);
        assert(ret == 0);
        // Resident=0  dirty=0  VirtualSize=100M  物理内存不占用
        SS_MAIN_DELAY(5, ^{
            // Resident=10M  dirty=10M  VirtualSize=100M  裸读10M 写10M 实际占用20M
            for (int i = 0; i < 10 * 1024 * 1024; ++i) {
                *((char *)address + i) = 0xab;
            }
            for (int i = 10 * 1024 * 1024; i < 20 * 1024 * 1024; ++i) {
              __unused int v = *((char *)address + i);
            }
            SS_MAIN_DELAY(5, ^{
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

- (void)p_printMempry
{
    WEAKSELF
    weak_s.label.text = [self getUsedMemory];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weak_s p_printMempry];
    });
}

- (int64_t)memoryPhysFootprint
{
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t ret = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t)&vmInfo, &count);
    if (ret != KERN_SUCCESS) {
        return 0;
    }
    return vmInfo.phys_footprint;
}

- (NSString *)getUsedMemory
{
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),
                                   MACH_TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if (kerr != KERN_SUCCESS) {
        return nil;
    }
    
    CGFloat resident_size = 1.0 * info.resident_size / 1024 / 1024;
    CGFloat virtual_size = 1.0 * info.virtual_size / 1024 / 1024;
    CGFloat phys_footprint = 1.0 * [self memoryPhysFootprint] / 1024 / 1024;
    return [NSString stringWithFormat:@"virtual[%.1f] resident[%.1f] phys[%.1f]", virtual_size, resident_size, phys_footprint];
}

@end
