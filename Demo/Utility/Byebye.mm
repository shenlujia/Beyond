//
//  Byebye.m
//  Beyond
//
//  Created by ZZZ on 2021/7/10.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

void ByebyeExceptionHandler(NSException *exception)
{
//    NSArray *stack = [exception callStackReturnAddresses];
//    NSLog(@"Stack trace: %@", stack);
}

void signalHandler(int signal)
{

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

__attribute((constructor)) static void byebye(void)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSAssertionHandler *assertHandler = [[ByebyeAssertionHandler alloc] init];
        [NSThread.currentThread.threadDictionary setValue:assertHandler forKey:NSAssertionHandlerKey];

        NSSetUncaughtExceptionHandler(&ByebyeExceptionHandler);

        signal(SIGINT, signalHandler);
    });
}



