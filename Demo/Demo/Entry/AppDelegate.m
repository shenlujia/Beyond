//
//  AppDelegate.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *c = [[NSClassFromString(@"ViewController") alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:c];
    navi.navigationBar.translucent = NO;
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
