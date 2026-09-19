//
//  SSEasyAlert.m — stub
//

#import "SSEasyAlert.h"

@implementation SSEasyAlertConfiguration {
    void (^_confirmHandler)(UIAlertController *);
}
- (void)addAction:(NSString *)title handler:(void (^)(UIAlertController *))handler { }
- (void)addTextFieldWithHandler:(void (^)(UITextField *))handler { }
- (void)addConfirmHandler:(void (^)(UIAlertController *))handler {
    _confirmHandler = [handler copy];
}
@end

void ss_easy_alert(void (^configuration)(SSEasyAlertConfiguration *config))
{
    SSEasyAlertConfiguration *config = [[SSEasyAlertConfiguration alloc] init];
    if (configuration) configuration(config);
    // Present a real alert on top-most VC if possible
    UIViewController *topVC = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow) {
                    topVC = window.rootViewController;
                    break;
                }
            }
        }
    }
    while (topVC.presentedViewController) topVC = topVC.presentedViewController;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:config.title
                                                                   message:config.message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [topVC presentViewController:alert animated:YES completion:nil];
}
