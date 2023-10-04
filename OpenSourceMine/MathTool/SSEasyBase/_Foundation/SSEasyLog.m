//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyLog.h"
#import "SSEasyHook.h"

/*
 */

static NSSet *m_filter_prefix_set = nil;

extern void p_easy_precheck_printf(NSString *text, BOOL shouldAddNewLine);

#pragma mark - log ignore

static int (*fprintf_p)(FILE *file, const char *format, ...);
static int fprintf_f(FILE *file, const char *format, ...) { return 0; }

static int (*vfprintf_p)(FILE *file, const char *format, va_list args);
static int vfprintf_f(FILE *file, const char *format, va_list args) { return 0; }

static int (*vprintf_p)(const char *format, va_list args);
static int vprintf_f(const char *format, va_list args) {
    NSString *text = ss_easy_string_with_format(format, args);
    static NSString *debug_local_identifier = nil;
    if (debug_local_identifier) {
        if ([text containsString:debug_local_identifier]) {
            // do something
        }
    }
    if (!ss_easy_log_should_filter(text)) {
        if (vprintf_p) {
            vprintf_p(format, args);
        } else {
//           vprintf(format, args);
        }
    }
    return 0;
}

static int (*printf_p)(const char *format, ...);
static int printf_f(const char *format, ...) {
    va_list args;
    va_start(args, format);
    vprintf_f(format, args);
    va_end(args);
    return 0;
}

static void (*NSLogv_p)(NSString *format, va_list args);
static void NSLogv_f(NSString *format, va_list args) NS_FORMAT_FUNCTION(1,0);
static void NSLogv_f(NSString *format, va_list args) {
    NSString *text = [[NSString alloc] initWithFormat:format arguments:args];
    if (!ss_easy_log_should_filter(text)) {
        printf_f("[oc] %s\n", text.UTF8String);
    }
}

static void (*NSLog_p)(NSString *format, ...);
static void NSLog_f(NSString *format, ...) NS_FORMAT_FUNCTION(1,0);
static void NSLog_f(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSLogv_f(format, args);
    va_end(args);
}

#pragma mark - public

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
NSString * ss_easy_string_with_format(const char *format, va_list args)
{
    return [[NSString alloc] initWithFormat:[[NSString alloc] initWithUTF8String:format] arguments:args];
}
#pragma clang diagnostic pop

BOOL ss_easy_log_should_filter(NSString *text)
{
    for (NSString *prefix in m_filter_prefix_set) {
        if ([text hasPrefix:prefix]) {
            return YES;
        }
    }
    return NO;
}

void ss_easy_log_add_filter_prefix(NSString *filter_prefix)
{
    NSMutableSet *set = [NSMutableSet set];
    if (filter_prefix) {
        [set addObject:filter_prefix];
    }
    if (m_filter_prefix_set.count) {
        [set addObjectsFromArray:m_filter_prefix_set.allObjects];
    }
    m_filter_prefix_set = [set copy];
}

void ss_easy_log_text(NSString *text)
{
    text = [text stringByReplacingOccurrencesOfString:@"%" withString:@"#"];
    if (printf_p) {
        printf_p("%s\n", text.UTF8String);
    } else {
        printf("%s\n", text.UTF8String);
    }
}

void ss_easy_log(NSString *format, ...)
{
    if (!format) {
        return;
    }

    va_list args;
    va_start(args, format);

    NSString *text = [[NSString alloc] initWithFormat:format arguments:args];
    ss_easy_log_text(text);

    va_end(args);
}

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
}

void ss_activate_easy_log()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        p_activate();
    });
}
