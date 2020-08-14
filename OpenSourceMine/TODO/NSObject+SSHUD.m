//
//  NSObject+SSHUD.m
//  Pods
//
//  Created by shenlujia on 2017/9/6.
//
//

#import "NSObject+SSHUD.h"
#import <objc/runtime.h>
#import "SSProgressHUD.h"

#pragma mark - SSHUDManager

@interface SSHUDManager ()

@property (nonatomic, strong) SSProgressHUD *HUD;

@end

@implementation SSHUDManager

- (void)dealloc
{
    [self dismiss];
}

- (instancetype)init
{
    self = [super init];
    
    _HUD = [[SSProgressHUD alloc] init];
    
    return self;
}

- (void)show
{
    SSProgressHUDStyle *style = [SSProgressHUDStyle defaultStyleForState:SSProgressHUDStateLoading];
    style.ignoreInteractionEvents = NO;
    style.backgroundView.backgroundColor = nil;
    [self.HUD showWithStyle:style];
}

- (void)showAndIgnoreInteraction
{
    SSProgressHUDStyle *style = [SSProgressHUDStyle defaultStyleForState:SSProgressHUDStateLoading];
    style.ignoreInteractionEvents = YES;
    style.backgroundView.backgroundColor = nil;
    [self.HUD showWithStyle:style];
}

- (void)dismiss
{
    [self dismissWithText:nil];
}

- (void)dismissWithText:(NSString *)text
{
    [self.HUD showInfoWithStyle:^(SSProgressHUDStyle *style) {
        style.text = text;
    }];
}

@end

#pragma mark - NSObject (SSHUD)

@implementation NSObject (SSHUD)

- (void)setSs_HUD:(SSHUDManager *)ss_HUD
{
    void *key = @selector(ss_HUD);
    objc_setAssociatedObject(self, key, ss_HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SSHUDManager *)ss_HUD
{
    NSParameterAssert([NSThread mainThread]);
    
    SSHUDManager *object = objc_getAssociatedObject(self, @selector(ss_HUD));
    if (![object isKindOfClass:SSHUDManager.class]) {
        object = [[SSHUDManager alloc] init];
        self.ss_HUD = object;
    }
    return object;
}

@end
