//
//  Created by ZZZ on 2020/10/30.
//

#ifdef KKK

#import <CreativeKit/NSObject+ACCSwizzle.h>
#import <AWEAppSettings/AWEBaseSettings.h>
#import <KiteLog/KiteLogControl.h>
#import <BDALog/BDAgileLog.h>
#import <AWEStudioImpl/AWEACCTrackerImpl.h>
#import <CreativeKit/ACCMemoryMonitor.h>
#import <Heimdallr/Heimdallr.h>
#import <fishhook/fishhook.h>
#import <objc/runtime.h>

#import "SSEasyAssert.h"

@implementation ACCMemoryMonitor (Byebye)
+ (void)startCheckMemoryLeaks:(id)object {}
+ (void)startMemoryMonitorForContext:(NSString *)context tartgetClasses:(NSArray<Class> *)classes maxInstanceCount:(NSUInteger)count {}
+ (void)addObject:(id)obj forContext:(NSString *)context {}
+ (void)stopMemoryMonitorForContext:(NSString *)context {}
@end

@implementation KiteLogControl (Byebye)

+ (BOOL)f_isEnabled
{
    return NO;
}

@end

@implementation Heimdallr (Byebye)

+ (instancetype)shared
{
    return nil;
}

@end

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

@interface Byebye : NSObject

@end

@implementation Byebye

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self bye];
    });
}

+ (void)bye
{
    ss_activate_easy_assert();
    
    [self swizzle];

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
