//
//  SSEasyAlert.h — stub
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSEasyAlertConfiguration : NSObject
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *message;
- (void)addAction:(NSString *)title handler:(void (^ __nullable)(UIAlertController *alert))handler;
- (void)addTextFieldWithHandler:(void (^ __nullable)(UITextField *textField))handler;
- (void)addConfirmHandler:(void (^ __nullable)(UIAlertController *alert))handler;
@end

/// Show a simple alert. Configuration block receives a SSEasyAlertConfiguration.
FOUNDATION_EXTERN void ss_easy_alert(void (^configuration)(SSEasyAlertConfiguration *config));

NS_ASSUME_NONNULL_END
