//
//  SSProgressHUD.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "SSProgressHUD.h"
#import "SSProgressHUDManager.h"

@interface SSProgressHUD ()

@property (nonatomic, copy) SSProgressHUDStyle *style;

@end

@implementation SSProgressHUD

- (void)dealloc
{
    [self dismiss];
}

- (instancetype)init
{
    self = [super init];
    
    self.fadeInDuration = 0.15;
    self.fadeOutDuration = 0.15;
    _identifier = [[NSUUID UUID] UUIDString];
    
    return self;
}

+ (instancetype)sharedHUD
{
    static SSProgressHUD *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SSProgressHUD alloc] init];
    });
    return instance;
}

- (void)showInfoWithStyle:(void (^)(SSProgressHUDStyle *style))style
{
    SSProgressHUDStyle *object = [SSProgressHUDStyle defaultStyleForState:SSProgressHUDStateInfo];
    if (style) {
        style(object);
    }
    [self showWithAutoDurationStyle:object];
}

- (void)showSuccessWithStyle:(void (^)(SSProgressHUDStyle *style))style
{
    SSProgressHUDStyle *object = [SSProgressHUDStyle defaultStyleForState:SSProgressHUDStateSuccess];
    if (style) {
        style(object);
    }
    [self showWithAutoDurationStyle:object];
}

- (void)showErrorWithStyle:(void (^)(SSProgressHUDStyle *style))style
{
    SSProgressHUDStyle *object = [SSProgressHUDStyle defaultStyleForState:SSProgressHUDStateError];
    if (style) {
        style(object);
    }
    [self showWithAutoDurationStyle:object];
}

- (void)showWithAutoDurationStyle:(SSProgressHUDStyle *)style
{
    if (style.duration == kSSProgressHUDDefaultDuration) {
        const NSInteger minLength = 10;
        const NSInteger maxLength = 150;
        const CGFloat minDuration = 1.5;
        const CGFloat maxDuration = 5;
        NSInteger length = style.text.length;
        length = MAX(length, minLength);
        length = MIN(length, maxLength);
        CGFloat singleDuration = (maxDuration - minDuration) / (maxLength - minLength);
        style.duration = (length - minLength) * singleDuration + minDuration;
    }
    [self showWithStyle:style];
}

- (void)showWithStyle:(SSProgressHUDStyle *)style
{
    _style = [style copy];
    [[SSProgressHUDManager sharedManager] show:self];
}

- (void)dismiss
{
    [[SSProgressHUDManager sharedManager] hide:self];
}

+ (void)dismissAll
{
    [[SSProgressHUDManager sharedManager] hideAll];
}

@end
