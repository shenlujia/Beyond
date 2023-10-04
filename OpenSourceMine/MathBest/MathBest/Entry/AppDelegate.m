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
    NSString *name = @"MathExercisesController";
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *c = [[NSClassFromString(name) alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:c];
    navi.view.backgroundColor = UIColor.whiteColor;
    navi.navigationBar.translucent = NO;
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];

    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        navi.navigationBar.standardAppearance = appearance;
        navi.navigationBar.scrollEdgeAppearance = appearance;
    }
    
    return YES;
}

@end
