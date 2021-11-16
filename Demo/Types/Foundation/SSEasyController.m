//
//  SSEasyController.m
//  Beyond
//
//  Created by ZZZ on 2021/9/18.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SSEasyController.h"
#import "SSEasy.h"

@implementation NSObject (MethodSwizzleTestTo)

+ (void)common_to_method_a:(id)a b:(id)b
{
    ss_easy_log(@"%@", NSStringFromSelector(_cmd));
}

@end

@interface SwizzleTest : NSObject

@end

@implementation SwizzleTest

+ (void)cls_void
{
    ss_easy_log(NSStringFromSelector(_cmd));
}

+ (BOOL)cls_bool
{
    ss_easy_log(NSStringFromSelector(_cmd));
    return YES;
}

+ (void)cls_void_f:(float)f d:(double)d rect:(CGRect)r obj:(id)obj
{
    ss_easy_log(NSStringFromSelector(_cmd));
}

+ (id)cls_id_f:(float)f d:(double)d rect:(CGRect)r obj:(id)obj
{
    ss_easy_log(NSStringFromSelector(_cmd));
    return nil;
}

+ (float)cls_f_f:(float)f d:(double)d rect:(CGRect)r obj:(id)obj
{
    ss_easy_log(NSStringFromSelector(_cmd));
    return 0;
}

- (void)obj_void
{
    ss_easy_log(NSStringFromSelector(_cmd));
}

- (BOOL)obj_bool
{
    ss_easy_log(NSStringFromSelector(_cmd));
    return YES;
}

- (void)obj_void_f:(float)f d:(double)d rect:(CGRect)r obj:(id)obj
{
    ss_easy_log(NSStringFromSelector(_cmd));
}

- (id)obj_id_f:(float)f d:(double)d rect:(CGRect)r obj:(id)obj
{
    ss_easy_log(NSStringFromSelector(_cmd));
    return nil;
}

- (long long)obj_f_f:(float)f d:(double)d rect:(CGRect)r obj:(id)obj
{
    ss_easy_log(NSStringFromSelector(_cmd));
    return 0;
}

@end

@implementation SSEasyController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss_easy_install();
        
        ss_method_ignore(@"SwizzleTest", @"cls_void");
        ss_method_ignore(@"SwizzleTest", @"cls_bool");
        ss_method_ignore(@"SwizzleTest", @"cls_void_f:d:rect:obj:");
        ss_method_ignore(@"SwizzleTest", @"cls_id_f:d:rect:obj:");
        ss_method_ignore(@"SwizzleTest", @"cls_f_f:d:rect:obj:");
        ss_method_ignore(@"SwizzleTest", @"obj_void");
        ss_method_ignore(@"SwizzleTest", @"obj_bool");
        ss_method_ignore(@"SwizzleTest", @"obj_void_f:d:rect:obj:");
        ss_method_ignore(@"SwizzleTest", @"obj_id_f:d:rect:obj:");
        ss_method_ignore(@"SwizzleTest", @"obj_f_f:d:rect:obj:");
    });
    
    [self test:@"pthread_kill 屏蔽" tap:^(UIButton *button, NSDictionary *userInfo) {
        pthread_kill(pthread_self(), SIGINT);
    }];
    
    [self test:@"NSAssert 可以继续且只断一次" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSAssert(0, @"NSAssert 可以继续且只断一次");
    }];
    
    [self test:@"NSCAssert 可以继续且只断一次" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSCAssert(0, @"NSCAssert 可以继续且只断一次");
    }];
    
    [self test:@"SafeAssert 可以继续且同内容只断一次" tap:^(UIButton *button, NSDictionary *userInfo) {
        ss_easy_assert_once_for_key(@"SafeAssert 可以继续且同内容只断一次");
    }];
    
    [self test:@"NSException 屏蔽" tap:^(UIButton *button, NSDictionary *userInfo) {
        [NSException raise:@"XXX" format:@"format"];
    }];
    
    [self test:@"ss_method_ignore" tap:^(UIButton *button, NSDictionary *userInfo) {
        for (NSInteger idx = 0; idx < 3; ++idx) {
            CGRect r = CGRectMake(3, 4, 5, 6);
            [SwizzleTest cls_void];
            [SwizzleTest cls_void_f:1 d:2 rect:r obj:@"6"];
            ss_easy_log(@"c1: %d", [SwizzleTest cls_bool]);
            ss_easy_log(@"c2: %f", [SwizzleTest cls_f_f:1 d:2 rect:r obj:@"6"]); // NAN???
            ss_easy_log(@"c3: %@", [SwizzleTest cls_id_f:1 d:2 rect:r obj:@"6"]);
            
            SwizzleTest *obj = [[SwizzleTest alloc] init];
            [obj obj_void];
            ss_easy_log(@"o1: %d", [obj obj_bool]);
            ss_easy_log(@"o2: %f", [obj obj_f_f:1 d:2 rect:r obj:@"6"]);
            ss_easy_log(@"o3: %@", [obj obj_id_f:1 d:2 rect:r obj:@"6"]);
        }
    }];
}

@end
