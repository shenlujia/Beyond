//
//  Created by ZZZ on 2021/11/16.
//

#import "SSEasyPanel.h"
#import <objc/runtime.h>

@interface SSDEBUGPanelItem ()

@property (nonatomic, weak) SSDEBUGPanel *panel;

@property (nonatomic, copy) void (^setup)(SSDEBUGPanelItem *item);
@property (nonatomic, copy) void (^action)(SSDEBUGPanelItem *item);

@end

@implementation SSDEBUGPanelItem

- (void)dealloc
{
    [self.button removeFromSuperview];
}

- (instancetype)init
{
    self = [super init];
    
    _button = ({
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        view.backgroundColor = [UIColor.cyanColor colorWithAlphaComponent:0.2];
        
        view.titleLabel.font = [UIFont systemFontOfSize:10];
        view.titleLabel.numberOfLines = 0;
        view.titleLabel.adjustsFontSizeToFitWidth = YES;
        [view addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        
        view;
    });
    
    return self;
}

- (void)tap:(UIButton *)button
{
    if (self.action) {
        self.action(self);
    }
}

@end

@interface SSDEBUGPanel () <UIGestureRecognizerDelegate>

@property (nonatomic, assign, readonly) CGPoint origin;

@property (nonatomic, weak, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL folded;
@property (nonatomic, assign) BOOL shouldLayout;

@property (nonatomic, strong) NSMutableArray<SSDEBUGPanelItem *> *items;
@property (nonatomic, strong) SSDEBUGPanelItem *controlItem;

@property (nonatomic, assign) CGPoint panPoint;

@end

@implementation SSDEBUGPanel

- (void)dealloc
{
    [self.scrollView removeFromSuperview];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.2];
        _scrollView.showsVerticalScrollIndicator = NO;
        _items = [NSMutableArray array];
        _folded = YES;

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [_scrollView addGestureRecognizer:pan];
        pan.delegate = self;
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
    }
    return self;
}

+ (CGSize)itemSize
{
    return CGSizeMake(88, 36);
}

- (void)showInView:(UIView *)view
{
    if (!view) {
        view = UIApplication.sharedApplication.delegate.window.rootViewController.view;
    }
    if (!view) {
        return;
    }
    
    CGPoint center = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2);
    NSString *stringValue = [NSUserDefaults.standardUserDefaults valueForKey:[self keyWithView:view]];
    if (stringValue.length) {
        center = CGPointFromString(stringValue);
    }
    [self showInView:view center:center];
}

