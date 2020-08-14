//
//  UIButton+TFAppearance.m
//  TFAppearance
//
//  Created by shenlujia on 2018/6/4.
//

#import "UIButton+TFAppearance.h"
#import <objc/runtime.h>
#import <TFViewDecorator/TFViewDecorator.h>
#import "TFAppearance.h"
#import "UIView+TFAppearance.h"

@interface TFButtonAppearanceHelper : NSObject

@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, weak, readonly) UIButton *button;

@end

@implementation TFButtonAppearanceHelper

- (instancetype)initWithButton:(UIButton *)button
{
    self = [self init];
    if (self) {
        _size = CGSizeZero;
        _button = button;
    }
    return self;
}

- (void)decorateIfNeeded
{
    UIButton *button = self.button;
    const CGSize size = button.bounds.size;
    
    Class styleClass = [TFAppearanceButtonStyle class];
    TFAppearanceButtonStyle *style = [button appearance_objectWithClass:styleClass];
    if (!style) {
        return;
    }
    
    if (!CGSizeEqualToSize(self.size, size) || style.needsUpdateAppearance) {
        _size = size;
        if (style) {
            style.needsUpdateAppearance = NO;
            [self decorate:style.normal state:UIControlStateNormal];
            [self decorate:style.highlighted state:UIControlStateHighlighted];
            [self decorate:style.disabled state:UIControlStateDisabled];
        }
    }
    
    TFAppearanceColor *shadow = nil;
    if (button.state == UIControlStateNormal) {
        shadow = style.normal.shadowColor;
    } else if (button.state == UIControlStateHighlighted) {
        shadow = style.highlighted.shadowColor;
    } else if (button.state == UIControlStateDisabled) {
        shadow = style.disabled.shadowColor;
    }
    UIColor *shadowColor = [shadow color];
    button.tf_decorator.shadowColor = shadowColor;
    button.tf_decorator.shadowOpacity = shadowColor ? 1 : 0;
    button.tf_decorator.shadowOffset = CGSizeMake(0, 3);
}

- (void)decorate:(TFAppearanceControlState *)obj state:(UIControlState)state
{
    UIButton *button = self.button;
    
    // title
    [button setTitleColor:[obj.textColor color] forState:state];
    
    // backgroundImage
    TFImageGenerator *generator = [[TFImageGenerator alloc] init];
    
    generator.size = button.bounds.size;
    UIColor *backgroundColor = [obj.backgroundColor color];
    generator.color = backgroundColor ?: UIColor.clearColor;
   
    generator.cornerRadius = button.tf_decorator.cornerRadius;
    generator.roundingCorners = button.tf_decorator.roundingCorners;
    
    generator.borderColor = [obj.borderColor color];
    generator.borderWidth = 0;
    if (generator.borderColor) {
        CGFloat borderWidth = button.tf_decorator.borderWidth;
        if (borderWidth == 0) {
            borderWidth = 1;
        }
        generator.borderWidth = borderWidth;
    }
    
    [button setBackgroundImage:[generator generate] forState:state];
}

@end

@interface UIButton (TFAppearanceInternal)

@property (nonatomic, strong, readonly) TFButtonAppearanceHelper *tf_appearance_helper;

@end

@implementation UIButton (TFAppearance)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSel = @selector(layoutSubviews);
        SEL swizzledSel = @selector(tf_appearance_layoutSubviews);
        Method originalMethod = class_getInstanceMethod(self, originalSel);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSel);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (TFButtonAppearanceHelper *)tf_appearance_helper
{
    const void * key = @selector(tf_appearance_helper);
    TFButtonAppearanceHelper *ret = objc_getAssociatedObject(self, key);
    if (![ret isKindOfClass:[TFButtonAppearanceHelper class]]) {
        ret = [[TFButtonAppearanceHelper alloc] initWithButton:self];
        objc_setAssociatedObject(self, key, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ret;
}

- (void)tf_appearance_layoutSubviews
{
    [self tf_appearance_layoutSubviews];
    [self.tf_appearance_helper decorateIfNeeded];
}

@end
