//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyAssert.h"
#import "SSEasyHook.h"
#import "SSEasyLog.h"

static int (*pthread_kill_real)(pthread_t t, int i);
int pthread_kill_f(pthread_t t, int i) { return 0; }

static void p_activate(void)
{
    ss_rebind_symbols((struct rebinding[1]) {
        {"pthread_kill", pthread_kill_f, (void *)&pthread_kill_real}
    }, 1);
    
    SEL selector = @selector(handleFailureInMethod:object:file:lineNumber:description:);
    ss_method_swizzle([NSAssertionHandler class], selector, ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ss_easy_assert_once_for_key(@"NSAssert");
        });
    });
    selector = @selector(handleFailureInFunction:file:lineNumber:description:);
    ss_method_swizzle([NSAssertionHandler class], selector, ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ss_easy_assert_once_for_key(@"NSCAssert");
        });
    });
}

void ss_activate_easy_assert(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        p_activate();
    });
}

void ss_easy_assert_once_for_key(NSString *key)
{
    if ([NSBundle.mainBundle.bundleIdentifier containsString:@"demo"]) {
        return;
    }
    
    if (![key isKindOfClass:[NSString class]]) {
        return;
    }
    
    static NSLock *m_lock = nil;
    static NSMutableSet *m_set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m_set = [NSMutableSet set];
        m_lock = [[NSLock alloc] init];
    });
    
    [m_lock lock];
    if (![m_set containsObject:key]) {
        [m_set addObject:key];
        SSEasyLogString(key);
        
        if (pthread_kill_real) {
            pthread_kill_real(pthread_self(), SIGINT);
        } else {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pthread_kill(pthread_self(), SIGINT);
            });
        }
    }
    [m_lock unlock];
}
