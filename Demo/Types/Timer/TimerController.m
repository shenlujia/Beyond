//
//  TimerController.m
//  Demo
//
//  Created by SLJ on 2020/7/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TimerController.h"
#import "NSTimer+SS.h"
#import "GCDTimer.h"

@interface TimerController ()

@property (nonatomic, strong) NSMutableArray *timers;

@end

@implementation TimerController

- (void)dealloc
{
    for (NSTimer *t in self.timers) {
        [t invalidate];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.timers = [NSMutableArray array];
    
    [self test:@"NSTimer weak target" set:nil action:@selector(NSTimer_weak_target)];
    
    [self test:@"NSTimer block" set:nil action:@selector(NSTimer_block)];
    
    [self test:@"GCDTimer repeat NO" set:nil action:@selector(GCDTimer_repeat_NO)];
    
    [self test:@"GCDTimer repeat YES" set:nil action:@selector(GCDTimer_repeat_YES)];
}

- (void)NSTimer_weak_target
{
    {
        SEL s = @selector(NSTimer_weak_target_action_1);
        NSTimer *t = [NSTimer ss_scheduledTimerWithTimeInterval:1 target:self selector:s userInfo:nil repeats:YES];
        [self.timers addObject:t];
    }
    {
        SEL s = @selector(NSTimer_weak_target_action_2);
        NSTimer *t = [NSTimer ss_scheduledTimerWithTimeInterval:3 target:self selector:s userInfo:nil repeats:NO];
        [self.timers addObject:t];
    }
}

- (void)NSTimer_weak_target_action_1
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)NSTimer_weak_target_action_2
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)NSTimer_block
{
    {
        NSTimer *t = [NSTimer ss_scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) {
            NSLog(@"NSTimer_block_1");
        }];
        [self.timers addObject:t];
    }
    {
        NSTimer *t = [NSTimer ss_scheduledTimerWithTimeInterval:3 repeats:NO block:^(NSTimer *timer) {
            NSLog(@"NSTimer_block_2");
        }];
        [self.timers addObject:t];
    }
}

- (void)GCDTimer_repeat_NO
{
    GCDTimer *t = [GCDTimer scheduledTimerWithTimeInterval:1 block:^BOOL{
        NSLog(@"GCDTimer repeat=NO");
        return NO;
    }];
    [self.timers addObject:t];
}

- (void)GCDTimer_repeat_YES
{
    GCDTimer *t = [GCDTimer scheduledTimerWithTimeInterval:1 block:^BOOL{
        NSLog(@"GCDTimer repeat=YES");
        return YES;
    }];
    [self.timers addObject:t];
}

@end
