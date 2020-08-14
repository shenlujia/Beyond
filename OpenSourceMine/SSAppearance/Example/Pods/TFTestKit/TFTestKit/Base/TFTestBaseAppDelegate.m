//
//  TFTestBaseAppDelegate.m
//  AFNetworking
//
//  Created by admin on 2018/6/4.
//

#import "TFTestBaseAppDelegate.h"

static NSString *_controllerName = nil;

@interface TFTestBaseAppDelegate ()

@end

@implementation TFTestBaseAppDelegate

+ (void)setControllerName:(NSString *)controllerName
{
    _controllerName = controllerName;
}

+ (NSString *)controllerName
{
    return _controllerName;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController = ({
        NSString *className = _controllerName;
        if (!className) {
            className = @"ViewController";
        }
        UIViewController *controller = [[NSClassFromString(className) alloc] init];
        [[UINavigationController alloc] initWithRootViewController:controller];
    });
    
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
