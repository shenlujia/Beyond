
#if INHOUSE_TARGET

#import "SSDEBUGTextViewController.h"

@interface SSDEBUGTextViewController () <UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, copy) NSArray *ranges;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) UIBarButtonItem *item0;
@property (nonatomic, strong) UIBarButtonItem *item1;

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
    
    self.navigationItem.rightBarButtonItems = ({
        _item0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(previousAction)];
        _item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(nextAction)];
        @[_item1, _item0];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateBarItems];
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
        _textView.editable = NO;
        _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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

- (void)previousAction
{
    --self.index;
    [self updateBarItems];
}

- (void)nextAction
{
    ++self.index;
    [self updateBarItems];
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
    attributes[NSForegroundColorAttributeName] = UIColor.lightGrayColor;

    NSInteger matchCount = 0;
    NSMutableArray *ranges = [NSMutableArray array];
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
                [ranges addObject:[NSValue valueWithRange:r]];
            }
        }
    }
    
    if (ranges.count == 0) {
        attributes[NSForegroundColorAttributeName] = UIColor.blackColor;
        [self.textView.textStorage addAttributes:[attributes copy] range:NSMakeRange(0, length)];
    }
    
    self.ranges = ranges;
    self.index = 0;
    [self updateBarItems];
}

- (void)updateBarItems
{
    self.title = [NSString stringWithFormat:@"已匹配: %@", @(self.ranges.count)];
    
    if (self.ranges.count == 0) {
        self.item0.enabled = NO;
        self.item1.enabled = NO;
        return;
    }
    
    self.index = MAX(self.index, 0);
    self.index = MIN(self.index, self.ranges.count - 1);
    self.item0.enabled = (self.index > 0);
    self.item1.enabled = (self.index < self.ranges.count - 1);
    
    NSRange range = [self.ranges[self.index] rangeValue];
    [self.textView scrollRangeToVisible:range];
}

@end

#endif
