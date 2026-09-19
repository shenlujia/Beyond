//
//  SSDEBUGTextViewController.h — stub
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSDEBUGTextViewController : UIViewController
+ (void)showText:(NSString *)text inContainer:(nullable UIViewController *)container;
+ (NSString *)textWithJSONObject:(id)object;
@end

NS_ASSUME_NONNULL_END
