//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyException.h"
#import "SSEasyLog.h"

void ss_safe_assert(NSString *text)
{
    NSLog(text);
    pthread_kill(pthread_self(), SIGINT);
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
    NSString *text = [NSString stringWithFormat:@"NSAssert Failure: Method %@ for object %@ in %@#%li", NSStringFromSelector(selector), object, fileName, (long)line];
    
    NSLog(text);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss_safe_assert(text);
    });
}

- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(nullable NSString *)format,...
{
    NSString *text = [NSString stringWithFormat:@"NSCAssert Failure: Function (%@) in %@#%li", functionName, fileName, (long)line];
    
    NSLog(text);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ss_safe_assert(text);
    });
}

@end
