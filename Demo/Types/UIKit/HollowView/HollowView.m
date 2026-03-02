//
//

#import "HollowView.h"

@interface HollowView ()

@property (nonatomic, strong) CAShapeLayer *hollowMaskLayer;
@property (nonatomic, strong) UIBezierPath *currentMainPath;

@end

@implementation HollowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

- (CAShapeLayer *)hollowMaskLayer
{
    if (!_hollowMaskLayer) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillRule = kCAFillRuleEvenOdd;
        layer.path = [[self emptyBezierPath] CGPath];
        self.layer.mask = layer;
        _hollowMaskLayer = layer;
    }
    return _hollowMaskLayer;
}

- (void)resetHollowPath:(UIBezierPath *_Nullable)hollowPath
{
    BOOL animated = (self.currentHollowPath != nil);
    [self resetHollowPath:hollowPath animated:animated];
}

- (void)resetHollowPath:(UIBezierPath *_Nullable)hollowPath animated:(BOOL)animated
{
    [self resetHollowPath:hollowPath duration:animated ? 0.25 : 0];
}

- (void)resetHollowPath:(UIBezierPath *_Nullable)hollowPath duration:(CGFloat)duration
{
    _currentHollowPath = hollowPath;
    
    NSString *animationKey = @"pathAnimation";
    CAShapeLayer *maskLayer = self.hollowMaskLayer;
    if (self.currentMainPath) {
        maskLayer.path = self.currentMainPath.CGPath;
    }
    [maskLayer removeAnimationForKey:animationKey];
    
    CGSize size = self.bounds.size;
    UIBezierPath *toBezierPath = nil;
    if (hollowPath) {
        toBezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
        [toBezierPath appendPath:hollowPath];
    } else {
        toBezierPath = [self emptyBezierPath];
    }
    self.currentMainPath = toBezierPath;
    
    if (duration > 0) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
        animation.toValue = (__bridge id _Nullable)(toBezierPath.CGPath);
        animation.duration = duration;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [maskLayer addAnimation:animation forKey:animationKey];
    } else {
        maskLayer.path = toBezierPath.CGPath;
    }
}

- (UIBezierPath *)emptyBezierPath
{
    CGSize size = self.bounds.size;
    UIBezierPath *ret = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithRect:CGRectMake(size.width / 2, size.height / 2, 0, 0)];
    [ret appendPath:innerPath];
    return ret;
}

@end
