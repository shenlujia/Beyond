//
//  UIBarButtonItem+TFEasy.m
//  TFBaseViewController
//
//  Created by shenlujia on 2018/5/30.
//

#import "UIBarButtonItem+TFEasy.h"

@implementation UIBarButtonItem (TFEasy)

+ (instancetype)tf_itemWithTitle:(NSString *)title
                     normalColor:(UIColor *)normalColor
                highlightedColor:(UIColor *)highlightedColor
                          target:(id)target
                          action:(SEL)action
{
    return [self tf_itemWithTitle:title
                             font:[UIFont systemFontOfSize:16]
                      normalColor:normalColor
                 highlightedColor:highlightedColor
                           target:target
                           action:action];
}

+ (instancetype)tf_itemWithTitle:(NSString *)title
                            font:(UIFont *)font
                     normalColor:(UIColor *)normalColor
                highlightedColor:(UIColor *)highlightedColor
                          target:(id)target
                          action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateNormal];
    [button setTitleColor:highlightedColor forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = font;
    
    const CGSize size = [button sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    button.frame = CGRectMake(0, 0, size.width + 12, size.height + 12);
    
    return [[self alloc] initWithCustomView:button];
}

@end
