//
//  TFBaseViewController.m
//  TFBaseViewController
//
//  Created by shenlujia on 2018/5/12.
//

#import "TFBaseViewController_Header.h"
#import <JZNavigationExtension.h>
#import "UIViewController+BackButtonItem.h"

#ifdef DEBUG
//#define DEBUG_THIS
#endif

#ifdef DEBUG_THIS
#define DEBUGLog(...) NSLog(__VA_ARGS__)
#else
#define DEBUGLog(...)
#endif

@interface TFBaseViewController ()

@end

@implementation TFBaseViewController

#pragma mark - lifecycle

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

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor colorWithWhite:243 / 255.0 alpha:1];
    
    [self tf_resetBackButtonItemWithTarget:self action:@selector(backAction)];
    
    self.jz_navigationBarHidden = self.jz_navigationBarHidden;
    self.jz_navigationBarBackgroundAlpha = self.jz_navigationBarBackgroundAlpha;
    self.jz_navigationBarTintColor = self.jz_navigationBarTintColor;
    self.jz_navigationInteractivePopGestureEnabled = self.jz_navigationInteractivePopGestureEnabled;
    self.jz_navigationBarBackgroundHidden = self.jz_navigationBarBackgroundHidden;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DEBUGLog(@"viewWillAppear: %@", self.title);
    
    UINavigationController *navigationController = self.navigationController;
    // 忽略 childViewControllers
    if ([navigationController.viewControllers containsObject:self]) {
        // 可能从钱包返回：钱包的translucent为NO，如果需要支持手势返回，这里必须设为YES；
        // 如果不需要支持手势返回，这里可以自定义。
        navigationController.navigationBar.translucent = self.navigationBarTranslucent;
    }
    
    // 必须调用一次
    __unused id c = navigationController.jz_previousVisibleViewController;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DEBUGLog(@"viewDidAppear: %@", self.title);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    DEBUGLog(@"viewWillDisappear: %@", self.title);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    DEBUGLog(@"viewDidDisappear: %@", self.title);
}

#pragma mark - public

- (void)backAction
{
    UINavigationController *navigationController = self.navigationController;
    if (navigationController.viewControllers.count >= 2) {
        [navigationController popViewControllerAnimated:YES];
        return;
    }
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

#pragma mark - private

- (void)p_base_commonInit
{
    self.jz_navigationBarHidden = NO;
    self.jz_navigationBarBackgroundAlpha = 1;
    self.jz_navigationInteractivePopGestureEnabled = YES; // 右滑手势打开，不在 BaseNavigationController 中设置
    self.jz_navigationBarBackgroundHidden = NO;
    // self.jz_navigationBarTintColor = UIColor.whiteColor; 方便扩展 不要在这里设置，在 BaseNavigationController 中设置
    
    self.navigationBarTranslucent = YES;
}

@end
