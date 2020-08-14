//
//  MainThreadRunLoopObserver.m
//  MainThreadMonitor
//
//  Created by shenlujia on 2018/3/6.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import "MainThreadRunLoopObserver.h"

static void runloopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    static NSDictionary *desc = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        ret[@(kCFRunLoopEntry)] = @"kCFRunLoopEntry";
        ret[@(kCFRunLoopBeforeTimers)] = @"kCFRunLoopBeforeTimers";
        ret[@(kCFRunLoopBeforeSources)] = @"kCFRunLoopBeforeSources";
        ret[@(kCFRunLoopBeforeWaiting)] = @"kCFRunLoopBeforeWaiting";
        ret[@(kCFRunLoopAfterWaiting)] = @"kCFRunLoopAfterWaiting";
        ret[@(kCFRunLoopExit)] = @"kCFRunLoopExit";
        desc = [ret copy];
    });
    NSLog(@"runloop = %@", desc[@(activity)]);
}

@interface MainThreadRunLoopObserver ()

@property (nonatomic, assign) CFRunLoopObserverRef observer;

@end

@implementation MainThreadRunLoopObserver

- (void)dealloc
{
    [self stop];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    CFRunLoopObserverContext context = {0, (__bridge void *)self, NULL, NULL};
    _observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                        kCFRunLoopAllActivities,
                                        YES,
                                        0,
                                        &runloopObserverCallBack,
                                        &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
}

- (void)stop
{
    if (_observer) {
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observer, kCFRunLoopCommonModes);
        CFRelease(_observer);
        _observer = nil;
    }
}

@end
