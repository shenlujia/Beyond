//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyAssert.h"
#import "SSEasyException.h"
#import "SSEasyHook.h"
#import "SSEasyLog.h"
#import <UIKit/UIKit.h>

//@implementation AWEBaseSettings (Byebye)
//
//- (BOOL)f_boolValueForKeyPath:(NSString *)keyPath defaultValue:(BOOL)defaultValue stable:(BOOL)stable
//{
//    return [keyPath isEqualToString:@"aweme_base_conf.enable_biz_network_alog"] ? NO : [self f_boolValueForKeyPath:keyPath defaultValue:defaultValue stable:stable];
//}
//
//@end

@implementation UIViewController (SSEasy)

- (void)ss_dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [self ss_dismissViewControllerAnimated:flag completion:completion];
}

- (void)ss_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    [self ss_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end

@implementation UINavigationController (SSEasy)

- (void)ss_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self ss_pushViewController:viewController animated:animated];
}

- (UIViewController *)ss_popViewControllerAnimated:(BOOL)animated
{
    return [self ss_popViewControllerAnimated:animated];
}

- (NSArray *)ss_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    return [self ss_popToViewController:viewController animated:animated];
}

- (NSArray *)ss_popToRootViewControllerAnimated:(BOOL)animated
{
    return [self ss_popToRootViewControllerAnimated:animated];
}

@end

static void p_modify_values()
{
    extern bool isTTVideoEngineLogEnabled;
    isTTVideoEngineLogEnabled = NO;

    extern void alog_close(void);
    alog_close();

    extern void hmd_disable_cpp_exception_backtrace(void);
    hmd_disable_cpp_exception_backtrace(); // 300M+ memory
}

static void p_ignore_objc_method()
{
    ss_method_ignore(@"ACCMemoryMonitor", @"startCheckMemoryLeaks:");
    ss_method_ignore(@"ACCMemoryMonitor", @"startMemoryMonitorForContext:tartgetClasses:maxInstanceCount:");
    ss_method_ignore(@"ACCMemoryMonitor", @"addObject:forContext:");
    ss_method_ignore(@"ACCMemoryMonitor", @"stopMemoryMonitorForContext:");
    
    ss_method_ignore(@"AWEACCTrackerImpl", @"logTrackerEvent:params:");
    
    ss_method_ignore(@"AWEJSBridge", @"debug_bridgeDicAssert:method:");
    
    ss_method_ignore(@"Heimdallr", @"shared");
    ss_method_ignore(@"HMDConfigManager", @"sharedInstance"); // 屏蔽所有HeimdallrModule子类
    
    ss_method_ignore(@"KiteLogControl", @"isEnabled");
}

static void p_swizzle_objc_method()
{
    void (^swizzle)(Class c, NSString *method) = ^(Class c, NSString *method) {
        SEL original = NSSelectorFromString(method);
        SEL other = NSSelectorFromString([NSString stringWithFormat:@"ss_%@", method]);
        [c ss_swizzleMethod:original withMethod:other];
    };
    
    swizzle([UIViewController class], @"presentViewController:animated:completion:");
    swizzle([UIViewController class], @"dismissViewControllerAnimated:completion:");

    swizzle([UINavigationController class], @"pushViewController:animated:");
    swizzle([UINavigationController class], @"popViewControllerAnimated:animated:");
    swizzle([UINavigationController class], @"popToRootViewControllerAnimated:");
}

static void p_replace_objc_method()
{
    { // HOOK打点方法 并屏蔽一些刷屏的点
        static NSMutableSet *ignore_events = nil;
        static NSMutableSet *ignore_prefixes = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableSet *events = [NSMutableSet set];
            [events addObject:@"smart_scan_capture_duration"];
            ignore_events = [events copy];
            NSMutableSet *prefixes = [NSMutableSet set];
            [prefixes addObject:@"vesdk_"];
            ignore_prefixes = [prefixes copy];
        });
        SEL method = NSSelectorFromString(@"trackEvent:params:to:");
        ss_method_swizzle(NSClassFromString(@"TrackerService"), method, ^(id a, NSString *event, id p) {
            static NSMutableSet *test_events = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                test_events = [NSMutableSet set];
            });
            if (test_events && event && [test_events containsObject:event]) {
                SSEasyLog(@"断点太慢 直接设置test_events方便调试 event:%@", event);
            }
            if (!event) {
                return;
            }
            if ([ignore_events containsObject:event]) {
                return;
            }
            for (NSString *prefix in ignore_prefixes) {
                if ([event hasPrefix:prefix]) {
                    return;
                }
            }
            SSEasyLog(@"event:%@ params:%@", event, p);
        });
    }
}

@interface SSEasy : NSObject

@end

@implementation SSEasy

+ (void)load
{
    ss_activate_easy_log();
    ss_activate_easy_assert();
    ss_activate_easy_exception();
    
    p_ignore_objc_method();
    p_swizzle_objc_method();
    p_replace_objc_method();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        p_modify_values();
    });
}

@end
