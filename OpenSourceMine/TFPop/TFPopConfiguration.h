//
//  TFPopConfiguration.h
//  TFPop
//
//  Created by admin on 2018/5/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////

typedef NS_OPTIONS(NSInteger, TFPopOptions) {
    TFPopLeft        = 1 << 0, // 左边
    TFPopRight       = 1 << 1, // 右边
    TFPopTop         = 1 << 2, // 上面
    TFPopBottom      = 1 << 3, // 下面
    TFPopMiddle      = 1 << 4, // 中心
    TFPopAlpha       = 1 << 5, // alpha动画
};

typedef NS_ENUM(NSInteger, TFPopDismissMode) {
    TFPopDismissModeNone = 1,
    TFPopDismissModeTapMask
};

////////////////////////////////////////////////////////////

@protocol TFPopDelegate <NSObject>
@optional
- (void)popViewWillAppear:(UIView *)view;
- (void)popViewDidAppear:(UIView *)view;
- (void)popViewWillDisappear:(UIView *)view;
- (void)popViewDidDisappear:(UIView *)view;
@end

////////////////////////////////////////////////////////////

@interface TFPopConfiguration : NSObject

@property (nonatomic, weak) id <TFPopDelegate> delegate;

@property (nonatomic, assign) TFPopOptions beginOptions; // 默认 TFPopBottom | TFPopMiddle
@property (nonatomic, assign) TFPopOptions showOptions; // 默认 TFPopBottom | TFPopMiddle
@property (nonatomic, assign) TFPopOptions endOptions; // 默认 TFPopBottom | TFPopMiddle

@property (nonatomic, assign) TFPopDismissMode dismissMode; // 默认 TFPopDismissModeNone
@property (nonatomic, assign) BOOL automaticallyAdjustsSafeAreaInsets; // 默认 NO

@property (nonatomic, assign) UIOffset offset; // 默认 UIOffsetZero

@property (nonatomic, assign) NSTimeInterval showAnimationDuration; // 默认 0.25
@property (nonatomic, assign) NSTimeInterval dismissAnimationDuration; // 默认 0.25

@end

////////////////////////////////////////////////////////////
