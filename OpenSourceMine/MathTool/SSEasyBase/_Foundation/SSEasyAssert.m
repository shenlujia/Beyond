//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyAssert.h"
#import "SSEasyHook.h"
#import "SSEasyLog.h"
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>
#include <pthread/pthread.h>

static bool AmIBeingDebugged(void)
    // Returns true if the current process is being debugged (either
    // running under the debugger or has a debugger attached post facto).
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;

    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.

    info.kp_proc.p_flag = 0;

    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.

    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();

    // Call sysctl.

    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);

    // We're being debugged if the P_TRACED flag is set.

    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}


static int (*pthread_kill_real)(pthread_t t, int i);
int pthread_kill_f(pthread_t t, int i) { return 0; }

static void p_activate(void)
{
    ss_rebind_symbols((struct rebinding[1]) {
        {"pthread_kill", pthread_kill_f, (void *)&pthread_kill_real}
    }, 1);
    
    SEL selector = @selector(handleFailureInMethod:object:file:lineNumber:description:);
    ss_method_swizzle([NSAssertionHandler class], selector, ^(id o, SEL selector, id object, NSString *fileName, NSInteger line, NSString *format) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ss_easy_log_text(@"NSAssert");
            ss_easy_assert_once_for_key(format);
        });
    });
    selector = @selector(handleFailureInFunction:file:lineNumber:description:);
    ss_method_swizzle([NSAssertionHandler class], selector, ^(id o, NSString *functionName, NSString *fileName, NSInteger line, NSString *format) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ss_easy_log_text(@"NSCAssert");
            ss_easy_assert_once_for_key(format);
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
    if (![key isKindOfClass:[NSString class]]) {
        return;
    }
    if (!AmIBeingDebugged()) {
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
        ss_easy_log_text(key);
        
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
