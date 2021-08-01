
#import "SSDEBUGViewPanel.h"

#pragma mark - SSDEBUGTextViewController

@interface SSDEBUGTextViewController () <UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation SSDEBUGTextViewController

@synthesize textView = _textView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    const CGSize size = self.view.bounds.size;
    const CGFloat searchHeight = self.searchBar.bounds.size.height;

    [self.view addSubview:self.searchBar];
    self.searchBar.frame = CGRectMake(0, 0, size.width, searchHeight);
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:self.textView];
    self.textView.frame = CGRectMake(0, searchHeight, size.width, size.height - searchHeight);
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        [_searchBar sizeToFit];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
    }
    return _textView;
}

- (void)backAction
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

+ (void)showText:(NSString *)text
{
    SSDEBUGTextViewController *textController = [[SSDEBUGTextViewController alloc] init];
    textController.textView.text = text;

    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.viewControllers = @[textController];
    navigationController.navigationBar.translucent = NO;
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    UIViewController *controller = UIApplication.sharedApplication.delegate.window.rootViewController;

    [controller presentViewController:navigationController animated:YES completion:nil];
}

+ (void)showJSONObject:(id)JSONObject
{
    [SSDEBUGTextViewController showText:[self textWithJSONObject:JSONObject]];
}

+ (NSString *)textWithJSONObject:(id)JSONObject
{
    if (![NSJSONSerialization isValidJSONObject:JSONObject]) {
        return @"JSON对象无效";
    }

    NSJSONWritingOptions opt = NSJSONWritingPrettyPrinted;
    if (@available(iOS 11.0, *)) {
        opt |= NSJSONWritingSortedKeys;
    }
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:JSONObject options:opt error:&error];
    if (error) {
        return error.description;
    }
    if (data) {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return @"未知错误";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    const NSInteger length = self.textView.text.length;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = UIColor.blackColor;

    NSInteger matchCount = 0;
    if (length) {
        [self.textView.textStorage addAttributes:[attributes copy] range:NSMakeRange(0, length)];
        if (searchText.length) {
            attributes[NSForegroundColorAttributeName] = UIColor.redColor;
            NSInteger i = 0;
            while (YES) {
                NSRange range = NSMakeRange(i, length - i);
                NSRange r = [self.textView.text rangeOfString:searchText options:NSCaseInsensitiveSearch range:range];
                if (r.location == NSNotFound) {
                    break;
                }
                [self.textView.textStorage addAttributes:attributes range:r];
                i = r.location + r.length;
                ++matchCount;
            }
        }
    }
    self.title = [NSString stringWithFormat:@"已匹配: %@", @(matchCount)];
}

@end

#pragma mark - SSDEBUGViewPanel

@interface SSDEBUGViewPanel ()

@property (nonatomic, assign, readonly) CGPoint point;
@property (nonatomic, weak, readonly) UIView *view;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, copy) NSArray<UIButton *> *buttons;

@property (nonatomic, assign) BOOL folded;
@property (nonatomic, assign) BOOL shouldLayout;

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *actions;

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
