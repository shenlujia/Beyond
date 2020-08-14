//
//  AppDelegate.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "AppDelegate.h"
#import "SSProgressHUD.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    NSString *className = @"MainViewController";
//    className = @"TestCompoundViewController";
//    className = @"TestPropertyViewController";
//    className = @"TestTextViewController";
//    className = @"TestIndicatorViewController";
//    className = @"TestTextImageViewController";
    navigationController.viewControllers = @[[[NSClassFromString(className) alloc] init]];
    navigationController.navigationBar.translucent = NO;
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    SSProgressHUDStyle *style = [SSProgressHUDStyle defaultStyleForState:SSProgressHUDStateInfo];
    style.backgroundView.backgroundColor = nil;
    style.ignoreInteractionEvents = NO;
    [SSProgressHUDStyle setDefaultStyle:style forState:SSProgressHUDStateInfo];
    
    return YES;
}

@end
