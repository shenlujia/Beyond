//
//  TFLoadingView.m
//  Pods
//
//  Created by shenlujia on 15/9/6.
//
//

#import "TFLoadingView.h"
#import <TFAppearance/TFAppearance.h>
#import <TFViewDecorator/TFViewDecorator.h>
#import <objc/runtime.h>
#import "TFLinearLayoutView.h"

@interface TFLoadingView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIButton *fullButton;

@property (nonatomic, strong) TFLinearLayoutView *mainLayoutView;
@property (nonatomic, strong) TFLinearLayoutView *horizontalLayoutView;

@end

@implementation TFLoadingView

#pragma mark - lifecycle

- (void)dealloc
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    const CGSize size = frame.size;
    
    self.fullButton = ({
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        view.backgroundColor = UIColor.clearColor;
        view.frame = CGRectMake(0, 0, size.width, size.height);
        view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
        
        [view addTarget:self
                 action:@selector(touchUpInside)
       forControlEvents:UIControlEventTouchUpInside];
        
        view;
    });
    [self addSubview:self.fullButton];
    
    _textLabel = ({
        UILabel *view = [[UILabel alloc] init];
        view.backgroundColor = UIColor.clearColor;
        view.textAlignment = NSTextAlignmentLeft;
        view.numberOfLines = 0;
        [TFAppearance.text.other1Style decorate:view];
        [TFAppearance.font.size16 decorate:view];
        view;
    });
    
    self.imageView = ({
        UIImageView *view = [[UIImageView alloc] init];
        view.contentMode = UIViewContentModeScaleAspectFit;
        view;
    });
    [self addSubview:self.imageView];
    
    self.indicatorView = ({
        UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleGray;
        UIActivityIndicatorView *view = ({
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        });
        view;
    });
    [self addSubview:self.indicatorView];
    
    _reloadButton = ({
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        [view addTarget:self
                 action:@selector(bottomButtonAction)
       forControlEvents:UIControlEventTouchUpInside];
        [TFAppearance.font.size16 decorate:view];
        view;
    });
    
    self.horizontalLayoutView = ({
        TFLinearLayoutView *view = [[TFLinearLayoutView alloc] init];
        view.backgroundColor = UIColor.clearColor;
        view.layoutType = TFLinearLayoutTypeHorizontal;
        view;
    });
    [self addSubview:self.horizontalLayoutView];
    
    self.mainLayoutView = ({
        TFLinearLayoutView *view = [[TFLinearLayoutView alloc] init];
        view.backgroundColor = UIColor.clearColor;
        view.layoutType = TFLinearLayoutTypeVertical;
        view;
    });
    [self addSubview:self.mainLayoutView];
    
    self.state = TFLoadingStateHidden;
    
    return self;
}

- (void)layoutSubviews
{
    [self updateLayoutView];
    [super layoutSubviews];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self.mainLayoutView ||
        view == self.horizontalLayoutView ||
        view == self.textLabel ||
        view == self.indicatorView ||
        view == self.imageView) {
        return self.fullButton;
    }
    return view;
}

#pragma mark - public

- (void)setState:(TFLoadingState)state
{
    [self.superview bringSubviewToFront:self];
    if ([self.superview isKindOfClass:UIScrollView.class]) {
        UIScrollView *superview = (UIScrollView *)self.superview;
        superview.scrollEnabled = (state == TFLoadingStateHidden);
    }
    
    _state = state;
    self.hidden = (state == TFLoadingStateHidden);
    self.backgroundColor = self.configuration.backgroundColor;
    
    if (state == TFLoadingStateLoading) {
        [self.indicatorView startAnimating];
    } else {
        [self.indicatorView stopAnimating];
    }
    
    // style
    TFLoadingStyle *style = [self.configuration styleForState:state];
    self.imageView.image = style.image;
    self.textLabel.textAlignment = style.textAlignment;
    //    self.textLabel.lineSpacing_ = state != TFLoadingStateLoading ? style.lineSpacing : 0;
    self.textLabel.text = style.text;
    if (style.attributedText) {
        self.textLabel.attributedText = style.attributedText;
    }
    [self.textLabel setNeedsLayout];
    [self.textLabel layoutIfNeeded];
    
    UIButton *button = self.reloadButton;
    [button setTitle:style.buttonNormalTitle forState:UIControlStateNormal];
    [button setTitle:style.buttonHighlightedTitle forState:UIControlStateHighlighted];
    button.tf_decorator.cornerRadius = style.buttonCornerRadius;
    if (style.buttonStyle) {
        [style.buttonStyle decorate:button];
    } else {
        [TFAppearance.button.hollowStyle decorate:button];
    }
    
    [self updateLayoutView];
}

