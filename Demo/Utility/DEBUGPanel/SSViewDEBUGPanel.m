
#import "SSViewDEBUGPanel.h"

#pragma mark - SSViewDEBUGTextViewController

@interface SSViewDEBUGTextViewController ()

@end

@implementation SSViewDEBUGTextViewController

@synthesize textView = _textView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.textView.frame = self.view.bounds;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (UITextView *)textView
{
    if (!_textView) {
        UITextView *view = [[UITextView alloc] init];
        _textView = view;
    }
    return _textView;
}

+ (void)show:(NSString *)text
{
    UIViewController *controller = UIApplication.sharedApplication.delegate.window.rootViewController;
    SSViewDEBUGTextViewController *textController = [[SSViewDEBUGTextViewController alloc] init];
    textController.textView.text = text;
    [controller presentViewController:textController animated:YES completion:nil];
}

@end

#pragma mark - SSViewDEBUGPanel

@interface SSViewDEBUGPanel ()

@property (nonatomic, assign, readonly) CGPoint point;
@property (nonatomic, weak, readonly) UIView *view;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, copy) NSArray<UIButton *> *buttons;

@property (nonatomic, assign) BOOL folded;
@property (nonatomic, assign) BOOL shouldLayout;

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *actions;

@end

@implementation SSViewDEBUGPanel

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
    }
    return self;
}

+ (CGSize)itemSize
{
    return CGSizeMake(64, 32);
}

- (void)showInView:(UIView *)view startPoint:(CGPoint)startPoint
{
    _view = view;
    _point = startPoint;
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
        frame.origin.y = (frame.size.height + 5) * idx;
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

@end
