//
//  EHDSecurityStrategy.m
//  EHDSecurity
//
//  Created by luohs on 2018/10/16.
//

#import "EHDSecurityStrategy.h"
#import <EHDComponent/EHDComponent.h>
#import <EHDSecurity/EHDSecurityBlurSnapshot.h>
#import <EHDSecurity/EHDSecurityUtilities.h>
@implementation EHDSecurityStrategy
+ (void)load
{
    [EHDURLRoute registerURL:EHDSecurityStrategyEnterprise handler:^id(NSDictionary *parameters) {
#ifndef DEBUG
        ehd_invalidGDB();
        if (ehd_debuged()) ehd_exit();
        if (ehd_jailbreak()) ehd_exit();
        id extraData = [parameters objectForKey:@"EHDRouterExtraData"];
        if ([extraData isKindOfClass:NSString.class]) {
            if(ehd_checkResign([extraData cStringUsingEncoding:NSUTF8StringEncoding])) exit(-1);
        }
#endif
        return [self strategy];
    }];
    [EHDURLRoute registerURL:EHDSecurityStrategyAppstore handler:^id(NSDictionary *parameters) {
#ifndef DEBUG
        ehd_invalidGDB();
        if (ehd_debuged()) ehd_exit();
        if (ehd_jailbreak()) ehd_exit();
        if (ehd_binaryEncrypted()==0) ehd_exit();
        id extraData = [parameters objectForKey:@"EHDRouterExtraData"];
        if ([extraData isKindOfClass:NSString.class]) {
            if(ehd_checkResign([extraData cStringUsingEncoding:NSUTF8StringEncoding])) exit(-1);
        }
#endif
        return [self strategy];
    }];
}

+ (instancetype)strategy
{
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (id)init
{
    self = [super init];
    if (self) {
        void (^notification)(NSString *, SEL) = ^(NSString *name, SEL sel) {
            NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
            [center addObserver:self
                       selector:sel
                           name:name
                         object:nil];
        };
        
        notification(UIApplicationDidFinishLaunchingNotification,
                     @selector(notification_applicationDidFinishLaunching:));
        notification(UIApplicationWillEnterForegroundNotification,
                     @selector(notification_applicationWillEnterForeground:));
        notification(UIApplicationDidEnterBackgroundNotification,
                     @selector(notification_applicationDidEnterBackground:));
    }
    return self;
}

- (void)notification_applicationDidFinishLaunching:(NSNotification *)notification
{

}

- (void)notification_applicationWillEnterForeground:(NSNotification *)notification
{
    //移除模糊效果  进入前台
    [EHDSecurityBlurSnapshot ehd_dismissSnapshot];
}

- (void)notification_applicationDidEnterBackground:(NSNotification *)notification
{
    //添加模糊效果   进入后台
    [EHDSecurityBlurSnapshot ehd_showSnapshot];
}
@end
