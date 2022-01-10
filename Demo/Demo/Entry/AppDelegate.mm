//
//  AppDelegate.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugly/Bugly.h>
#import <FLEX/FLEX.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import "MacroHeader.h"

static NSNumber *backgroundTaskIdentifier = nil;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)isViewGuidePopped:(UIView *)view
{
    return objc_getAssociatedObject(view, _cmd) != nil;
}

- (void)setViewGuidePopped:(UIView *)parentView
{
    objc_setAssociatedObject(parentView, _cmd, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Bugly startWithAppId:@"ca58095700"];

    NSString *name = nil;
    name = @"ViewController";
    name = @"DEBUGPanelController";
    name = @"SSFoundationController";
    name = @"UIKitController";

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *c = [[NSClassFromString(name) alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:c];
    navi.view.backgroundColor = UIColor.whiteColor;
    navi.navigationBar.translucent = NO;
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];

    [navi.navigationBar addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(tapBarAction)];
        tap.numberOfTapsRequired = 3;
        tap;
    })];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        navi.navigationBar.standardAppearance = appearance;
        navi.navigationBar.scrollEdgeAppearance = appearance;
    }
    
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    
    [center addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(willTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
    return YES;
}

- (void)tapBarAction
{
    [[FLEXManager sharedManager] toggleExplorer];
}

- (void)willResignActive
{
    NSLog(@"willResignActive");
}

- (void)didBecomeActive
{
    NSLog(@"didBecomeActive");
    [self p_endBackgroundTask];
}

- (void)didEnterBackground
{
    NSLog(@"didEnterBackground");
    [self p_startBackgroundTask];
}

- (void)willTerminate
{
    NSLog(@"willTerminate");
}

- (void)p_endBackgroundTask
{
    MAIN_THREAD_SAFE_SYNC(^{
        if (backgroundTaskIdentifier) {
            UIBackgroundTaskIdentifier identifier = backgroundTaskIdentifier.unsignedIntegerValue;
            backgroundTaskIdentifier = nil;
            [UIApplication.sharedApplication endBackgroundTask:identifier];
        }
    });
}

- (void)p_startBackgroundTask
{
    [self p_endBackgroundTask];
        
    UIApplication *application = UIApplication.sharedApplication;
    UIBackgroundTaskIdentifier identifier = [application beginBackgroundTaskWithName:@"HTBackgroundTask" expirationHandler:^{
        [self p_endBackgroundTask];
    }];
    backgroundTaskIdentifier = @(identifier);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 强制后台运行约 180 - 10 秒钟
        do {
            __block NSTimeInterval timeRemaining = -1;
            MAIN_THREAD_SAFE_SYNC(^{
                if (backgroundTaskIdentifier) {
                    timeRemaining = UIApplication.sharedApplication.backgroundTimeRemaining;
                    NSLog(@"backgroundTimeRemaining %.2f", timeRemaining);
                }
            });
            if (timeRemaining < 10) {
                break;
            }
            [NSThread sleepForTimeInterval:1];
        } while (YES);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self p_endBackgroundTask];
        });
    });
}

@end
