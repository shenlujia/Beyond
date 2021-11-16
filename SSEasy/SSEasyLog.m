//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyLog.h"
#import "SSEasyHook.h"

static NSString *PREFIX = @"AWE";

static int (*printf_p)(const char *format, ...);
static int printf_f(const char *format, ...) {
    NSString *string = [NSString stringWithUTF8String:format];
    if (!PREFIX || [string hasPrefix:PREFIX]) {
        va_list args;
        va_start(args, format);
        NSString *text = [[NSString alloc] initWithFormat:string arguments:args];
        va_end(args);
        SSEasyLogString(text);
    }
    return 0;
}

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

FOUNDATION_EXTERN void SSEasyLogString(NSString *text)
{
    text = [text stringByReplacingOccurrencesOfString:@"@" withString:@"#"];
    SSEasyLog(text);
}

void SSEasyLog(NSString *format, ...)
{
    if (!printf_p) {
        return;
    }
    
    if (!format) {
        return;
    }

    va_list args;
    va_start(args, format);

    NSString *text = [[NSString alloc] initWithFormat:format arguments:args];
    printf_p("%s\n", text.UTF8String);

    va_end(args);
}

typedef struct SSLoggerInfo_t {
    const char* filename;
    const char* func_name;
    int line;
    const char* tag;
} SSLoggerInfo;

static void p_activate()
{
    ss_rebind_symbols((struct rebinding[6]) {
        {"fprintf", fprintf_f, (void *)&fprintf_p},
        {"printf", printf_f, (void *)&printf_p},
        {"vfprintf", vfprintf_f, (void *)&vfprintf_p},
        {"vprintf", vprintf_f, (void *)&vprintf_p},
        {"NSLogv", NSLogv_f, (void *)&NSLogv_p},
        {"NSLog", NSLog_f, (void *)&NSLog_p},
    }, 6);
    
    void (^replace_acc_logger_method)(SEL method) = ^(SEL method) {
        void (^action)(id a, SSLoggerInfo, NSString *) = ^(id a, SSLoggerInfo s, NSString *msg) {
            SSEasyLogString(msg);
        };
        Class c = NSClassFromString(@"AWEACCLogImpl");
        ss_method_swizzle(c, method, action);
    };
    replace_acc_logger_method(NSSelectorFromString(@"toolErrorLogWithInfo:message:"));
    replace_acc_logger_method(NSSelectorFromString(@"toolWarnLogWithInfo:message:"));
}

void ss_activate_easy_log()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        p_activate();
    });
}
