//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyAssert.h"
#import "SSEasyException.h"
#import "SSEasyHook.h"
#import "SSEasyLog.h"

//@implementation AWEBaseSettings (Byebye)
//
//- (BOOL)f_boolValueForKeyPath:(NSString *)keyPath defaultValue:(BOOL)defaultValue stable:(BOOL)stable
//{
//    return [keyPath isEqualToString:@"aweme_base_conf.enable_biz_network_alog"] ? NO : [self f_boolValueForKeyPath:keyPath defaultValue:defaultValue stable:stable];
//}
//
//@end

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

static void p_modify_values()
{
    extern bool isTTVideoEngineLogEnabled;
    isTTVideoEngineLogEnabled = NO;

    extern void alog_close(void);
    alog_close();

    extern void hmd_disable_cpp_exception_backtrace(void);
    hmd_disable_cpp_exception_backtrace(); // 300M+ memory
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        p_modify_values();
    });
}

@end