- (void)showInView:(UIView *)view center:(CGPoint)center
{
    _containerView = view;
    CGSize itemSize = [[self class] itemSize];
    _origin = CGPointMake(center.x - itemSize.width / 2, center.y - itemSize.height / 2);
    [self setNeedsLayout];
    
    const void *key = @selector(showInView:center:);
    if (view) {
        objc_setAssociatedObject(view, key, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)dismiss
{
    [_items removeAllObjects];
    UIView *view = self.containerView;
    const void *key = @selector(showInView:center:);
    if (view) {
        objc_setAssociatedObject(view, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)test:(void (^)(SSDEBUGPanelItem *item))setup action:(void (^)(SSDEBUGPanelItem *item))action
{
    SSDEBUGPanelItem *item = [[SSDEBUGPanelItem alloc] init];
    item.panel = self;
    item.setup = setup;
    item.action = action;
    [self.items addObject:item];
    [self setNeedsLayout];
}

- (void)setNeedsLayout
{
    self.shouldLayout = YES;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        if (self.shouldLayout) {
            [self layoutIfNeeded];
        }
    }];
}

- (void)layoutIfNeeded
{
    if (!self.shouldLayout || !self.containerView) {
        return;
    }
    self.shouldLayout = NO;

    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    __weak SSDEBUGPanel *weakPanel = self;
    self.controlItem = [[SSDEBUGPanelItem alloc] init];
    self.controlItem.panel = self;
    [self.controlItem.button setTitle:weakPanel.folded ? @"展开" : @"收起" forState:UIControlStateNormal];
    self.controlItem.action = ^(SSDEBUGPanelItem *item) {
        weakPanel.folded = !weakPanel.folded;
        [weakPanel setNeedsLayout];
    };
    
    NSMutableArray *fixedItems = [NSMutableArray array];
    NSMutableArray *otherItems = [NSMutableArray array];
    [self.items enumerateObjectsUsingBlock:^(SSDEBUGPanelItem *item, NSUInteger idx, BOOL *stop) {
        if (item.setup) {
            item.setup(item);
        }
        if (item.fixed) {
            [fixedItems addObject:item];
        } else {
            [otherItems addObject:item];
        }
    }];
    
    const CGSize itemSize = [[self class] itemSize];
    CGRect itemFrame = CGRectMake(0, 0, itemSize.width, itemSize.height);
    for (SSDEBUGPanelItem *item in fixedItems) {
        itemFrame.origin.y = (itemSize.height + 1) * self.scrollView.subviews.count;
        item.button.frame = itemFrame;
        [self.scrollView addSubview:item.button];
    }
    if (otherItems.count) {
        itemFrame.origin.y = (itemSize.height + 1) * self.scrollView.subviews.count;
        self.controlItem.button.frame = itemFrame;
        [self.scrollView addSubview:self.controlItem.button];
    }
    if (!self.folded) {
        for (SSDEBUGPanelItem *item in otherItems) {
            itemFrame.origin.y = (itemSize.height + 1) * self.scrollView.subviews.count;
            item.button.frame = itemFrame;
            [self.scrollView addSubview:item.button];
        }
    }
    
    const CGFloat contentHeight = CGRectGetMaxY(itemFrame);
    const CGSize maxSize = self.containerView.bounds.size;
    CGRect frame = CGRectZero;
    frame.size.width = itemSize.width;
    frame.size.height = MIN(MAX(itemSize.height, contentHeight), maxSize.height * 0.8);
    frame.origin = self.origin;
    frame = [self p_fixFrame:frame];
    
    self.scrollView.frame = frame;
    [self.containerView addSubview:self.scrollView];
    self.scrollView.contentSize = CGSizeMake(itemSize.width, contentHeight);
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.panPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGRect frame = gestureRecognizer.view.frame;
        
        CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
        frame.origin.x += point.x - self.panPoint.x;
        frame.origin.y += point.y - self.panPoint.y;
        frame = [self p_fixFrame:frame];
        
        _origin = frame.origin;
        [self saveLocation];
        gestureRecognizer.view.frame = frame;
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap
{
    CGSize size = self.containerView.frame.size;
    [self showInView:self.containerView center:CGPointMake(size.width / 2, size.height / 2)];
}

- (NSString *)keyWithView:(UIView *)view
{
    NSString *key1 = NSStringFromClass([self class]);
    NSString *key2 = NSStringFromClass([view class]);
    NSString *key3 = NSStringFromClass([view.nextResponder class]);
    NSString *key4 = NSStringFromClass([view.nextResponder.nextResponder class]);
    return [NSString stringWithFormat:@"%@_%@_%@_%@", key1, key2, key3, key4];
}

- (void)saveLocation
{
    NSString *value = NSStringFromCGPoint(self.origin);
    [NSUserDefaults.standardUserDefaults setValue:value forKey:[self keyWithView:self.containerView]];
}

- (CGRect)p_fixFrame:(CGRect)frame
{
    const CGSize maxSize = self.containerView.bounds.size;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.containerView.safeAreaInsets;
    }
    
    if (frame.origin.x + frame.size.width + safeAreaInsets.right > maxSize.width) {
        frame.origin.x = maxSize.width - (frame.size.width + safeAreaInsets.right);
    }
    frame.origin.x = MAX(frame.origin.x, safeAreaInsets.left);
    if (frame.origin.y + frame.size.height + safeAreaInsets.bottom > maxSize.height) {
        frame.origin.y = maxSize.height - (frame.size.height + safeAreaInsets.bottom);
    }
    frame.origin.y = MAX(frame.origin.y, safeAreaInsets.top);
 
    return frame;
}

@end
