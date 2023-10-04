//
//  AppDelegate.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AppDelegate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#pragma clang diagnostic ignored "-Wunused-command-line-argument"
#pragma clang diagnostic ignored "-Wquoted-include-in-framework-header"
//#import <Bugly/Bugly.h>
#import <FLEX/FLEX.h>
#pragma clang diagnostic pop

static NSNumber *m_backgroundTaskIdentifier = nil;
static NSTimer *m_timer = nil;

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
//    [Bugly startWithAppId:@"ca58095700"];
//    [BuglyLog initLogger:BuglyLogLevelError consolePrint:NO];
    
    NSString *name = @"MathExercisesController";
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
    
    [m_timer invalidate];
}

- (void)didEnterBackground
{
    NSLog(@"didEnterBackground");
    [self p_startBackgroundTask];
    
    CGFloat now = [[NSDate date] timeIntervalSince1970];
    [m_timer invalidate];
    m_timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"background action, duration = %.2f", [[NSDate date] timeIntervalSince1970] - now);
    }];
}

- (void)willTerminate
{
    NSLog(@"willTerminate");
}

- (void)p_endBackgroundTask
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (m_backgroundTaskIdentifier) {
            UIBackgroundTaskIdentifier identifier = m_backgroundTaskIdentifier.unsignedIntegerValue;
            m_backgroundTaskIdentifier = nil;
            [UIApplication.sharedApplication endBackgroundTask:identifier];
        }
    });
}

- (void)p_startBackgroundTask
{
    [self p_endBackgroundTask];
        
    UIApplication *application = UIApplication.sharedApplication;
    CGFloat now = [[NSDate date] timeIntervalSince1970];
    UIBackgroundTaskIdentifier identifier = [application beginBackgroundTaskWithName:@"HTBackgroundTask" expirationHandler:^{
        NSLog(@"BackgroundTask[duration=%.2f] expired", [[NSDate date] timeIntervalSince1970] - now);
        [self p_endBackgroundTask];
    }];
    m_backgroundTaskIdentifier = @(identifier);
}

@end
