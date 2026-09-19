//
//  SSEasy.m — stub implementation
//

#import "SSEasy.h"
#import <objc/runtime.h>
#import <stdarg.h>

void ss_easy_log(NSString *format, ...)
{
    if (!format) return;
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"%@", msg);
}

void ss_easy_log_text(NSString *text)
{
    NSLog(@"%@", text);
}

void ss_easy_install(void) { }

IMP ss_method_swizzle(Class cls, SEL selector, id block) {
    return imp_implementationWithBlock(block);
}

void ss_method_ignore(NSString *clsName, NSString *selectorName) { }

void ss_easy_assert_once_for_key(NSString *key) { }

NSArray *ss_memory_retainedObjects(id object) { return @[]; }

id ss_easy_objc_call(id target, NSString *selectorName, NSArray *arguments)
{
    if (!target || !selectorName) return nil;
    SEL sel = NSSelectorFromString(selectorName);
    if (!sel) return nil;
    Method method;
    if ([target class] == target) {
        method = class_getInstanceMethod(object_getClass(target), sel);
    } else {
        method = class_getInstanceMethod([target class], sel);
    }
    if (!method) return nil;

    NSMethodSignature *sig = [target methodSignatureForSelector:sel];
    if (!sig) return nil;
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:target];
    [inv setSelector:sel];
    NSUInteger argCount = [sig numberOfArguments] - 2; // self + _cmd
    NSUInteger idx = 0;
    for (id arg in arguments) {
        if (idx++ >= argCount) break;
        if ([arg isKindOfClass:[NSNumber class]]) {
            double d = [arg doubleValue];
            [inv setArgument:&d atIndex:idx + 1];
        } else {
            id obj = (arg == [NSNull null]) ? nil : arg;
            [inv setArgument:&obj atIndex:idx + 1];
        }
    }
    [inv invoke];
    const char *retType = [sig methodReturnType];
    if (retType[0] == '@') {
        __unsafe_unretained id ret = nil;
        [inv getReturnValue:&ret];
        return ret;
    }
    return nil;
}
