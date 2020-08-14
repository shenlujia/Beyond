//
//  NSObject+TFHUD.m
//  EHD
//
//  Created by shenlujia on 2018/5/3.
//

#import "NSObject+TFHUD.h"
#import <objc/runtime.h>
#import <UIView+HUD.h>
#import <TFWindow/TFWindow.h>

@interface TFHUDManager ()

@property (nonatomic, weak, readonly) NSObject *object;

@property (nonatomic, strong, readonly) UIView *containerView;

@property (nonatomic, assign) BOOL showing;

@end

@implementation TFHUDManager

- (void)dealloc
{
    [self.containerView removeFromSuperview];
}

- (instancetype)initWithObject:(NSObject *)object
{
    self = [self init];
    if (self) {
        _object = object;
        _containerView = [[UIView alloc] init];
    }
    return self;
}

#pragma mark - public

- (void)show
{
    [self showWithText:@"正在加载..." ignoreInteraction:YES];
}

- (void)showWithText:(NSString *)text ignoreInteraction:(BOOL)ignoreInteraction
{
    UIView *parentView = [self currentParentView];
    UIView *containerView = self.containerView;
    
    [containerView removeFromSuperview];
    [parentView addSubview:containerView];
    const CGSize size = parentView.bounds.size;
    containerView.frame = CGRectMake(0, 0, size.width, size.height);
    containerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight);
    
    self.showing = YES;
    if (ignoreInteraction) {
        containerView.userInteractionEnabled = YES;
    }
    [containerView ehd_showHUD:text];
}

- (void)dismiss
{
    [self dismissWithText:nil];
}

- (void)dismissWithText:(NSString *)text
{
    self.showing = NO;
    [self.containerView ehd_hideHUD];
    
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        if (!self.showing) {
            self.containerView.userInteractionEnabled = NO;
        }
    });
    
    if ([text isKindOfClass:[NSString class]]) {
        if (text.length) {
            UIView *parentView = [self currentParentView];
            [parentView ehd_showToast:text];
        }
    }
}

- (UIView *)currentParentView
{
    UIView *view = self.view;
    if ([view isKindOfClass:[UIView class]]) {
        return view;
    }
    
    if ([self.object isKindOfClass:[UIView class]]) {
        return (UIView *)self.object;
    }
    
    return [TFWindow topWindow];
}

@end

@implementation NSObject (TFHUD)

- (TFHUDManager *)TFHUD
{
    const void * key = _cmd;
    TFHUDManager *object = objc_getAssociatedObject(self, key);
    if (![object isKindOfClass:[TFHUDManager class]]) {
        object = [[TFHUDManager alloc] initWithObject:self];
        objc_setAssociatedObject(self, key, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return object;
}

@end
