//
//  SSProgressHUD.h
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSProgressHUDStyle.h"

@interface SSProgressHUD : NSObject

@property (nonatomic, assign) NSTimeInterval fadeInDuration;  // default is 0.15
@property (nonatomic, assign) NSTimeInterval fadeOutDuration; // default is 0.15

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) SSProgressHUDStyle *style;

+ (instancetype)sharedHUD;

// 显示一段时间后自动消失 若duration没有设置 根据text长度自动调整duration
- (void)showInfoWithStyle:(void (^)(SSProgressHUDStyle *style))style;
- (void)showSuccessWithStyle:(void (^)(SSProgressHUDStyle *style))style;
- (void)showErrorWithStyle:(void (^)(SSProgressHUDStyle *style))style;

// 显示时间为duration
- (void)showWithStyle:(SSProgressHUDStyle *)style;

- (void)dismiss;
+ (void)dismissAll;

@end
