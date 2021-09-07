//
//  Created by ZZZ on 2020/10/30.
//

#import <CreativeKit/NSObject+ACCSwizzle.h>
#import <AWEAppSettings/AWEBaseSettings.h>
#import <KiteLog/KiteLogControl.h>
#import <BDALog/BDAgileLog.h>
#import <AWEStudioImpl/AWEACCTrackerImpl.h>
#import <CreativeKit/ACCMemoryMonitor.h>
#import <Heimdallr/Heimdallr.h>
#import <fishhook/fishhook.h>
#import <objc/runtime.h>

static NSString *PREFIX = @"AWE";

static int (*pthread_kill_p)(pthread_t t, int i);
int pthread_kill_f(pthread_t t, int i) { return 0; }

static int (*printf_p)(const char *format, ...);
static int printf_f(const char *format, ...) { return 0; }

static int (*fprintf_p)(FILE *file, const char *format, ...);
static int fprintf_f(FILE *file, const char *format, ...) { return 0; }

static int (*vfprintf_p)(FILE *file, const char *format, va_list);
static int vfprintf_f(FILE *file, const char *format, va_list args) { return 0; }

static int (*vprintf_p)(const char *format, va_list);
static int vprintf_f(const char *format, va_list args) { return 0; }

static void (*NSLogv_p)(NSString *format, va_list args);
static void NSLogv_f(NSString *format, va_list args) {}

static void (*NSLog_p)(NSString *format, ...);
static void NSLog_f(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    if (!PREFIX || [format hasPrefix:PREFIX]) {
        NSLogv_p(format, args);
    }
    va_end(args);
}

void ByebyeExceptionHandler(NSException *exception)
{
    NSArray *stack = [exception callStackReturnAddresses];
    NSLog(@"Stack trace: %@", stack);
}

@interface ByebyeAssertionHandler : NSAssertionHandler

@end

@implementation ByebyeAssertionHandler

- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(nullable NSString *)format,...
{
    NSLog(@"NSAssert Failure: Method %@ for object %@ in %@#%li", NSStringFromSelector(selector), object, fileName, (long)line);
}

- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(nullable NSString *)format,...
{
    NSLog(@"NSCAssert Failure: Function (%@) in %@#%li", functionName, fileName, (long)line);
}

@end

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
    rebind_symbols((struct rebinding[7]) {
        {"pthread_kill", pthread_kill_f, (void *)&pthread_kill_p},
        {"fprintf", fprintf_f, (void *)&fprintf_p},
        {"printf", printf_f, (void *)&printf_p},
        {"vfprintf", vfprintf_f, (void *)&vfprintf_p},
        {"vprintf", vprintf_f, (void *)&vprintf_p},
        {"NSLogv", NSLogv_f, (void *)&NSLogv_p},
        {"NSLog", NSLog_f, (void *)&NSLog_p},
    }, 7);

    extern bool isTTVideoEngineLogEnabled;
    isTTVideoEngineLogEnabled = NO;

    alog_set_console_log(false);
    alog_set_log_level(kLevelNone);
    alog_close();

    extern void hmd_disable_cpp_exception_backtrace(void);
    hmd_disable_cpp_exception_backtrace(); // 300M+ memory

    NSAssertionHandler *assertHandler = [[ByebyeAssertionHandler alloc] init];
    [NSThread.currentThread.threadDictionary setValue:assertHandler forKey:NSAssertionHandlerKey];

    NSSetUncaughtExceptionHandler(&ByebyeExceptionHandler);
}

@end
