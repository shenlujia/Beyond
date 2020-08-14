//
//  TFWindow.m
//  Pods-TFWindow
//
//  Created by admin on 2018/5/12.
//

#import "TFWindow.h"

@implementation TFWindow

- (instancetype)initWithType:(TFWindowType)type
{
    self = [self init];
    if (self) {
        _type = type;
        self.windowLevel = UIWindowLevelNormal + type;
    }
    return self;
}

+ (__kindof UIWindow *)topWindow
{
    UIWindow *ret = UIApplication.sharedApplication.delegate.window;
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
        if (![window isKindOfClass:[TFWindow class]]) {
            continue;
        }
        if (window.hidden) {
            continue;
        }
        if (!window.userInteractionEnabled) {
            continue;
        }
        if (window.alpha <= 0.01) {
            continue;
        }
        if (!ret || ret.windowLevel < window.windowLevel) {
            ret = window;
        }
    }
    return ret;
}

+ (__kindof UIViewController *)topViewController
{
    UIWindow *window = [TFWindow topWindow];
    UIViewController *ret = window.rootViewController;
    
    while (YES) {
        if ([ret isKindOfClass:[UINavigationController class]]) {
            ret = ((UINavigationController *)ret).topViewController;
        } else if ([ret isKindOfClass:[UITabBarController class]]) {
            ret = ((UITabBarController *)ret).selectedViewController;
        } else if (ret.presentedViewController) {
            ret = ret.presentedViewController;
        } else {
            break;
        }
    }
    
    return ret;
}

@end
