//
//  AppDelegate.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AppDelegate.h"

#define MAIN_THREAD_SAFE_SYNC(action) \
do { \
  if (!action) { \
    break; \
  } \
  if ([NSThread.currentThread isMainThread]) { \
    action(); \
  } else { \
     dispatch_sync(dispatch_get_main_queue(), ^{ \
         action(); \
     }); \
  } \
} while (0);


#define PRINT_BLANK_LINE printf("\n");


#define SS_MAIN_DELAY(time, block) \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ \
  block(); \
});


#define SS_GLOBAL_DELAY(time, block) \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{ \
  block(); \
});

static NSNumber *backgroundTaskIdentifier = nil;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIViewController *c = [[NSClassFromString(@"T1ViewController") alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:c];
    navi.navigationBar.translucent = NO;
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self didBecomeActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self didEnterBackground];
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
