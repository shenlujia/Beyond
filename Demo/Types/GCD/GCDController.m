//
//  GCDController.m
//  Demo
//
//  Created by SLJ on 2020/4/16.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "GCDController.h"

@interface GCDController ()

@end

@implementation GCDController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self test:@"sync 快手"
           set:nil
           tap:^(UIButton *button) {
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

               dispatch_sync(queue1, ^{
                   NSLog(@"queue1 sync thread: %@", [NSThread currentThread]);
               });
               dispatch_sync(queue2, ^{
                   NSLog(@"queue2 sync thread: %@", [NSThread currentThread]);
               });
           }];

    [self test:@"sync 最多三秒返回 多多"
           set:nil
           tap:^(UIButton *button) {
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

    [self test:@"sync ???"
           set:nil
           tap:^(UIButton *button) {
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