- (TFLoadingConfiguration *)configuration
{
    if (!_configuration) {
        TFLoadingConfiguration *defaultConfiguration = [TFLoadingConfiguration defaultConfiguration];
        _configuration = [[TFLoadingConfiguration alloc] init];
        _configuration.ignoreTouchIfStateEmpty = defaultConfiguration.ignoreTouchIfStateEmpty;
        _configuration.backgroundColor = defaultConfiguration.backgroundColor;
    }
    return _configuration;
}

#pragma mark - action

- (void)touchUpInside
{
    if ([self shouldIgnoreTouch]) {
        return;
    }
    
    if (self.tapBlock) {
        self.tapBlock(self);
    }
}

- (void)bottomButtonAction
{
    TFLoadingStyle *style = [self.configuration styleForState:self.state];
    if (style.buttonTapBlock) {
        style.buttonTapBlock();
    } else {
        if (self.tapBlock) {
            self.tapBlock(self);
        }
    }
}

#pragma mark - private

- (CGFloat)maxContentWidth
{
    return ceil(0.8 * self.bounds.size.width);
}

- (void)updateLayoutView
{
    // cleanup
    [self.mainLayoutView cleanup];
    [self.horizontalLayoutView cleanup];
    
    TFLoadingStyle *style = [self.configuration styleForState:self.state];
    UIView *textLabel = (self.textLabel.attributedText.length > 0) ? self.textLabel : nil;
    UIView *imageView = (!!self.imageView.image) ? self.imageView : nil;
    const CGSize buttonSize = style.buttonSize;
    self.reloadButton.bounds = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    UIView *button = !CGSizeEqualToSize(buttonSize, CGSizeZero) ? self.reloadButton : nil;
    
    const CGFloat verticalMargin = style.itemVerticalMargin;
    const CGFloat horizontalMargin = style.itemHorizontalMargin;
    
    UIView *indicatorView = self.indicatorView;
    
    __weak typeof (self) weakSelf = self;
    const CGFloat contentWidth = [self maxContentWidth];
    
    // 显示 horizontalLayoutView
    if (indicatorView && textLabel) {
        [self.horizontalLayoutView addItem:^(TFLinearLayoutItem *item) {
            item.view = indicatorView;
            item.size = indicatorView.bounds.size;
            item.edgeInsets = UIEdgeInsetsMake(0, 0, 0, horizontalMargin);
            item.contentMode = TFLinearLayoutContentModeCenter;
        }];
        [self.horizontalLayoutView addItem:^(TFLinearLayoutItem *item) {
            item.view = textLabel;
            item.size = CGSizeMake(contentWidth - horizontalMargin - indicatorView.bounds.size.width, 0);
            item.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            item.contentMode = TFLinearLayoutContentModeCenter;
        }];
        
        [self.horizontalLayoutView reloadItemsWithLimit:NSIntegerMax];
        CGSize horizontalSize = self.horizontalLayoutView.contentSize;
        horizontalSize.height = MAX(CGRectGetHeight(indicatorView.bounds), CGRectGetHeight(textLabel.bounds));
        
        [self.mainLayoutView addItem:^(TFLinearLayoutItem *item) {
            item.view = imageView;
            item.size = imageView.bounds.size;
            item.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
            item.contentMode = TFLinearLayoutContentModeCenter;
        }];
        
        [self.mainLayoutView addItem:^(TFLinearLayoutItem *item) {
            item.view = weakSelf.horizontalLayoutView;
            item.size = horizontalSize;
            item.edgeInsets = UIEdgeInsetsMake(verticalMargin, 0, 0, 0);
            item.contentMode = TFLinearLayoutContentModeCenter;
        }];
        
        if (button) {
            [self.mainLayoutView addItem:^(TFLinearLayoutItem *item) {
                item.view = button;
                item.size = style.buttonSize;
                item.edgeInsets = UIEdgeInsetsMake(verticalMargin, 0, 0, 0);
                item.contentMode = TFLinearLayoutContentModeCenter;
            }];
        }
        
    } else {
        NSMutableArray *views = [NSMutableArray array];
        if (imageView) {
            [views addObject:imageView];
        }
        if (indicatorView) {
            [views addObject:indicatorView];
        }
        if (textLabel) {
            [views addObject:textLabel];
        }
        if (button) {
            [views addObject:button];
        }
        
        [views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            CGFloat marginY = (idx != views.count - 1) ? verticalMargin : 0;
            [self.mainLayoutView addItem:^(TFLinearLayoutItem *item) {
                item.view = view;
                if (![view isKindOfClass:UILabel.class]) {
                    item.size = view.bounds.size;
                }
                item.edgeInsets = UIEdgeInsetsMake(0, 0, marginY, 0);
                item.contentMode = TFLinearLayoutContentModeCenter;
            }];
        }];
    }
    
    [self.mainLayoutView reloadItemsWithLimit:contentWidth];
    const CGSize viewSize = self.bounds.size;
    const UIEdgeInsets insets = style.contentEdgeInsets;
    
    CGRect frame = CGRectZero;
    frame.size = self.mainLayoutView.contentSize;
    frame.origin.x = (viewSize.width - frame.size.width) / 2;
    
    switch (style.verticalAlignment) {
        case UIControlContentVerticalAlignmentTop: {
            frame.origin.y = insets.top;
            break;
        }
        case UIControlContentVerticalAlignmentCenter: {
            frame.origin.y = insets.top + (viewSize.height - insets.top - insets.bottom - frame.size.height) / 2;
            break;
        }
        case UIControlContentVerticalAlignmentBottom: {
            frame.origin.y = viewSize.height - frame.size.height - insets.bottom;
            break;
        }
        default: {
            break;
        }
    }
    
    self.mainLayoutView.frame = frame;
}

