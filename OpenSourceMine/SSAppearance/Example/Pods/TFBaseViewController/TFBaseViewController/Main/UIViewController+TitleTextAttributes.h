//
//  UIViewController+TitleTextAttributes.h
//  TFBaseViewController
//
//  Created by shenlujia on 2018/6/5.
//

#import <UIKit/UIKit.h>

@interface TFTitleAttributes : NSObject

@property (nonatomic, copy) UIColor *textColor;
@property (nonatomic, copy) UIFont *font;
@property (nonatomic, copy) UIColor *shadowColor;
@property (nonatomic, assign) CGSize shadowOffset;

@end

@interface UIViewController (TitleTextAttributes)

@property (nonatomic, strong, readonly) TFTitleAttributes *tf_titleAttributes;

@end
