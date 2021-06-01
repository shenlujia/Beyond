//
//  BaseViewController.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "BaseViewController.h"

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
@property (nonatomic, strong) NSMutableArray *naviItems;
@property (nonatomic, strong) NSMutableArray *models;

@end

@implementation BaseViewController

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
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
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;

    self.scrollView = [[ScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self reloadData];
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

- (void)reloadData
{
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
