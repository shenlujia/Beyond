
#import "SSDEBUGViewPanel.h"

@interface SSDEBUGViewPanel () <UIGestureRecognizerDelegate>

@property (nonatomic, assign, readonly) CGPoint point;
@property (nonatomic, weak, readonly) UIView *view;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, copy) NSArray<UIButton *> *buttons;

@property (nonatomic, assign) BOOL folded;
@property (nonatomic, assign) BOOL shouldLayout;

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, assign) CGPoint panPoint;

@end

@implementation SSDEBUGViewPanel

- (void)dealloc
{
    [self.scrollView removeFromSuperview];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.15];
        _scrollView.showsVerticalScrollIndicator = NO;
        _buttons = [NSMutableArray array];
        _titles = [NSMutableArray array];
        _actions = [NSMutableArray array];

        __weak typeof (self) weak_self = self;
        [self test:@"" action:^{
            weak_self.folded = !weak_self.folded;
            [weak_self setNeedsLayout];
        }];
        [weak_self setNeedsLayout];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [_scrollView addGestureRecognizer:pan];
        pan.delegate = self;
    }
    return self;
}

+ (CGSize)itemSize
{
    return CGSizeMake(64, 32);
}

- (void)showInView:(UIView *)view
{
    if (!view) {
        view = UIApplication.sharedApplication.delegate.window.rootViewController.view;
    }
    if (!view) {
        return;
    }
    
    CGPoint point = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2);
    NSString *value = [NSUserDefaults.standardUserDefaults valueForKey:[self keyWithView:view]];
    NSArray *components = [value componentsSeparatedByString:@","];
    if (components.count == 2) {
        point = CGPointMake([components[0] floatValue], [components[1] floatValue]);
    }
    [self showInView:view startPoint:point];
}

- (void)showInView:(UIView *)view startPoint:(CGPoint)startPoint
{
    _view = view;
    _point = startPoint;
    [self saveLocation];
    [self setNeedsLayout];
}

- (void)test:(NSString *)title action:(dispatch_block_t)action
{
    if (title && action) {
        [_titles addObject:title];
        [_actions addObject:action];
    }
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
    if (!self.shouldLayout || !self.view) {
        return;
    }
    self.shouldLayout = NO;

    for (UIView *view in self.buttons) {
        [view removeFromSuperview];
    }

    const CGSize buttonSize = [[self class] itemSize];

    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    for (NSInteger idx = 0; idx < self.titles.count && idx < self.actions.count; ++idx) {
        CGRect frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
        frame.origin.y = (frame.size.height + 2) * idx;
        UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
        view.tag = idx;
        view.frame = frame;
        view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.15];
        NSString *title = self.titles[idx];
        if (idx == 0) {
            title = self.folded ? @"展开" : @"收起";
        }
        [view setTitle:title forState:UIControlStateNormal];
        view.titleLabel.font = [UIFont systemFontOfSize:10];
        view.titleLabel.adjustsFontSizeToFitWidth = YES;
        [view addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:view];
        [buttons addObject:view];
    }
    self.buttons = buttons;

    const CGFloat contentHeight = CGRectGetMaxY(buttons.lastObject.frame);
    const CGSize mainSize = self.view.bounds.size;
    CGRect frame = CGRectMake(0, 0, buttonSize.width, self.folded ? buttonSize.height : contentHeight);
    frame.origin = self.point;
    if (CGRectGetMaxX(frame) + 10 > mainSize.width) {
        frame.size.width = MAX(mainSize.width - frame.origin.x - 10, buttonSize.width);
        if (CGRectGetMaxX(frame) > mainSize.width) {
            frame.origin.x = mainSize.width - frame.size.width;
        }
    }
    if (CGRectGetMaxY(frame) + 10 > mainSize.height) {
        frame.size.height = MAX(mainSize.height - frame.origin.y - 10, buttonSize.height);
        if (CGRectGetMaxY(frame) > mainSize.height) {
            frame.origin.y = mainSize.height - frame.size.height;
        }
    }

    self.scrollView.frame = frame;
    if (self.view != self.scrollView.superview) {
        [self.view addSubview:self.scrollView];
    }
    self.scrollView.contentSize = CGSizeMake(buttonSize.width, contentHeight);
}

- (void)tap:(UIButton *)button
{
    dispatch_block_t action = self.actions[button.tag];
    action();
}

- (void)pan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.panPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        const CGSize superSize = gestureRecognizer.view.superview.frame.size;
        CGRect frame = gestureRecognizer.view.frame;
        
        CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
        frame.origin.x += point.x - self.panPoint.x;
        frame.origin.y += point.y - self.panPoint.y;
        frame.origin.x = MIN(frame.origin.x, superSize.width - frame.size.width);
        frame.origin.x = MAX(frame.origin.x, 0);
        frame.origin.y = MIN(frame.origin.y, superSize.height - frame.size.height);
        frame.origin.y = MAX(frame.origin.y, 0);
        
        _point = frame.origin;
        [self saveLocation];
        gestureRecognizer.view.frame = frame;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    const CGSize itemSize = [SSDEBUGViewPanel itemSize];
    const CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    return CGRectContainsPoint(CGRectMake(0, 0, itemSize.width, itemSize.height), point);
}

- (NSString *)keyWithView:(UIView *)view
{
    NSString *key1 = NSStringFromClass([self class]);
    NSString *key2 = nil;
    if (view) {
        key2 = NSStringFromClass([view class]);
    }
    NSString *key3 = nil;
    if (view.nextResponder) {
        key3 = NSStringFromClass([view.nextResponder class]);
    }
    return [NSString stringWithFormat:@"%@_%@_%@", key1, key2, key3];
}

- (void)saveLocation
{
    NSString *value = [NSString stringWithFormat:@"%f,%f", self.point.x, self.point.y];
    [NSUserDefaults.standardUserDefaults setValue:value forKey:[self keyWithView:self.view]];
    
}

@end
