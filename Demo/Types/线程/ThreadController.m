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
    
    WEAKSELF
    
    [self test_c:@"ThreadPipe" title:@"NSPipe只能传递流式的数据 通过文件可以跨进程通信"];
    
    [self test_c:@"ThreadPort" title:@"NSPort"];
    
    __block CFRunLoopRef runloop = NULL;
    weak_s.thread = [[NSThread alloc] initWithBlock:^{
        runloop = NSRunLoop.currentRunLoop.getCFRunLoop;
        [NSRunLoop.currentRunLoop addPort:[[NSMachPort alloc] init] forMode:NSRunLoopCommonModes];
        [NSRunLoop.currentRunLoop run];
        assert(0);
    }];
    [weak_s.thread start];
    
    [weak_s test:@"runloop" tap:^(UIButton *button, NSDictionary *userInfo) {
        CFRunLoopPerformBlock(runloop, NSRunLoopCommonModes, ^{
            NSLog(@"runloop perform block 1");
        });
        [weak_s performSelector:@selector(p_test_runloop) onThread:weak_s.thread withObject:nil waitUntilDone:NO];
        CFRunLoopPerformBlock(runloop, NSRunLoopCommonModes, ^{
            NSLog(@"runloop perform block 2");
        });
    }];
    
    [weak_s test:@"不同类型的线程安全 不加锁" tap:^(UIButton *button, NSDictionary *userInfo) {
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
    
    [weak_s test:@"不同类型的线程安全 加锁" tap:^(UIButton *button, NSDictionary *userInfo) {
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
    
    [weak_s test:@"NSMapTable和NSHashTable不安全 NSCache安全" tap:^(UIButton *button, NSDictionary *userInfo) {
        __block NSMapTable *a = [NSMapTable strongToStrongObjectsMapTable];
        __block NSHashTable *b = [NSHashTable weakObjectsHashTable];
        __block NSCache *c = [[NSCache alloc] init];
        __block BOOL a_safe = YES;
        __block BOOL b_safe = YES;
        NSInteger count = 10000;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger index = 0; index < count; ++index) {
            [array addObject:[NSString stringWithFormat:@"abcdefghijklmnopqrstuvwxyz_slj_%@", @(index)]];
        }
        for (NSInteger index = 0; index < 10 * 10000; ++index) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *obj = array[index % count];
                @try {
                    if (a_safe) {
                        if (a.dictionaryRepresentation[obj]) {
                            [a removeObjectForKey:obj];
                        } else {
                            [a setObject:obj forKey:obj];
                        }
                    }
                } @catch (NSException *exception) {
                    NSLog(@"%@", exception);
                    a_safe = NO;
                }
                @try {
                    if (b_safe) {
                        if ([b member:obj]) {
                            [b removeObject:obj];
                        } else {
                            [b addObject:obj];
                        }
                    }
                } @catch (NSException *exception) {
                    NSLog(@"%@", exception);
                    b_safe = NO;
                }
                if ([c objectForKey:obj]) {
                    [c removeObjectForKey:obj];
                } else {
                    [c setObject:obj forKey:obj];
                }
            });
        }
        NSLog(@"测试完毕");
    }];
}

- (void)p_test_runloop
{
    NSLog(@"p_test_runloop");
}

@end
