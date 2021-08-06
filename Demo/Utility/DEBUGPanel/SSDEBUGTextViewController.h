
#if INHOUSE_TARGET

#import <UIKit/UIKit.h>

@interface SSDEBUGTextViewController : UIViewController

@property (nonatomic, strong, readonly) UITextView *textView;

+ (void)showText:(NSString *)text;
+ (void)showJSONObject:(id)JSONObject;

@end

#endif
