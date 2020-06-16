//
//  ThreadController.m
//  Demo
//
//  Created by SLJ on 2020/6/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ThreadController.h"

NSInteger g_thread_int = 0;
static NSInteger s_thread_int = 0;

@interface ThreadController ()

@end

@implementation ThreadController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self test:@"不同类型的线程安全 不加锁" tap:^(UIButton *button) {
        g_thread_int = 0;
        s_thread_int = 0;
        __block NSInteger p_local_int = 0;
        for (NSInteger idx = 0; idx < 10000; ++idx) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ++g_thread_int;
                ++s_thread_int;
                ++p_local_int;
            });
        }
        sleep(1);
        NSLog(@"global=%@ static=%@ local=%@", @(g_thread_int), @(s_thread_int), @(p_local_int));
    }];
    
    [self test:@"不同类型的线程安全 加锁" tap:^(UIButton *button) {
        g_thread_int = 0;
        s_thread_int = 0;
        static NSLock *lock = nil;
        if (!lock) {
            lock = [[NSLock alloc] init];
        }
        __block NSInteger p_local_int = 0;
        for (NSInteger idx = 0; idx < 10000; ++idx) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [lock lock];
                ++g_thread_int;
                ++s_thread_int;
                ++p_local_int;
                [lock unlock];
            });
        }
        sleep(1);
        NSLog(@"global=%@ static=%@ local=%@", @(g_thread_int), @(s_thread_int), @(p_local_int));
    }];
}

@end
