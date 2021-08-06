
#if INHOUSE_TARGET

#import <UIKit/UIKit.h>

@interface SSDEBUGViewPanel : NSObject

+ (CGSize)itemSize;

- (void)showInView:(UIView *)view;

- (void)showInView:(UIView *)view startPoint:(CGPoint)startPoint;

- (void)test:(NSString *)title action:(dispatch_block_t)action;

@end

#endif
