//
//  SceneDelegate.m
//  Demo
//
//  Created by ZZZ on 2023/10/5.
//

#import "SceneDelegate.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    
    NSString *name = @"ViewController";
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
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has become active.
}

- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will resign active.
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called when the scene will move from background to foreground.
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called when the scene has moved from foreground to background.
}

@end
