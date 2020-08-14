//
//  NSObject+TFHUD.h
//  EHD
//
//  Created by shenlujia on 2018/5/3.
//

#import <UIKit/UIKit.h>

@interface TFHUDManager : NSObject

@property (nonatomic, weak) UIView *view;

- (void)show; // 菊花 + 正在加载... + 屏蔽点击
- (void)showWithText:(NSString *)text ignoreInteraction:(BOOL)ignoreInteraction;

- (void)dismiss;
- (void)dismissWithText:(NSString *)text;

@end

@interface NSObject (TFHUD)

@property (nonatomic, strong, readonly) TFHUDManager *TFHUD;

@end
