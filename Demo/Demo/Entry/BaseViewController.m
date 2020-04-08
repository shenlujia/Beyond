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
@property (nonatomic, copy) ActionBlock setup;
@property (nonatomic, copy) ActionBlock callback;

@end

@implementation EntryDataModel

@end

@interface BaseViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, copy) NSArray *buttons;

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

- (void)test:(NSString *)title setup:(ActionBlock)setup callback:(ActionBlock)callback
{
    EntryDataModel *model = [[EntryDataModel alloc] init];
    model.title = title;
    model.setup = setup;
    model.callback = callback;
    [self.models addObject:model];
}

- (void)reloadData
{
    for (UIView *view in self.buttons) {
        [view removeFromSuperview];
    }
    NSMutableArray *buttons = [NSMutableArray array];
    for (NSInteger idx = 0; idx < self.models.count; ++idx) {
        EntryDataModel *model = self.models[idx];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.scrollView addSubview:button];
        [buttons addObject:button];
        button.backgroundColor = UIColor.whiteColor;
        [button setTitle:model.title forState:UIControlStateNormal];
        [button setTitleColor:UIColor.darkGrayColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.tag = idx;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame = CGRectMake(10, 10, self.view.bounds.size.width, 50);
        frame.size.width -= 2 * frame.origin.x;
        frame.origin.y += idx * (frame.size.height + 10);
        button.frame = frame;
        if (model.setup) {
            model.setup(button);
        }
    }
    self.buttons = buttons;
    CGRect frame = [self.buttons.lastObject frame];
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, CGRectGetMaxY(frame));
}

- (void)buttonAction:(UIButton *)button
{
    EntryDataModel *model = self.models[button.tag];
    if (model.callback) {
        model.callback(button);
    }
}

@end
