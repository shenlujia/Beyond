//
//  EHDSecurityBlurSnapshot.m
//  Pods
//
//  Created by luohs on 2018/10/17.
//
static UIView *securityBlurSnapshot;

#import "EHDSecurityBlurSnapshot.h"
//#import <UIViewController/UIViewController+ehd_topmost.h>
#import <UIImage/UIImage+ehd_blur.h>
@implementation EHDSecurityBlurSnapshot
+ (UIView *)ehd_keyWindowBlurrySnapshot
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIImage *snapshot = [UIImage imageWithData:UIImageJPEGRepresentation([self snapshot:window], 1.0)];
    UIImageView *blurView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    blurView.image = [snapshot ehd_blur];
    /*
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = blurView.bounds;
    [blurView addSubview:effectView];
    */
    return blurView;
}

//截取当前视图为图片
+ (UIImage *)snapshot:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    /*
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    */
    return image;
}

+ (void)ehd_showSnapshot
{
    [self ehd_dismissSnapshot];
    securityBlurSnapshot = [self ehd_keyWindowBlurrySnapshot];
    [[UIApplication sharedApplication].keyWindow addSubview:securityBlurSnapshot];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:securityBlurSnapshot];
}

+ (void)ehd_dismissSnapshot
{
    if (securityBlurSnapshot) {
        [securityBlurSnapshot removeFromSuperview];
        securityBlurSnapshot = nil;
    }
}
@end
