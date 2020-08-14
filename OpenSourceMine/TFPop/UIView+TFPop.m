//
//  UIView+TFPop.m
//  AFNetworking
//
//  Created by admin on 2018/5/10.
//

#import "UIView+TFPop.h"
#import <objc/runtime.h>
#import "TFPopHandler.h"

@implementation UIView (TFPop)

- (void)setTfpop_backgroundView:(UIView *)tfpop_backgroundView
{
    const void * key = @selector(tfpop_backgroundView);
    const objc_AssociationPolicy policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
    
    UIView *view = self.tfpop_backgroundView;
    [view removeFromSuperview];
    objc_setAssociatedObject(self, key, tfpop_backgroundView, policy);
}

- (UIView *)tfpop_backgroundView
{
    const void * key = @selector(tfpop_backgroundView);
    const objc_AssociationPolicy policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
    
    UIView *view = objc_getAssociatedObject(self, key);
    if (![view isKindOfClass:[UIView class]]) {
        view = [[UIView alloc] init];
        objc_setAssociatedObject(self, key, view, policy);
    }
    return view;
}

- (void)tfpop_showWithConfiguration:(TFPopConfiguration *)configuration
{
    [self tfpop_showWithConfiguration:configuration inView:nil];
}

- (void)tfpop_showWithConfiguration:(TFPopConfiguration *)configuration inView:(UIView *)view
{
    if (!view) {
        view = UIApplication.sharedApplication.delegate.window;
    }
    TFPopHandler *handler = [view p_pop_handler];
    [handler show:self configuration:configuration];
}

- (void)tfpop_dismiss
{
    TFPopHandler *handler = [self.superview.superview p_pop_handler];
    [handler dismiss:self];
}

#pragma mark - private

- (TFPopHandler *)p_pop_handler
{
    const void * key = @selector(p_pop_handler);
    TFPopHandler *obj = objc_getAssociatedObject(self, key);
    if (![obj isKindOfClass:[TFPopHandler class]]) {
        obj = [[TFPopHandler alloc] initWithHostView:self];
        objc_setAssociatedObject(self, key, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return obj;
}

@end
