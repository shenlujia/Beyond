//
//  UIViewController+BarShadowView.m
//  TFBaseViewController
//
//  Created by shenlujia on 2018/7/3.
//

#import "UIViewController+BarShadowView.h"
#import <objc/runtime.h>

@implementation UIViewController (BarShadowView)

- (NSNumber *)tf_barShadowViewAlpha
{
    const void * key = @selector(tf_barShadowViewAlpha);
    NSNumber *ret = objc_getAssociatedObject(self, key);
    return [ret isKindOfClass:[NSNumber class]] ? ret : nil;
}

- (void)setTf_barShadowViewAlpha:(NSNumber *)tf_barShadowViewAlpha
{
    const void * key = @selector(tf_barShadowViewAlpha);
    const objc_AssociationPolicy policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
    objc_setAssociatedObject(self, key, tf_barShadowViewAlpha, policy);
}

@end
