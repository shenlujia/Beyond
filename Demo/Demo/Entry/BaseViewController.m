//
//  BaseViewController.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "BaseViewController.h"
#import "SSEasy.h"

UIEdgeInsets app_safeAreaInsets()
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        insets = UIApplication.sharedApplication.delegate.window.safeAreaInsets;
    }
    return insets;
}

@interface NaviItemModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) ActionBlock tap;
@property (nonatomic, strong) NSMutableDictionary *userInfo;

@end

@implementation NaviItemModel

- (instancetype)init
{
    self = [super init];
    _userInfo = [NSMutableDictionary dictionary];
    return self;
}

- (void)tapAction
{
    NSInteger count = [self.userInfo[kButtonTapCountKey] integerValue] + 1;
    self.userInfo[kButtonTapCountKey] = @(count);
    if (self.tap) {
        self.tap(nil, self.userInfo);
    }
}

@end

@interface EntryDataModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) ActionBlock set;
@property (nonatomic, copy) ActionBlock tap;
@property (nonatomic, assign) SEL action;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) NSMutableDictionary *userInfo;

@end

@implementation EntryDataModel

- (instancetype)init
{
    self = [super init];
    _userInfo = [NSMutableDictionary dictionary];
    return self;
}

@end

@interface ScrollView : UIScrollView

@end

@implementation ScrollView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

@end

@interface BaseViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL shouldLayout;
@property (nonatomic, strong) NSMutableArray *naviItems;
@property (nonatomic, strong) NSMutableArray *models;

@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSMutableDictionary *observeMapping;

@end

@implementation BaseViewController

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.naviItems = [NSMutableArray array];
    self.models = [NSMutableArray array];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.createDate = [NSDate date];
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;

    self.scrollView = [[ScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap3Action)];
    tap.numberOfTapsRequired = 3;
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.title.length == 0) {
        NSString *text = NSStringFromClass([self class]);
        text = [text stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
        self.title = [text stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.createDate) {
        CGFloat duration = [[NSDate date] timeIntervalSinceDate:self.createDate];
        ss_easy_log(@"%@ first frame cost: %.2f", NSStringFromClass([self class]), duration * 1000);
        self.createDate = nil;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self p_setNeedsLayout];
}

- (void)add_navi_right_item:(NSString *)title tap:(ActionBlock)tap
{
    if (title.length == 0 || !tap) {
        return;
    }
    NaviItemModel *current = [[NaviItemModel alloc] init];
    current.title = title;
    current.tap = tap;
    [self.naviItems addObject:current];
    
    NSMutableArray *rightBarButtonItems = [NSMutableArray array];
    for (NaviItemModel *object in self.naviItems) {
        UIBarButtonItem *item = nil;
        item = [[UIBarButtonItem alloc] initWithTitle:object.title
                                                style:UIBarButtonItemStylePlain
                                               target:object
                                               action:@selector(tapAction)];
        [rightBarButtonItems addObject:item];
    }
    self.navigationItem.rightBarButtonItems = rightBarButtonItems;
}

- (void)observe:(NSString *)name block:(void (^)(NSNotification *notification))block
{
    if (!name || !block) {
        return;
    }
    if (!self.observeMapping) {
        self.observeMapping = [NSMutableDictionary dictionary];
    }
    self.observeMapping[name] = block;
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(notificationDidObserve:) name:name object:nil];
}

- (void)notificationDidObserve:(NSNotification *)notification
{
    if (notification.name) {
        void (^block)(NSNotification *notification) = self.observeMapping[notification.name];
        if (block) {
            block(notification);
        }
    }
}

- (void)set_insets:(UIEdgeInsets)insets
{
    self.scrollView.contentInset = insets;
}

- (void)test_c:(NSString *)c
{
    [self test_c:c title:nil];
}

- (void)test_c:(NSString *)c title:(NSString *)title
{
    Class clazz = NSClassFromString(c);
    if (!clazz) {
        NSString *temp = [NSString stringWithFormat:@"%@Controller", c];
        clazz = NSClassFromString(temp);
        if (!clazz) {
            NSString *temp = [NSString stringWithFormat:@"SS%@Controller", c];
            clazz = NSClassFromString(temp);
        }
    }
    if (!clazz) {
        return;
    }
    if (title.length == 0) {
        title = [c stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
    }
    WEAKSELF
    ActionBlock block = ^(UIButton *button, NSDictionary *userInfo) {
        UIViewController *to = [[clazz alloc] init];
        [weak_s.navigationController pushViewController:to animated:YES];
    };
    [self p_test:title set:nil tap:block action:NULL];
}

- (void)test:(NSString *)title tap:(ActionBlock)tap
{
    [self p_test:title set:nil tap:tap action:NULL];
}

- (void)test:(NSString *)title set:(ActionBlock)set tap:(ActionBlock)tap
{
    [self p_test:title set:set tap:tap action:NULL];
}

- (void)test:(NSString *)title set:(ActionBlock)set action:(SEL)action
{
    [self p_test:title set:set tap:nil action:action];
}

- (void)p_test:(NSString *)title set:(ActionBlock)set tap:(ActionBlock)tap action:(SEL)action
{
    EntryDataModel *model = [[EntryDataModel alloc] init];
    model.title = title;
    model.set = set;
    model.tap = tap;
    model.action = action;
    [self.models addObject:model];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = UIColor.whiteColor;
    [button setTitle:model.title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.titleLabel.numberOfLines = 0;
    model.button = button;

    if (model.action) {
        [button addTarget:self action:model.action forControlEvents:UIControlEventTouchUpInside];
    }
    if (model.tap) {
        [button addTarget:self action:@selector(p_base_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    if (model.set) {
        model.set(button, nil);
    }
}

- (void)p_setNeedsLayout
{
    self.shouldLayout = YES;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        if (self.shouldLayout) {
            [self reloadData];
        }
    }];
}

- (void)tap3Action
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)reloadData
{
    if (!self.shouldLayout) {
        return;
    }
    self.shouldLayout = NO;

    for (EntryDataModel *model in self.models) {
        [model.button removeFromSuperview];
    }
    const CGFloat spaceY = 10;
    for (NSInteger idx = 0; idx < self.models.count; ++idx) {
        EntryDataModel *model = self.models[idx];
        [self.scrollView addSubview:model.button];
        model.button.tag = idx;
        CGRect frame = CGRectMake(10, spaceY, self.view.bounds.size.width, 50);
        frame.size.width -= 2 * frame.origin.x;
        frame.origin.y += idx * (frame.size.height + spaceY);
        model.button.frame = frame;
    }

    CGRect frame = [[self.models.lastObject button] frame];
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(frame) + spaceY);
}

- (void)p_base_buttonAction:(UIButton *)button
{
    EntryDataModel *model = self.models[button.tag];
    NSInteger count = [model.userInfo[kButtonTapCountKey] integerValue] + 1;
    model.userInfo[kButtonTapCountKey] = @(count);
    if (model.tap) {
        model.tap(button, model.userInfo);
    }
}

@end
