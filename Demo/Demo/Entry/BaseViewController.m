//
//  BaseViewController.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "BaseViewController.h"

@interface EntryDataModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) ActionBlock set;
@property (nonatomic, copy) ActionBlock tap;
@property (nonatomic, assign) SEL action;
@property (nonatomic, strong) UIButton *button;

@end

@implementation EntryDataModel

@end

@interface BaseViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *models;

@end

@implementation BaseViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.models = [NSMutableArray array];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self reloadData];
}

- (void)test_c:(NSString *)c
{
    [self test_c:c title:nil];
}

- (void)test_c:(NSString *)c title:(NSString *)title
{
    Class clazz = NSClassFromString(c);
    if (!clazz) {
        return;
    }
    if (title.length == 0) {
        title = [c stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
    }
    WEAKSELF;
    ActionBlock block = ^(UIButton *button) {
        UIViewController *to = [[clazz alloc] init];
        [weak_self.navigationController pushViewController:to animated:YES];
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
    model.button = button;

    if (model.action) {
        [button addTarget:self action:model.action forControlEvents:UIControlEventTouchUpInside];
    }
    if (model.tap) {
        [button addTarget:self action:@selector(p_base_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    if (model.set) {
        model.set(button);
    }
}

- (void)reloadData
{
    for (EntryDataModel *model in self.models) {
        [model.button removeFromSuperview];
    }
    for (NSInteger idx = 0; idx < self.models.count; ++idx) {
        EntryDataModel *model = self.models[idx];
        [self.scrollView addSubview:model.button];
        model.button.tag = idx;
        CGRect frame = CGRectMake(10, 10, self.view.bounds.size.width, 50);
        frame.size.width -= 2 * frame.origin.x;
        frame.origin.y += idx * (frame.size.height + 10);
        model.button.frame = frame;
    }

    CGRect frame = [[self.models.lastObject button] frame];
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(frame));
}

- (void)p_base_buttonAction:(UIButton *)button
{
    EntryDataModel *model = self.models[button.tag];
    if (model.tap) {
        model.tap(button);
    }
}

@end
