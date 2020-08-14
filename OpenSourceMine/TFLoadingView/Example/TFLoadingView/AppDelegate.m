//
//  AppDelegate.m
//  TFLoadingView
//
//  Created by admin on 2018/4/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController = ({
        NSString *className = @"ViewController";
        UIViewController *controller = [[NSClassFromString(className) alloc] init];
        [[UINavigationController alloc] initWithRootViewController:controller];
    });
    
    self.window = ({
        CGRect frame = UIScreen.mainScreen.bounds;
        UIWindow *window = [[UIWindow alloc] initWithFrame:frame];
        window.rootViewController = navigationController;
        window;
    });
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
