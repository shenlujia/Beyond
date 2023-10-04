//
//  Created by ZZZ on 2021/11/16.
//

#import "SSEasyAlert.h"
#import <objc/runtime.h>

@interface SSEasyAlertConfiguration ()

@property (nonatomic, strong, readonly) NSMutableArray *items;
@property (nonatomic, strong, readonly) NSMutableArray *textFieldHandlers;

@property (nonatomic, weak) UIAlertController *alert;

@end

@implementation SSEasyAlertConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        _showsCancelAction = YES;
        _items = [NSMutableArray array];
        _textFieldHandlers = [NSMutableArray array];
    }
    return self;
}

- (void)addConfirmHandler:(SSEasyAlertActionBlock)handler
{
    [self addAction:@"确定" handler:handler];
}

- (void)addAction:(NSString *)action handler:(SSEasyAlertActionBlock)handler
{
    __weak SSEasyAlertConfiguration *weakConfiguration = self;
    UIAlertAction *item = [UIAlertAction actionWithTitle:action style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (handler) {
            handler(weakConfiguration.alert);
        }
    }];
    [self.items addObject:item];
}

- (void)addTextFieldWithHandler:(void (^)(UITextField *textField))handler
{
    [self.textFieldHandlers addObject:handler];
}

@end

UIViewController * ss_easy_top_controller_of(UIViewController *controller)
{
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *c = (UINavigationController *)controller;
        return ss_easy_top_controller_of(c.topViewController);
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *c = (UITabBarController *)controller;
        return ss_easy_top_controller_of(c.selectedViewController);
    } else if (controller.presentedViewController) {
        return controller.presentedViewController;
    }
    return controller;
}

UIViewController * ss_easy_top_controller(void)
{
    id c = NSClassFromString(@"BTDResponder");
    if ([c respondsToSelector:NSSelectorFromString(@"topViewController")]) {
        return [c valueForKey:@"topViewController"];
    }
    UIWindow *window = UIApplication.sharedApplication.delegate.window;
    UIViewController *controller = window.rootViewController;
    return ss_easy_top_controller_of(controller);
}

void ss_easy_alert(SSEasyAlertConfigurationBlock configuration)
{
    UIViewController *controller = ss_easy_top_controller();
    if (!controller || !configuration) {
        return;
    }
    
    SSEasyAlertConfiguration *object = [[SSEasyAlertConfiguration alloc] init];
    configuration(object);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:object.title message:object.message preferredStyle:UIAlertControllerStyleAlert];
    objc_setAssociatedObject(alert, @selector(addAction:handler:), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    object.alert = alert;
    
    for (void (^handler)(UITextField *textField) in object.textFieldHandlers) {
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            handler(textField);
        }];
    }
    
    if (object.showsCancelAction) {
        UIAlertAction *item = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        [alert addAction:item];
    }
    
    for (UIAlertAction *item in object.items) {
        [alert addAction:item];
    }
    
    [controller presentViewController:alert animated:YES completion:^{
        
    }];
}
