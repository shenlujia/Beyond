//
//  MemoryDetectController.m
//  Beyond
//
//  Created by ZZZ on 2021/2/4.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "MemoryDetectController.h"
#import "MemoryNonARC.h"
#import "MainThreadSetterChecker.h"

@interface MemoryDetectObj : NSObject

@property (nonatomic, assign) NSInteger tag;

@end

@implementation MemoryDetectObj

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
}

@end

@interface MemoryDetectMain : NSObject
{
@public
    NSInteger a[1024];
    MemoryDetectObj *_raw_obj;
}

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, strong) void (^block)(void);
@property (nonatomic, strong) MemoryDetectObj *obj;
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, strong) NSArray *array;

@end

@implementation MemoryDetectMain

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
}

@end

@interface MemoryDetectController ()

@end

@implementation MemoryDetectController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self test:@"double release obj" tap:^(UIButton *button, NSDictionary *userInfo) {
        static MemoryDetectMain *main = nil;
        main = [[MemoryDetectMain alloc] init];
        MemoryDetectObj *obj = [[MemoryDetectObj alloc] init];
        main.obj = obj;
        [MemoryNonARC releaseObject:obj];
    }];

    [self test:@"double release obj in array" tap:^(UIButton *button, NSDictionary *userInfo) {
        static MemoryDetectMain *main = nil;
        main = [[MemoryDetectMain alloc] init];
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:[[MemoryDetectObj alloc] init]];
        main.array = array;
        for (NSObject *obj in array) {
            [MemoryNonARC releaseObject:obj];
        }
    }];

    [self test:@"double release obj in dictionary" tap:^(UIButton *button, NSDictionary *userInfo) {
        static MemoryDetectMain *main = nil;
        main = [[MemoryDetectMain alloc] init];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        dictionary[@"1"] = [[MemoryDetectObj alloc] init];
        dictionary[@"2"] = [[MemoryDetectObj alloc] init];
        main.dictionary = dictionary;
        for (NSObject *obj in dictionary.allValues) {
            [MemoryNonARC releaseObject:obj];
        }
    }];

    [self test:@"double release obj in block" tap:^(UIButton *button, NSDictionary *userInfo) {
        static MemoryDetectMain *main = nil;
        main = [[MemoryDetectMain alloc] init];
        MemoryDetectObj *obj = [[MemoryDetectObj alloc] init];
        main.block = ^{
            obj.tag = 0;
        };
        [MemoryNonARC releaseObject:obj];
    }];

    [self test:@"double release async" tap:^(UIButton *button, NSDictionary *userInfo) {
        static MemoryDetectMain *main = nil;
        main = [[MemoryDetectMain alloc] init];
        MemoryDetectObj *obj = [[MemoryDetectObj alloc] init];
        main.block = ^{
            obj.tag = 0;
        };
        [MemoryNonARC releaseObject:obj];
    }];

    main_thread_setter_checker_on_class([MemoryDetectMain class]);
    [self test:@"对象非主线程调用监控" set:nil action:@selector(testNotMainThreadClassDetectAction)];
}

- (void)testNotMainThreadClassDetectAction
{
    static MemoryDetectMain *main = nil;
    main = [[MemoryDetectMain alloc] init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        main.array = @[];
        main->_raw_obj = [[MemoryDetectObj alloc] init];
        main.obj = [[MemoryDetectObj alloc] init];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            [MemoryDetectController testNotMainThreadClassDetectAction2:main];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                NSLog(@"current all = %@", main_thread_setter_checker_all_records());
            });
        });
    });
}

+ (void)testNotMainThreadClassDetectAction2:(MemoryDetectMain *)m
{
    m.index = 3;
    m.dictionary = @{@"1" : @"2"};
    m.block = ^{

    };
    m.insets = UIEdgeInsetsMake(5, 5, 5, 5);
}

@end
