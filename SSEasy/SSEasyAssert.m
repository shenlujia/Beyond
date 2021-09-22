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
            ss_easy_assert_once(@"NSAssert");
        });
    });
    selector = @selector(handleFailureInFunction:file:lineNumber:description:);
    ss_method_swizzle([NSAssertionHandler class], selector, ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ss_easy_assert_once(@"NSCAssert");
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

void ss_easy_assert_once(NSString *identifier)
{
    static NSLock *m_lock = nil;
    static NSMutableSet *m_set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m_set = [NSMutableSet set];
        m_lock = [[NSLock alloc] init];
    });
    
    identifier = identifier ?: @"";
    identifier = [identifier stringByReplacingOccurrencesOfString:@"%" withString:@"#"];
    
    [m_lock lock];
    if (![m_set containsObject:identifier]) {
        [m_set addObject:identifier];
        SSEasyLog(identifier);
        pthread_kill_real(pthread_self(), SIGINT);
    }
    [m_lock unlock];
}
