//
//  UIView+HUD.m
//
//  Created by sj on 17/8/25.
//  Copyright © 2017年 sj. All rights reserved.
//

#import "UIView+HUD.h"

#import <objc/runtime.h>
#import <SDWebImage/UIImage+GIF.h>
#import <NSBundle/NSBundle+ResourceBundle.h>
#import <TFAppConfiguration/TFAppConfiguration.h>
#import <UIImage/UIImage+EHDBundleImage.h>
#import <UIColor/UIColor+HexString.h>
#import <TFViewDecorator/TFViewDecorator.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#import <MBProgressHUD/MBProgressHUD.h>
#pragma clang diagnostic pop

@interface UIView (HUD_Private)

@property (nonatomic, strong) MBProgressHUD *ehd_currentHUD;

@end

@implementation UIView (HUD)

- (MBProgressHUD *)ehd_currentHUD
{
    const void * key = @selector(ehd_currentHUD);
    return objc_getAssociatedObject(self, key);
}

- (void)setEhd_currentHUD:(MBProgressHUD *)ehd_currentHUD
{
    const void * key = @selector(ehd_currentHUD);
    objc_setAssociatedObject(self, key, ehd_currentHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)ehd_showToast:(NSString *)toast
{
    [self ehd_showToast:toast yoffset:0];
}

- (void)ehd_showToast:(NSString *)toast yoffset:(CGFloat)yoffset
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
    HUD.userInteractionEnabled = NO;
    HUD.mode = MBProgressHUDModeText;
    HUD.detailsLabelText = toast;
    HUD.detailsLabelFont = [UIFont systemFontOfSize:16];
    HUD.margin = 10;
    HUD.yOffset += yoffset;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:1];
}

- (void)ehd_showHUD:(NSString *)text
{
    [self ehd_showHUD:text yoffset:0];
}

- (void)ehd_showHUD:(NSString *)text yoffset:(CGFloat)yoffset
{
    [self ehd_hideHUD];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self];
    HUD.labelText = text;
    HUD.yOffset += yoffset;
    [self addSubview:HUD];
    [HUD show:YES];
    
    self.ehd_currentHUD = HUD;
}

- (void)ehd_showEHDGifHUD:(NSString *)text
{
    switch (TFAppConfiguration.other.appType) {
        case TFConfigurationAppShipper:
        case TFConfigurationAppDriver:
        {
            NSBundle *bundle = [NSBundle ehd_bundleWithBundleName:@"UIView_HUD" frameWorkName:@"UIView"];
            NSString *path = [bundle pathForResource:@"loadImage" ofType:@"gif" inDirectory:nil];
            NSData *data = [NSData dataWithContentsOfFile:path];
            UIImage *image = [UIImage sd_animatedGIFWithData:data];
            
            [self ehd_showHUD:text image:image animationImgaes:nil backgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7] yoffset:0];
        }
            break;
        case TFConfigurationAppCharger:
        {
            NSMutableArray *images = [NSMutableArray arrayWithCapacity:60];
            for (NSInteger i = 0; i < 60; i++) {
                [images addObject:[UIImage ehd_imageWithBundleName:@"UIView_HUD" imageName:[NSString stringWithFormat:@"loader_%05ld", i]]];
            }
            [self ehd_showHUD:text image:nil animationImgaes:images backgroundColor:[[UIColor colorWithHexString:@"#1DA295"] colorWithAlphaComponent:0.8] yoffset:0];
        }
            break;
            
        default:
            break;
    }

}

- (void)ehd_showHUD:(NSString *)text image:(UIImage *)image animationImgaes:(NSArray *)animationImgaes backgroundColor:(UIColor *)backgroundColor yoffset:(CGFloat)yoffset
{
    [self ehd_hideHUD];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
    HUD.mode = MBProgressHUDModeCustomView;
    
    UIView *backView = [[UIView alloc] init];
    backView.tf_decorator.color = backgroundColor;
    
    
    UIImageView *gifImageView = [[UIImageView alloc] init];
    [backView addSubview:gifImageView];
    

    
    UILabel *hintLab = [[UILabel alloc]init];
    hintLab.textColor = [UIColor whiteColor];
    hintLab.font = [UIFont systemFontOfSize:15];
    hintLab.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:hintLab];
    hintLab.text = text;
    //小豹子配置
    if (image) {
        hintLab.numberOfLines = 1;
        backView.tf_decorator.cornerRadius = 5;
        backView.frame = CGRectMake(0, 0, 90, 90);
        gifImageView.frame = CGRectMake(22.5, 10, 45, 45);
        hintLab.frame = CGRectMake(5, 63, 80, 15);
        gifImageView.image = image;
        //慧连动画配置
    } else if (animationImgaes) {
        backView.tf_decorator.cornerRadius = 12;
        backView.tf_decorator.shadowColor = [UIColor colorWithHexString:@"#0E7A70"];
        backView.tf_decorator.shadowOpacity = 0.4;
        backView.tf_decorator.shadowOffset = CGSizeMake(0, 0);
        backView.tf_decorator.shadowRadius = 5;
        backView.frame = CGRectMake(0, 0, 120, 120);
        gifImageView.frame = CGRectMake(28, 27, 69, 30);
        hintLab.frame = CGRectMake(10, 68, 100, 36);
        hintLab.font = [UIFont systemFontOfSize:14];
        hintLab.numberOfLines = 0;
        gifImageView.animationImages = animationImgaes;
        [gifImageView startAnimating];
    }
    HUD.customView = backView;
    HUD.color = [UIColor clearColor];
    HUD.yOffset += yoffset;
    
    self.ehd_currentHUD = HUD;
}



- (void)ehd_hideHUD
{
    [self.ehd_currentHUD removeFromSuperview];
    self.ehd_currentHUD = nil;
}

@end

#pragma mark - UIView (HUD_Deprecated)

@implementation UIView (HUD_Deprecated)

- (void)showToastInMidView:(NSString *)toast
{
    [self ehd_showToast:toast];
}

- (void)showToast:(NSString *)toast yoffset:(CGFloat)yoffset
{
    [self ehd_showToast:toast yoffset:yoffset];
}

- (void)showHUDInMidView:(NSString *)hint
{
    [self ehd_showHUD:hint];
}

- (void)showHUDInMidView:(NSString *)hint yoffset:(CGFloat)yoffset
{
    [self ehd_showHUD:hint yoffset:yoffset];
}

- (void)showEHDGIFHudInMidView:(NSString *)hint
{
    [self ehd_showEHDGifHUD:hint];
}

- (void)showGIFHudInMidView:(NSString *)hint image:(UIImage *)image yoffset:(CGFloat)yoffset
{
    [self ehd_showHUD:hint image:image yoffset:yoffset];
}

- (void)hidHUD
{
    [self ehd_hideHUD];
}

@end