- (BOOL)shouldIgnoreTouch
{
    if (self.state == TFLoadingStateLoading ||
        self.state == TFLoadingStateHidden) {
        return YES;
    }
    if (self.configuration.ignoreTouchIfStateEmpty) {
        if (self.state == TFLoadingStateEmpty ||
            self.state == TFLoadingStateEmptyList) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation UIView (TFLoadingView)

- (TFLoadingView *)tf_loadingView
{
    const void *key = @selector(tf_loadingView);
    TFLoadingView *view = objc_getAssociatedObject(self, key);
    
    if (![view isKindOfClass:[TFLoadingView class]]) {
        view = [[TFLoadingView alloc] init];
        self.tf_loadingView = view;
    }
    return view;
}

- (void)setTf_loadingView:(TFLoadingView *)tf_loadingView
{
    const void *key = @selector(tf_loadingView);
    TFLoadingView *view = objc_getAssociatedObject(self, key);
    [view removeFromSuperview];
    
    CGRect frame = self.bounds;
    frame.origin = CGPointZero;
    tf_loadingView.frame = frame;
    tf_loadingView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight);
    [self addSubview:tf_loadingView];
    
    objc_setAssociatedObject(self, key, tf_loadingView, OBJC_ASSOCIATION_RETAIN);
}

@end
