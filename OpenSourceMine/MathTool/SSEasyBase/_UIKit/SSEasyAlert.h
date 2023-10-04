//
//  Created by ZZZ on 2021/11/16.
//

#import <UIKit/UIKit.h>

@class SSEasyAlertConfiguration;

typedef void (^SSEasyAlertActionBlock)(UIAlertController *alert);
typedef void (^SSEasyAlertConfigurationBlock)(SSEasyAlertConfiguration *configuration);

FOUNDATION_EXTERN void ss_easy_alert(SSEasyAlertConfigurationBlock configuration);

@interface SSEasyAlertConfiguration : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) BOOL showsCancelAction; // default YES

- (void)addConfirmHandler:(SSEasyAlertActionBlock)handler;
- (void)addAction:(NSString *)action handler:(SSEasyAlertActionBlock)handler;

- (void)addTextFieldWithHandler:(void (^)(UITextField *textField))handler;

@end
