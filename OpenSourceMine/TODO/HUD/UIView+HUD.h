//
//  UIView+HUD.h
//
//  Created by sj on 17/8/25.
//  Copyright © 2017年 sj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HUD)

/** toast展现，1s后消失 toast：提示文案 默认中间位置 */
- (void)ehd_showToast:(NSString *)toast;

/** toast展现，1s后消失 toast：提示文案，yoffset：y轴距离中心偏移距离*/
- (void)ehd_showToast:(NSString *)toast yoffset:(CGFloat)yoffset;

/** 展示hud text:提示文案，默认中心位置 */
- (void)ehd_showHUD:(NSString *)text;

/** 展示hud text:提示文案，默认中心位置 image:图片 yoffset：y轴距离中心偏移距离* */
- (void)ehd_showHUD:(NSString *)text yoffset:(CGFloat)yoffset;
- (void)ehd_showHUD:(NSString *)text image:(UIImage *)image yoffset:(CGFloat)yoffset;

/**  展示货嘀小豹子动图HUD */
- (void)ehd_showEHDGifHUD:(NSString *)text;

/** 去除hud */
- (void)ehd_hideHUD;

@end

@interface UIView (HUD_Deprecated)
- (void)showToastInMidView:(NSString *)toast DEPRECATED_MSG_ATTRIBUTE("Use ehd_showToast: instead");
- (void)showToast:(NSString *)toast yoffset:(CGFloat)yoffset DEPRECATED_MSG_ATTRIBUTE("Use ehd_showToast:yoffset: instead");
- (void)showHUDInMidView:(NSString *)hint DEPRECATED_MSG_ATTRIBUTE("Use ehd_showHUD: instead");
- (void)showHUDInMidView:(NSString *)hint yoffset:(CGFloat)yoffset DEPRECATED_MSG_ATTRIBUTE("Use ehd_showHUD:yoffset: instead");
- (void)showEHDGIFHudInMidView:(NSString *)hint DEPRECATED_MSG_ATTRIBUTE("Use ehd_showEHDGifHUD: instead");
- (void)showGIFHudInMidView:(NSString *)hint image:(UIImage *)image yoffset:(CGFloat)yoffset DEPRECATED_MSG_ATTRIBUTE("Use ehd_showHUD:image:yoffset: instead");
- (void)hidHUD DEPRECATED_MSG_ATTRIBUTE("Use ehd_hideHUD instead");
@end
