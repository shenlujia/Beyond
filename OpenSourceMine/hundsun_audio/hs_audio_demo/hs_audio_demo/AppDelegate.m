//
//  AppDelegate.m
//  hs_audio_demo
//
//  Created by shenlujia on 16/6/5.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *controller = [[ViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
