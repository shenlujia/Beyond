//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyAssert.h"
#import "SSEasyHook.h"
#import "SSEasyLog.h"

static int (*pthread_kill_real)(pthread_t t, int i);
int pthread_kill_f(pthread_t t, int i) { return 0; }

@interface SSEasyAssertionHandler : NSAssertionHandler

@end

@implementation SSEasyAssertionHandler

- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(nullable NSString *)format,...
{
    NSString *text = [NSString stringWithFormat:@"NSAssert Failure: Method %@ for object %@ in %@#%li", NSStringFromSelector(selector), object, fileName, (long)line];
    
    SSEasyLog(text);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss_easy_assert_safe(text);
    });
}

- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(nullable NSString *)format,...
{
    NSString *text = [NSString stringWithFormat:@"NSCAssert Failure: Function (%@) in %@#%li", functionName, fileName, (long)line];
    
    SSEasyLog(text);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss_easy_assert_safe(text);
    });
}

@end

void ss_activate_easy_assert(void)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss_rebind_symbols((struct rebinding[1]) {
            {"pthread_kill", pthread_kill_f, (void *)&pthread_kill_real}
        }, 1);
        
        NSAssertionHandler *handler = [[SSEasyAssertionHandler alloc] init];
        [NSThread.currentThread.threadDictionary setValue:handler forKey:NSAssertionHandlerKey];
    });
}

void ss_easy_assert_safe(NSString *identifier)
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
