//
//  SSEasyController.m
//  Beyond
//
//  Created by ZZZ on 2021/9/18.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SSEasyController.h"
#import "SSEasy.h"
#import <pthread.h>

typedef struct SSTestStructInfo_t {
    const char* filename;
    const char* func_name;
    int line;
    const char* tag;
} SSTestStructInfo;

@implementation NSObject (MethodSwizzleTestTo)

+ (void)common_to_method_a:(id)a b:(id)b
{
    ss_easy_log(@"%@", NSStringFromSelector(_cmd));
}

@end

@interface SwizzleTest : NSObject

@property (nonatomic, copy) NSString *name;

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

- (NSString *)test_replace_then_call_original_with_s:(SSTestStructInfo)s text:(NSString *)text
{
    NSString *ret = [NSString stringWithFormat:@"old %@,%@", @(s.line), text];
    ss_easy_log(ret);
    return ret;
}

- (NSString *)test_update_obj:(SwizzleTest *)other
{
    return [NSString stringWithFormat:@"other: %@", other.name];
}

@end

@class MemoryLeak_test1Class, MemoryLeak_test2Class, MemoryLeak_test3Class;
@interface MemoryLeak_test1Class : NSObject

@property (nonatomic, strong) MemoryLeak_test1Class *test1_1;
@property (nonatomic, strong) MemoryLeak_test2Class *test1_2;
@property (nonatomic, strong) MemoryLeak_test3Class *test1_3;

@end

@implementation MemoryLeak_test1Class

@end

@interface MemoryLeak_test2Class : NSObject

@property (nonatomic, strong) MemoryLeak_test1Class *test2_1;
@property (nonatomic, strong) MemoryLeak_test2Class *test2_2;
@property (nonatomic, strong) MemoryLeak_test3Class *test2_3;

@end

@implementation MemoryLeak_test2Class

@end

@interface MemoryLeak_test3Class : NSObject

@property (nonatomic, strong) id test3_1;
@property (nonatomic, strong) id test3_2;
@property (nonatomic, strong) id test3_3;

@end

@implementation MemoryLeak_test3Class

@end

@implementation SSEasyController

+ (void)initialize
{
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak SSEasyController *host = self;
    
    [self test:@"FLEXLiveObjects" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIViewController *c = [[NSClassFromString(@"FLEXLiveObjectsController") alloc] init];
        [host.navigationController pushViewController:c animated:YES];
    }];
    
    [self test:@"制造内存泄漏" tap:^(UIButton *button, NSDictionary *userInfo) {
        MemoryLeak_test1Class *test1 = [[MemoryLeak_test1Class alloc] init];
        test1.test1_2 = [[MemoryLeak_test2Class alloc] init];
        test1.test1_3 = [[MemoryLeak_test3Class alloc] init];
        test1.test1_2.test2_2 = [[MemoryLeak_test2Class alloc] init];
        test1.test1_2.test2_3 = [[MemoryLeak_test3Class alloc] init];
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:@[test1]];
        [array addObject:@[test1]];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        dictionary[@"test_a"] = array;
        dictionary[@"test_b"] = array;
        test1.test1_2.test2_3.test3_1 = dictionary;
    }];
    
    [self test:@"easy alert" tap:^(UIButton *button, NSDictionary *userInfo) {
        ss_easy_alert(^(SSEasyAlertConfiguration *configuration) {
            configuration.title = @"title";
            configuration.message = @"message";
            [configuration addAction:@"custom" handler:^(UIAlertController *alert) {
                ss_easy_log(@"alert action");
            }];
        });
    }];
    
    [self test:@"easy alert + 输入框" tap:^(UIButton *button, NSDictionary *userInfo) {
        ss_easy_alert(^(SSEasyAlertConfiguration *configuration) {
            configuration.title = @"title";
            configuration.message = @"message";
            [configuration addAction:@"custom" handler:^(UIAlertController *alert) {
                ss_easy_log(@"alert action");
            }];
            [configuration addTextFieldWithHandler:^(UITextField *textField) {
                
            }];
        });
    }];
    
    [self test:@"pthread_kill 屏蔽" tap:^(UIButton *button, NSDictionary *userInfo) {
        pthread_kill(pthread_self(), SIGINT);
    }];
    
    [self test:@"替换方法并调用原方法" tap:^(UIButton *button, NSDictionary *userInfo) {
        typedef struct SSStructTemp_t {
            const char* filename;
            const char* func_name;
            int line;
            const char* tag;
        } SSStructTemp;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class c = [SwizzleTest class];
            SEL selector = NSSelectorFromString(@"test_replace_then_call_original_with_s:text:");
            __block IMP imp = NULL;
            imp = ss_method_swizzle(c, selector, ^NSString *(id obj, SSStructTemp s, NSString *text) {
                NSString *ret = [NSString stringWithFormat:@"new %@,%@", @(s.line), text];
                ss_easy_log_text(ret);
                typedef NSString *(*Func)(id obj, SEL selector, SSStructTemp s, NSString *text);
                Func p = (Func)imp;
                ss_easy_log_text(@"====== call original start");
                p(obj, selector, s, text);
                ss_easy_log_text(@"====== call original finish");
                return ret;
            });
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            PRINT_BLANK_LINE
            SwizzleTest *o = [[SwizzleTest alloc] init];
            SSTestStructInfo temp;
            temp.line = 2;
            temp.tag = "mmm";
            NSString *ret = [o test_replace_then_call_original_with_s:temp text:@"6"];
            ss_easy_log(@"done ret: %@", ret);
        });
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
