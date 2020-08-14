//
//  UIBarButtonItem+TFEasy.h
//  TFBaseViewController
//
//  Created by shenlujia on 2018/5/30.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (TFEasy)

+ (instancetype)tf_itemWithTitle:(NSString *)title
                     normalColor:(UIColor *)normalColor
                highlightedColor:(UIColor *)highlightedColor
                          target:(id)target
                          action:(SEL)action;

+ (instancetype)tf_itemWithTitle:(NSString *)title
                            font:(UIFont *)font
                     normalColor:(UIColor *)normalColor
                highlightedColor:(UIColor *)highlightedColor
                          target:(id)target
                          action:(SEL)action;

@end
