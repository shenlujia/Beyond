//
//

#import <UIKit/UIKit.h>

@interface HollowView : UIView

@property (nonatomic, strong, nullable, readonly) UIBezierPath *currentHollowPath;

- (void)resetHollowPath:(UIBezierPath *_Nullable)hollowPath;

- (void)resetHollowPath:(UIBezierPath *_Nullable)hollowPath animated:(BOOL)animated;

- (void)resetHollowPath:(UIBezierPath *_Nullable)hollowPath duration:(CGFloat)duration;

@end
