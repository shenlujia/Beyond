
#import <UIKit/UIKit.h>

@interface SSDEBUGTextViewController : UIViewController

@property (nonatomic, strong, readonly) UITextView *textView;

+ (void)showText:(NSString *)text;
+ (void)showJSONObject:(id)JSONObject;

@end

@interface SSDEBUGViewPanel : NSObject

+ (CGSize)itemSize;

- (void)showInView:(UIView *)view startPoint:(CGPoint)startPoint;

- (void)test:(NSString *)title action:(dispatch_block_t)action;

@end
