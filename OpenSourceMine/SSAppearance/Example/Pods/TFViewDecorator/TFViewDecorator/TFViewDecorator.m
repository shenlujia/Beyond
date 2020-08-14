//
//  TFViewDecorator.m
//  AFNetworking
//
//  Created by admin on 2018/6/12.
//

#import "TFViewDecorator.h"
#import <objc/runtime.h>

#define TFViewDecoratorSizeInvalid  CGSizeMake(-1, -1)

#pragma mark - TFViewDecorator

@interface TFViewDecorator : NSObject <TFViewDecorator>

@property (nonatomic, strong, readonly) TFImageGenerator *imageGenerator;
@property (nonatomic, strong, readonly) TFShadowDecorator *shadowDecorator;

@property (nonatomic, weak, readonly) UIView *view;
@property (nonatomic, assign) CGSize size;

@end

@implementation TFViewDecorator

- (instancetype)initWithView:(UIView *)view
{
    self = [self init];
    if (self) {
        _view = view;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _view = nil;
        _size = TFViewDecoratorSizeInvalid;
        
        _imageGenerator = [[TFImageGenerator alloc] init];
        _shadowDecorator = [[TFShadowDecorator alloc] init];
    }
    
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSString *text = NSStringFromSelector(aSelector);
    if ([text hasPrefix:@"set"]) {
        [self invalidate];
    }
    
    if ([self.imageGenerator respondsToSelector:aSelector]) {
        return self.imageGenerator;
    }
    
    if ([self.shadowDecorator respondsToSelector:aSelector]) {
        return self.shadowDecorator;
    }
    
    return nil;
}

- (void)invalidate
{
    _size = TFViewDecoratorSizeInvalid;
    [self.view setNeedsLayout];
}

@end

#pragma mark - TFDecoratorContentView

@interface TFDecoratorContentView : UIView

@property (nonatomic, strong, readonly) UIView *shadowView;
@property (nonatomic, strong, readonly) UIImageView *backgroundView;

@property (nonatomic, strong, readonly) TFViewDecorator *decorator;

@end

@implementation TFDecoratorContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _shadowView = [[UIView alloc] initWithFrame:self.bounds];
        self.shadowView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                                UIViewAutoresizingFlexibleHeight);
        [self addSubview:self.shadowView];
       
        _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                                UIViewAutoresizingFlexibleHeight);
        [self addSubview:self.backgroundView];
        
        _decorator = [[TFViewDecorator alloc] initWithView:self];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self decorateIfNeeded];
}

- (void)decorateIfNeeded
{
    TFDecoratorContentView *view = self;
    TFViewDecorator *decorator = self.decorator;
    const CGSize size = view.bounds.size;
    const CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    if (CGSizeEqualToSize(decorator.size, size)) {
        return;
    }
    decorator.size = size;
    
    if (view != view.superview.subviews.firstObject) {
        [view.superview insertSubview:view atIndex:0];
    }
    
    // shadowView
    UIBezierPath *shadowPath = ({
        CGSize cornerRadii = CGSizeMake(decorator.cornerRadius, decorator.cornerRadius);
        [UIBezierPath bezierPathWithRoundedRect:frame
                              byRoundingCorners:decorator.roundingCorners
                                    cornerRadii:cornerRadii];
    });
    CALayer *shadowLayer = self.shadowView.layer;
    [decorator.shadowDecorator decorate:shadowLayer];
    if (!shadowLayer.shadowPath) {
        shadowLayer.shadowPath = shadowPath.CGPath;
    }
    
    // backgroundView
    decorator.imageGenerator.size = size;
    self.backgroundView.image = [decorator.imageGenerator generate];
}

@end

#pragma mark - UIView (TFViewDecorator)

@implementation UIView (TFViewDecorator)

- (id <TFViewDecorator>)tf_decorator
{
    TFDecoratorContentView *view = [self tf_decoratorContentView];
    return view.decorator;
}

- (TFDecoratorContentView *)tf_decoratorContentView
{
    const void * key = @selector(tf_decoratorContentView);
    TFDecoratorContentView *view = objc_getAssociatedObject(self, key);
    if (![view isKindOfClass:[TFDecoratorContentView class]]) {
        const CGSize size = self.bounds.size;
        view = [[TFDecoratorContentView alloc] init];
        [self addSubview:view];
        view.userInteractionEnabled = NO;
        view.frame = CGRectMake(0, 0, size.width, size.height);
        view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
        objc_setAssociatedObject(self, key, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

@end
