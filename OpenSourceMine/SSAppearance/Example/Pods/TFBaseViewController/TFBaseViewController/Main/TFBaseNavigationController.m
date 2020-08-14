//
//  TFBaseNavigationController.m
//  TFBaseViewController
//
//  Created by shenlujia on 2018/5/12.
//

#import "TFBaseNavigationController.h"

@interface TFBaseNavigationController ()

@end

@implementation TFBaseNavigationController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self p_base_commonInit];
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self p_base_commonInit];
    return self;
}

- (void)p_base_commonInit
{
    self.jz_navigationBarHidden = NO;
    self.jz_navigationBarBackgroundAlpha = 1;
    self.jz_navigationInteractivePopGestureEnabled = NO; // 右滑手势关闭，在 BaseViewController 中设置
    self.jz_navigationBarBackgroundHidden = NO;
    self.jz_navigationBarTintColor = UIColor.whiteColor;
}

@end
