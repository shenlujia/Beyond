//
//  GCDController.m
//  Demo
//
//  Created by SLJ on 2020/4/16.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "GCDController.h"

@interface GCDController ()
{
    dispatch_semaphore_t _semaphore;
}

@end

@implementation GCDController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self test:@"sync同一个队列" tap:^(UIButton *button) {
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

    [self test:@"使dispatch_once不执行" tap:^(UIButton *button) {
        static dispatch_once_t onceToken = ~0l;
        dispatch_once(&onceToken, ^{
            // 不会调用
            NSParameterAssert(0);
            NSLog(@"onceToken设为-1后 内部判定已经执行过不会再调用");
        });
    }];

    [self test:@"sync 快手" tap:^(UIButton *button) {
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

    [self test:@"sync 最多三秒返回 多多" tap:^(UIButton *button) {
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

    [self test:@"sync ???" tap:^(UIButton *button) {
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
}

@end
