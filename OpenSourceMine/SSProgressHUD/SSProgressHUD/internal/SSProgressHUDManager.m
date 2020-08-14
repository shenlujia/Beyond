//
//  SSProgressHUDManager.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "SSProgressHUDManager.h"
#import "SSProgressHUD.h"
#import "SSProgressHUDRecord.h"
#import "SSProgressHUDContentView.h"
#import "SSProgressHUDContainerView.h"

#define UserInfoIdentifierKey @"UserInfoIdentifierKey"

@interface SSProgressHUDManager ()

@property (nonatomic, strong) NSMutableDictionary *records;

@end

@implementation SSProgressHUDManager

- (instancetype)init
{
    self = [super init];
    
    _records = [NSMutableDictionary dictionary];
    
    return self;
}

+ (instancetype)sharedManager
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)show:(SSProgressHUD *)progressHUD
{
    if (![progressHUD isKindOfClass:SSProgressHUD.class]) {
        return;
    }
    NSString *identifier = progressHUD.identifier;
    if (!identifier) {
        return;
    }
    const CGFloat duration = progressHUD.style.duration;
    if (duration <= 0) {
        return;
    }
    
    [self hideStyleWithIdentifier:identifier];
    
    // 定时器结束
    NSTimer *timer = ({
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[UserInfoIdentifierKey] = identifier;
        [NSTimer scheduledTimerWithTimeInterval:duration + progressHUD.fadeInDuration
                                         target:self
                                       selector:@selector(timerCallback:)
                                       userInfo:userInfo
                                        repeats:NO];
    });
    
    SSProgressHUDRecord *record = ({
        [[SSProgressHUDRecord alloc] initWithIdentifier:identifier
                                                  style:progressHUD.style
                                                  timer:timer
                                         fadeInDuration:progressHUD.fadeInDuration
                                        fadeOutDuration:progressHUD.fadeOutDuration];
    });
    self.records[identifier] = record;
    [self animationImpl:YES record:record];
}

- (void)timerCallback:(NSTimer *)timer
{
    NSString *identifier = timer.userInfo[UserInfoIdentifierKey];
    [self hideStyleWithIdentifier:identifier];
}

- (void)hide:(SSProgressHUD *)progressHUD
{
    if (![progressHUD isKindOfClass:SSProgressHUD.class]) {
        return;
    }
    [self hideStyleWithIdentifier:progressHUD.identifier];
}

- (void)hideAll
{
    for (NSString *identifier in self.records.allKeys) {
        [self hideStyleWithIdentifier:identifier];
    }
}

- (void)hideStyleWithIdentifier:(NSString *)identifier
{
    SSProgressHUDRecord *record = self.records[identifier];
    self.records[identifier] = nil;
    [self animationImpl:NO record:record];
}

- (void)animationImpl:(BOOL)show record:(SSProgressHUDRecord *)record
{
    if (!record) {
        return;
    }
    SSProgressHUDStyle *style = record.style;
    if (!style) {
        return;
    }
    
    // 初始化superview
    UIView *superview = style.superview;
    if (!superview) {
        superview = UIApplication.sharedApplication.delegate.window;
    }
    
    // 更新contentView
    SSProgressHUDContentView *contentView = (SSProgressHUDContentView *)style.contentView;
    [contentView updateWithStyle:style];
    
    // 初始化containerView
    UIView *backgroundView = style.backgroundView;
    SSProgressHUDContainerView *containerView = (id)contentView.superview;
    if (![containerView isKindOfClass:[SSProgressHUDContainerView class]]) {
        containerView = [[SSProgressHUDContainerView alloc] init];
    }
    if (containerView.superview != superview) {
        [containerView removeFromSuperview];
        CGRect frame = superview.bounds;
        frame.origin = CGPointZero;
        containerView.frame = frame;
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [superview addSubview:containerView];
    }
    containerView.userInteractionEnabled = style.ignoreInteractionEvents;
    [containerView updateWithContentView:contentView backgroundView:backgroundView];
    
    if (CGSizeEqualToSize(contentView.bounds.size, CGSizeZero)) {
        self.records[record.identifier] = nil;
        [containerView removeFromSuperview];
        return;
    }
    
    if (show) {
        contentView.transform = CGAffineTransformScale(contentView.transform, 1.3, 1.3);
    } else {
//        contentView.transform = CGAffineTransformIdentity;
    }
    
    void (^animationBlock)(void) = ^() {
        if (show) {
            contentView.transform = CGAffineTransformScale(contentView.transform, 1/1.3, 1/1.3);
            contentView.alpha = show ? 1 : 0;
            backgroundView.alpha = show ? 1 : 0;
        }
        else {
            contentView.transform = CGAffineTransformScale(contentView.transform, 0.8, 0.8);
            contentView.alpha = show ? 1 : 0;
            backgroundView.alpha = show ? 1 : 0;
        }
    };
    void (^completionBlock)(void) = ^() {
        if (!show) {
            [containerView removeFromSuperview];
        }
    };
    
    CGFloat duration = show ? record.fadeInDuration : record.fadeOutDuration;
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionNone;
    if (show) {
        options = UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState;
    } else {
        options = UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState;
    }
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        animationBlock();
    } completion:^(BOOL finished) {
        completionBlock();
    }];
}

@end
