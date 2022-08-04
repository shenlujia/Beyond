//
//  StrictForegroundProtector.m
//  Beyond
//
//  Created by ZZZ on 2022/7/7.
//  Copyright © 2022 SLJ. All rights reserved.
//

#import "StrictForegroundProtector.h"

@interface StrictForegroundProtector ()

@property (nonatomic, strong) NSMutableArray *actions;

@end

@implementation StrictForegroundProtector

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    _actions = [NSMutableArray array];
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self
               selector:@selector(applicationDidBecomeActiveNotification:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static StrictForegroundProtector *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[StrictForegroundProtector alloc] init];
    });
    return instance;
}

+ (void)handleAction:(void (^)(void))action
{
    if (!action) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            action();
        } else {
            [[StrictForegroundProtector sharedInstance].actions addObject:action];
        }
    });
}

#pragma mark - notification

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *actions = [self.actions copy];
        [self.actions removeAllObjects];
        for (void (^action)(void) in actions) {
            action();
        }
    });
}

@end
