//
//  Created by ZZZ on 2020/10/30.
//

#ifdef INHOUSE_TARGET1

#import "SSEasyAssert.h"
#import "SSEasyException.h"
#import "SSEasyHook.h"
#import "SSEasyLog.h"


@implementation AWEACCTrackerImpl (Byebye)

- (void)f_logTrackerEvent:(NSString *)event params:(NSDictionary *)params
{

}

@end

@implementation AWEBaseSettings (Byebye)

- (BOOL)f_boolValueForKeyPath:(NSString *)keyPath defaultValue:(BOOL)defaultValue stable:(BOOL)stable
{
    return [keyPath isEqualToString:@"aweme_base_conf.enable_biz_network_alog"] ? NO : [self f_boolValueForKeyPath:keyPath defaultValue:defaultValue stable:stable];
}

@end

static void p_ignore_method
{
    ss_method_ignore(@"ACCMemoryMonitor", @"startCheckMemoryLeaks:");
    ss_method_ignore(@"ACCMemoryMonitor", @"startMemoryMonitorForContext:");
    ss_method_ignore(@"ACCMemoryMonitor", @"startMemoryMonitorForContext:tartgetClasses:maxInstanceCount:");
    ss_method_ignore(@"ACCMemoryMonitor", @"addObject:forContext:");
    ss_method_ignore(@"ACCMemoryMonitor", @"stopMemoryMonitorForContext:");
    
    ss_method_ignore(@"Heimdallr", @"shared");
    
    ss_method_ignore(@"KiteLogControl", @"isEnabled");
}

__attribute__((constructor))
static void bye()
{
    ss_activate_easy_log();
    ss_activate_easy_assert();
    ss_activate_easy_exception();
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self go];
    });
}

+ (void)swizzle
{
    void (^swizzle)(Class c, NSString *func) = ^(Class c, NSString *func) {
        NSString *to = [NSString stringWithFormat:@"f_%@", func];
        [c acc_swizzleMethodsOfClass:c originSelector:NSSelectorFromString(func) targetSelector:NSSelectorFromString(to)];
    };
    swizzle([AWEBaseSettings class], @"boolValueForKeyPath:defaultValue:stable:");
    swizzle([AWEACCTrackerImpl class], @"logTrackerEvent:params:");
    swizzle([KiteLogControl class], @"isEnabled");
//    swizzle(objc_getMetaClass(object_isClass(<#id  _Nullable obj#>)), @"isEnabled");
//
//
//    + (void)startCheckMemoryLeaks:(id)object {}
//    + (void)startMemoryMonitorForContext:(NSString *)context tartgetClasses:(NSArray<Class> *)classes maxInstanceCount:(NSUInteger)count {}
//    + (void)addObject:(id)obj forContext:(NSString *)context {}
//    + (void)stopMemoryMonitorForContext:(NSString *)context {}
}

+ (void)go
{
    

    extern bool isTTVideoEngineLogEnabled;
    isTTVideoEngineLogEnabled = NO;

    alog_set_console_log(false);
    alog_set_log_level(kLevelNone);
    alog_close();

    extern void hmd_disable_cpp_exception_backtrace(void);
    hmd_disable_cpp_exception_backtrace(); // 300M+ memory

    
}

@end

#endif
