//
//  GCDController.m
//  Demo
//
//  Created by SLJ on 2020/4/16.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "GCDController.h"
#include <mach/mach_init.h>
#import "MacroHeader.h"

@interface GCDController ()
{
    dispatch_semaphore_t _semaphore;
}

@end

@implementation GCDController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WEAKSELF
    
    [weak_s test:@"主线程不一定执行主队列 主队列不一定在主线程" tap:^(UIButton *button, NSDictionary *userInfo) {
        static int key = 0;
        CFStringRef context = CFSTR("main");
        dispatch_queue_set_specific(dispatch_get_main_queue(), &key, (void *)context, (dispatch_function_t)CFRelease);
        void (^block)(void) = ^{
            NSLog(@"main thread: %@", @([[NSThread currentThread] isMainThread]));
            void *name = dispatch_get_specific(&key);
            NSLog(@"queue: %@", name);
        };
        
        NSLog(@"主线程执行");
        block();
        PRINT_BLANK_LINE
        
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"主线程sync其他线程执行");
            block();
            PRINT_BLANK_LINE
        });
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"其他线程执行");
            block();
            PRINT_BLANK_LINE
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"其他线程sync主线程");
                block();
                PRINT_BLANK_LINE
            });
        });
        if ([userInfo[kButtonTapCountKey] integerValue] > 1) {
            // 这个会导致主线程退出 然后主队列也会在其他线程执行
            dispatch_main();
        }
        NSLog(@"case结束");
        PRINT_BLANK_LINE
    }];
    
    [weak_s test:@"sync同一个队列" tap:^(UIButton *button, NSDictionary *userInfo) {
        dispatch_queue_t queue1 = dispatch_queue_create("com.slj.1", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t queue2 = dispatch_queue_create("com.slj.2", DISPATCH_QUEUE_SERIAL);

        dispatch_async(queue1, ^{
            NSLog(@"async task 0 start");
            NSLog(@"task thread: %@", [NSThread currentThread]);
            sleep(5);
            NSLog(@"async task 0 end");
            printf("\n");
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(queue2, ^{
                dispatch_sync(queue1, ^{
                    NSLog(@"sync task 2 start");
                    NSLog(@"task thread: %@", [NSThread currentThread]);
                    sleep(5);
                    NSLog(@"sync task 2 end");
                    printf("\n");
                });
            });
            dispatch_sync(queue1, ^{
                NSLog(@"sync task 1 start");
                NSLog(@"task thread: %@", [NSThread currentThread]);
                sleep(5);
                NSLog(@"sync task 1 end");
                printf("\n");
            });
        });
    }];

    [weak_s test:@"使dispatch_once不执行" tap:^(UIButton *button, NSDictionary *userInfo) {
        static dispatch_once_t onceToken = ~0l;
        dispatch_once(&onceToken, ^{
            // 不会调用
            assert(0);
            NSLog(@"onceToken设为-1后 内部判定已经执行过不会再调用");
        });
    }];

    [weak_s test:@"sync 快手" tap:^(UIButton *button, NSDictionary *userInfo) {
        dispatch_queue_t queue1 = dispatch_queue_create("com.slj.1", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t queue2 = dispatch_queue_create("com.slj.2", DISPATCH_QUEUE_SERIAL);

        dispatch_async(queue1, ^{
            NSLog(@"queue1 thread: %@", [NSThread currentThread]);
        });
        dispatch_async(queue1, ^{
            NSLog(@"queue1 thread: %@", [NSThread currentThread]);
        });

        dispatch_async(queue2, ^{
            NSLog(@"queue2 thread: %@", [NSThread currentThread]);
        });
        dispatch_async(queue2, ^{
            NSLog(@"queue2 thread: %@", [NSThread currentThread]);
        });

        dispatch_async(queue1, ^{
            NSLog(@"sync start");
            NSLog(@"queue1 thread: %@", [NSThread currentThread]);
            dispatch_sync(queue2, ^{
                NSLog(@"queue2 thread: %@", [NSThread currentThread]);
            });
            NSLog(@"sync end");
        });

        // 为了优化 sync一般只在当前线程处理block
        dispatch_sync(queue1, ^{
            NSLog(@"queue1 sync thread: %@", [NSThread currentThread]);
        });
        dispatch_sync(queue2, ^{
            NSLog(@"queue2 sync thread: %@", [NSThread currentThread]);
        });

        dispatch_async(queue1, ^{
            // 主线程的block无论何时都在主线程处理
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"YEAH queue1 sync thread: %@", [NSThread currentThread]);
            });
        });
    }];

    [weak_s test:@"sync 最多三秒返回 多多" tap:^(UIButton *button, NSDictionary *userInfo) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));
        dispatch_queue_t queue1 = dispatch_queue_create("com.slj.sync.wait", DISPATCH_QUEUE_SERIAL);
        __block NSString *ret = nil;
        dispatch_async(queue1, ^{
            sleep(6);
            ret = @"OK";
            dispatch_semaphore_signal(semaphore);
            NSLog(@"6s task over");
            NSLog(@"new ret = %@", ret);
        });
        dispatch_semaphore_wait(semaphore, time);
        NSLog(@"ret = %@", ret);
    }];

    [weak_s test:@"sync ???" tap:^(UIButton *button, NSDictionary *userInfo) {
        dispatch_queue_t queue1 = dispatch_queue_create("com.slj.1", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t queue2 = dispatch_queue_create("com.slj.2", DISPATCH_QUEUE_SERIAL);

        dispatch_async(queue2, ^{
            NSLog(@"queue2 heavy task start, thread = %@", [NSThread currentThread]);
            sleep(5);
            NSLog(@"queue2 heavy task end, thread = %@", [NSThread currentThread]);
        });

        dispatch_async(queue1, ^{
            NSLog(@"sync start");
            NSLog(@"queue1 thread: %@", [NSThread currentThread]);
            dispatch_sync(queue2, ^{
                NSLog(@"queue2 thread: %@", [NSThread currentThread]);
            });
            NSLog(@"sync end");
        });
    }];
    
    [weak_s test:@"group" tap:^(UIButton *button, NSDictionary *userInfo) {
        dispatch_group_t group = dispatch_group_create();
        NSLog(@"group create");
        for (int i = 1; i < 8; ++i) {
            dispatch_group_enter(group);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"group task %@ start", @(i));
                sleep(i);
                NSLog(@"group task %@ finish", @(i));
                dispatch_group_leave(group);
            });
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"group notify 1");
        });
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"group notify 2");
        });
    }];
    
    [weak_s test:@"barriar CONCURRENT" tap:^(UIButton *button, NSDictionary *userInfo) {
        PRINT_BLANK_LINE
        dispatch_queue_t queue = dispatch_queue_create("com.gcdTest.queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(queue, ^{
            NSLog(@"work1");
        });
        dispatch_barrier_async(queue, ^{
            sleep(3);
            NSLog(@"work2");
            sleep(3);
        });
        dispatch_async(queue, ^{
            NSLog(@"work3");
        });
        dispatch_async(queue, ^{
            sleep(3);
            NSLog(@"work4");
            sleep(3);
        });
        dispatch_async(queue, ^{
            NSLog(@"work5");
        });
        dispatch_barrier_async(queue, ^{
            NSLog(@"work6");
        });
    }];
    
    [weak_s test:@"barriar global_queue 无效" tap:^(UIButton *button, NSDictionary *userInfo) {
        PRINT_BLANK_LINE
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_async(queue, ^{
            NSLog(@"work1");
        });
        dispatch_barrier_async(queue, ^{
            sleep(2);
            NSLog(@"work2");
            sleep(2);
        });
        dispatch_async(queue, ^{
            NSLog(@"work3");
        });
        dispatch_async(queue, ^{
            sleep(3);
            NSLog(@"work4");
            sleep(3);
        });
        dispatch_async(queue, ^{
            NSLog(@"work5");
        });
        dispatch_barrier_async(queue, ^{
            NSLog(@"work6");
        });
    }];
    
    [weak_s test:@"semephore顺序执行" tap:^(UIButton *button, NSDictionary *userInfo) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSLog(@"semaphore create");
        for (int i = 1; i < 8; ++i) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSLog(@"semaphore task %@ start", @(i));
                sleep(1);
                NSLog(@"semaphore task %@ finish", @(i));
                dispatch_semaphore_signal(semaphore);
            });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        NSLog(@"semaphore finish");
    }];
    
    [weak_s test:@"子线程 performSelector case 1" tap:^(UIButton *button, NSDictionary *userInfo) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // 虽然23不会打印 但是已经加到了runloop 没有run而已
            // 所以执行case1后再执行case2会发生奇怪的事情
            NSLog(@"test start");
            [weak_s performSelector:@selector(p_test_performSelector1)];
            [weak_s performSelector:@selector(p_test_performSelector2) withObject:nil afterDelay:0];
            [weak_s performSelector:@selector(p_test_performSelector3) withObject:nil afterDelay:3];
            NSLog(@"test end");
        });
    }];
    
    [weak_s test:@"子线程 performSelector case 2" tap:^(UIButton *button, NSDictionary *userInfo) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"test start");
            [weak_s performSelector:@selector(p_test_performSelector1)];
            [weak_s performSelector:@selector(p_test_performSelector2) withObject:nil afterDelay:0];
            [NSRunLoop.currentRunLoop run];
            [weak_s performSelector:@selector(p_test_performSelector3) withObject:nil afterDelay:3];
            NSLog(@"test end");
        });
    }];
    
    [weak_s test:@"子线程 performSelector case 3" tap:^(UIButton *button, NSDictionary *userInfo) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"test start");
            [weak_s performSelector:@selector(p_test_performSelector1)];
            [weak_s performSelector:@selector(p_test_performSelector2) withObject:nil afterDelay:0];
            [NSRunLoop.currentRunLoop run];
            [weak_s performSelector:@selector(p_test_performSelector3) withObject:nil afterDelay:3];
            [NSRunLoop.currentRunLoop run];
            NSLog(@"test end");
        });
    }];

    [weak_s test:@"dispatch_group_leave crash" tap:^(UIButton *button, NSDictionary *userInfo) {
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_leave(group);
    }];

    [weak_s test:@"group donot wait leave" tap:^(UIButton *button, NSDictionary *userInfo) {
        PRINT_BLANK_LINE
        static NSInteger task_cost = 0;
        task_cost = (task_cost % 5) + 1;
        NSInteger current_task = task_cost;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        NSLog(@"task start (cost = %@s)", @(current_task));
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(current_task * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_group_leave(group);
            NSLog(@"task finish (cost = %@s)", @(current_task));
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"wait start");
            CGFloat begin = CFAbsoluteTimeGetCurrent();
            dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)));
            NSLog(@"wait end, total_wait_time = %f", CFAbsoluteTimeGetCurrent() - begin);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"===END===");
            });
        });
    }];
}

- (void)p_test_performSelector1
{
    NSLog(@"1");
}

- (void)p_test_performSelector2
{
    NSLog(@"2");
}

- (void)p_test_performSelector3
{
    NSLog(@"3");
}

@end
