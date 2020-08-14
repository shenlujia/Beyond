//
//  AppDelegate.m
//  Demo
//
//  Created by TF020283 on 2018/9/27.
//  Copyright © 2018 TF020283. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController = ({
        NSString *className = @"MainViewController";
        UIViewController *controller = [[NSClassFromString(className) alloc] init];
        [[UINavigationController alloc] initWithRootViewController:controller];
    });
    navigationController.navigationBar.translucent = NO;
    
    self.window = ({
        CGRect frame = UIScreen.mainScreen.bounds;
        UIWindow *window = [[UIWindow alloc] initWithFrame:frame];
        window.rootViewController = navigationController;
        [window makeKeyAndVisible];
        window;
    });
    
    return YES;
}

@end
