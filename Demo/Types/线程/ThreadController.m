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

@property (nonatomic, strong) NSThread *thread;

@end

@implementation ThreadController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WEAKSELF;
    
    __block CFRunLoopRef runloop = NULL;
    self.thread = [[NSThread alloc] initWithBlock: ^{
        runloop = NSRunLoop.currentRunLoop.getCFRunLoop;
        [NSRunLoop.currentRunLoop addPort:[[NSMachPort alloc] init] forMode:NSRunLoopCommonModes];
        [NSRunLoop.currentRunLoop run];
        NSParameterAssert(0);
    }];
    [self.thread start];
    
    [self test:@"runloop" tap:^(UIButton *button, NSDictionary *userInfo) {
        CFRunLoopPerformBlock(runloop, NSRunLoopCommonModes, ^{
            NSLog(@"runloop perform block 1");
        });
        [weak_self performSelector:@selector(p_test_runloop) onThread:weak_self.thread withObject:nil waitUntilDone:NO];
        CFRunLoopPerformBlock(runloop, NSRunLoopCommonModes, ^{
            NSLog(@"runloop perform block 2");
        });
    }];
    
    [self test:@"不同类型的线程安全 不加锁" tap:^(UIButton *button, NSDictionary *userInfo) {
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
    
    [self test:@"不同类型的线程安全 加锁" tap:^(UIButton *button, NSDictionary *userInfo) {
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

- (void)p_test_runloop
{
    NSLog(@"p_test_runloop");
}

@end
