//
//  AppDelegate.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AppDelegate.h"
#import "MacroHeader.h"
#import "SSEasyFixBeyond.h"

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

// MARK: - Shared window factory

static UIWindow *SSCreateAppWindow(UIWindowScene *scene)
{
    NSString *name = beyond_entryClassName();
    UIWindow *window;
    if (scene) {
        window = [[UIWindow alloc] initWithWindowScene:scene];
    } else {
        window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    UIViewController *c = [[NSClassFromString(name) alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:c];
    navi.view.backgroundColor = UIColor.whiteColor;
    navi.navigationBar.translucent = NO;
    window.rootViewController = navi;

    [navi.navigationBar addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:UIApplication.sharedApplication.delegate action:@selector(tapBarAction)];
        tap.numberOfTapsRequired = 3;
        tap;
    })];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        navi.navigationBar.standardAppearance = appearance;
        navi.navigationBar.scrollEdgeAppearance = appearance;
    }
    return window;
}

// MARK: - AppDelegate

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
    // Window creation moved to SceneDelegate on iOS 13+ (required on iPhone Duo / visionOS).
    if (@available(iOS 13.0, *)) {
        // SceneDelegate will create the window in scene:willConnectToSession:options:
    } else {
        self.window = SSCreateAppWindow(nil);
        [self.window makeKeyAndVisible];
    }

    // Debug literals (kept for reference)
    __unused NSInteger kk1 = @"a".length;
    __unused NSInteger kk2 = @"💩".length;
    __unused NSInteger kk3 = @"1️⃣".length;
    __unused NSInteger kk4 = @"12345@678🏍️".length;

    NSMutableDictionary *params = [@{@"1":@"value1", @"2": @"value2"} mutableCopy];
    NSMutableDictionary *params2 = [@{@"1":@"value12", @"12": @"value23"} mutableCopy];
    [params addEntriesFromDictionary:params2];

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
    MAIN_THREAD_SAFE_SYNC(^{
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

// MARK: - SceneDelegate (iOS 13+)

#if __has_include(<UIKit/UIWindowScene.h>)
API_AVAILABLE(ios(13.0))
@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (nonatomic, strong, nullable) UIWindow *window;
@end

API_AVAILABLE(ios(13.0))
@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions
{
    if (![scene isKindOfClass:[UIWindowScene class]]) return;
    self.window = SSCreateAppWindow((UIWindowScene *)scene);
    [self.window makeKeyAndVisible];

    // Sync window reference back to AppDelegate for compatibility.
    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    if ([appDelegate isKindOfClass:[AppDelegate class]]) {
        appDelegate.window = self.window;
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene { }
- (void)sceneDidBecomeActive:(UIScene *)scene { }
- (void)sceneWillResignActive:(UIScene *)scene { }
- (void)sceneWillEnterForeground:(UIScene *)scene { }
- (void)sceneDidEnterBackground:(UIScene *)scene { }

@end
#endif
