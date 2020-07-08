//
//  GCDTimer.m
//  Demo
//
//  Created by SLJ on 2020/7/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "GCDTimer.h"

@interface GCDTimer ()

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation GCDTimer

- (void)dealloc
{
    [self invalidate];
    NSLog(@"~%@", NSStringFromClass([self class]));
}

+ (GCDTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(BOOL (^)(void))block
{
    GCDTimer *ret = [[GCDTimer alloc] init];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    ret.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 设置定时器
    dispatch_source_set_timer(ret.timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    // 设置回调
    dispatch_source_set_event_handler(ret.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL repeat = NO;
            if (block) {
                repeat = block();
            }
            if (!repeat) {
                dispatch_source_cancel(ret.timer);
            }
        });
    });
    
    dispatch_resume(ret.timer);
    return ret;
}

- (void)invalidate
{
    dispatch_source_cancel(self.timer);
}

@end
