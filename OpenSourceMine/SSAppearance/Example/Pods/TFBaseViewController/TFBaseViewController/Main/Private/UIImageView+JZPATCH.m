//
//  UIImageView+JZPATCH.m
//  TFBaseViewController
//
//  Created by shenlujia on 2018/6/3.
//

#import "UIImageView+JZPATCH.h"
#import <objc/runtime.h>

@implementation UIImageView (JZPATCH)

- (BOOL)jz_JZPATCH_enabled
{
    const void * key = @selector(jz_JZPATCH_enabled);
    NSNumber *object = objc_getAssociatedObject(self, key);
    object = [object isKindOfClass:[NSNumber class]] ? object : nil;
    return object.boolValue;
}

- (void)setJz_JZPATCH_enabled:(BOOL)enabled
{
    const void * key = @selector(jz_JZPATCH_enabled);
    objc_setAssociatedObject(self, key, @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)set_JZPATCH_Alpha:(CGFloat)alpha
{
    if (!self.jz_JZPATCH_enabled) {
        [self set_JZPATCH_Alpha:alpha];
    }
}

- (void)set_JZPATCH_AlphaReal:(CGFloat)alpha
{
    [self set_JZPATCH_Alpha:alpha];
}

@end
