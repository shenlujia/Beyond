//
//  SSProgressHUDStyle.h
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kSSProgressHUDDefaultDuration;

typedef NS_ENUM(NSInteger, SSProgressHUDState) {
    SSProgressHUDStateLoading = 0,
    SSProgressHUDStateInfo,
    SSProgressHUDStateSuccess,
    SSProgressHUDStateError
};

typedef NS_ENUM(NSInteger, SSProgressHUDItem) {
    SSProgressHUDItemInvalid = 0,
    SSProgressHUDItemText,
    SSProgressHUDItemImage,
    SSProgressHUDItemIndicator
};

@interface SSProgressHUDStyle : NSObject <NSCopying>

////////////////////////////////////////////////////////////

@property (nonatomic, copy) NSString *text; ///< 默认 `nil`
@property (nonatomic, copy) NSAttributedString *attributedText; ///< 默认 `nil`
@property (nonatomic, copy) UIFont *font; ///< 默认 `14`
@property (nonatomic, copy) UIColor *textColor; ///< 默认 `whiteColor`
@property (nonatomic, strong) UIImage *image; ///< 默认 `nil`
@property (nonatomic, assign) UIActivityIndicatorViewStyle indicatorStyle; ///< 默认 `UIActivityIndicatorViewStyleWhite`

@property (nonatomic, assign) BOOL ignoreInteractionEvents; ///< 默认 `YES`

@property (nonatomic, assign) CGFloat duration; ///< 持续时间 默认 `kSSProgressHUDDefaultDuration`
@property (nonatomic, weak) UIView *superview; ///< 显示在指定view中 默认 mainWindow

@property (nonatomic, strong, readonly) UIView *contentView; ///< 可以设置圆角、背景色等 添加子控件无效
@property (nonatomic, strong, readonly) UIView *backgroundView; ///< 可以设置圆角、背景色等 可以添加子控件

////////////////////////////////////////////////////////////

@property (nonatomic, assign) UIEdgeInsets contentPadding; ///< 内部空白 默认 `{12, 12, 12, 12}`
@property (nonatomic, assign) UIEdgeInsets contentMargin; ///< 外部空白 默认 `{15, 15, 15, 15}`
@property (nonatomic, assign) CGPoint offset; ///< 偏移量 默认 `{0, 0}`

@property (nonatomic, assign) CGFloat verticalSpace; ///< 上下间距 默认 `5`
@property (nonatomic, assign) CGFloat horizontalSpace; ///< 左右间距 默认 `5`

/*
 * @brief 从上到下排列 支持子数组 子数组表示横向排列 例子如下
 * @brief @[@(Item), @(Item), @(Item)] 分别位于第一、二、三行
 * @brief @[@[@(Item), @(Item)], @(Item)] 前两个第一行，第三个第二行
 */
@property (nonatomic, copy) NSArray *layout;

////////////////////////////////////////////////////////////

+ (SSProgressHUDStyle *)defaultStyleForState:(SSProgressHUDState)state;
+ (void)setDefaultStyle:(SSProgressHUDStyle *)style forState:(SSProgressHUDState)state;

@end
