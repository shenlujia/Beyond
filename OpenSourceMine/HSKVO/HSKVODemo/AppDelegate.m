//
//  AppDelegate.m
//  HSKVO
//
//  Created by shenlujia on 2016/1/7.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController = ({
        UINavigationController *controller = [[UINavigationController alloc] init];
        NSString *className = @"MainViewController";
        controller.viewControllers = @[[[NSClassFromString(className) alloc] init]];
        controller.navigationBar.translucent = NO;
        controller;
    });
    
    self.window = ({
        CGRect frame = [[UIScreen mainScreen] bounds];
        UIWindow *window = [[UIWindow alloc] initWithFrame:frame];
        window.rootViewController = navigationController;
        [window makeKeyAndVisible];
        window;
    });
    
    return YES;
}

@end
