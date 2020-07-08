//
//  NSTimer+SS.m
//  Demo
//
//  Created by SLJ on 2020/7/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "NSTimer+SS.h"
#import <objc/runtime.h>

@interface SSTimerInternalTarget : NSProxy

@property (nonatomic, weak) id target;

@end

@implementation SSTimerInternalTarget

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.target];
}

@end

@implementation NSTimer (SS)

+ (NSTimer *)ss_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats
{
    SSTimerInternalTarget *target = [SSTimerInternalTarget alloc];
    target.target = aTarget;
    return [self scheduledTimerWithTimeInterval:ti target:target selector:aSelector userInfo:userInfo repeats:repeats];
}

+ (NSTimer *)ss_scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block
{
    SEL selector = @selector(ss_blockTimerCallback:);
    return [self scheduledTimerWithTimeInterval:ti target:self selector:selector userInfo:block repeats:repeats];
}

+ (void)ss_blockTimerCallback:(NSTimer *)timer
{
    void (^block)(NSTimer *timer) = timer.userInfo;
    if (block) {
        block(timer);
    }
}

@end
