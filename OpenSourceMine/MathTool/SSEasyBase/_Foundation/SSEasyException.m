//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyException.h"
#import "SSEasyAssert.h"
#import "SSEasyHook.h"
#import "SSEasyLog.h"

void SSEasyExceptionHandler(NSException *exception)
{
    NSArray *stack = [exception callStackSymbols];
    ss_easy_assert_once_for_key([NSString stringWithFormat:@"Exception: %@", stack]);
}

static void p_activate(void)
{
    NSSetUncaughtExceptionHandler(&SSEasyExceptionHandler);
    
    Class c = object_getClass([NSException class]);
    ss_method_swizzle(c, @selector(raise:format:), ^(id a, id b, id c) {
        NSString *text = [NSString stringWithFormat:@"%@ raise:%@ format:%@", a, b, c];
        ss_easy_assert_once_for_key(text);
    });
    ss_method_swizzle(c, @selector(raise:format:arguments:), ^(id a, id b, id c) {
        NSString *text = [NSString stringWithFormat:@"%@ raise:%@ format:%@(arguments)", a, b, c];
        ss_easy_assert_once_for_key(text);
    });
}

void ss_activate_easy_exception(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        p_activate();
    });
}
