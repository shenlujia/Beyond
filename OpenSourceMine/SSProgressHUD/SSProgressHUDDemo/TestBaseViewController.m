//
//  TestBaseViewController.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/16.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "TestBaseViewController.h"
#import "SSProgressHUD.h"

@interface TestBaseViewController ()

@end

@implementation TestBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    _imageControl = ({
        UISegmentedControl *view = nil;
        NSArray *items = [TestParameter imagedescArray];
        view = [[UISegmentedControl alloc] initWithItems:items];
        view.selectedSegmentIndex = 1;
        [self.view addSubview:view];
        view;
    });
    
    _textControl = ({
        UISegmentedControl *view = nil;
        NSArray *items = [TestParameter textDescArray];
        view = [[UISegmentedControl alloc] initWithItems:items];
        view.selectedSegmentIndex = 1;
        [self.view addSubview:view];
        view;
    });
    
    _tableView = ({
        UITableView *view = [[UITableView alloc] initWithFrame:CGRectZero
                                                         style:UITableViewStyleGrouped];
        view.delegate = self;
        view.dataSource = self;
        [self.view addSubview:view];
        view;
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SSProgressHUD dismissAll];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    const CGSize size = self.view.bounds.size;
    const CGFloat margin = 10;
    
    CGRect frame = CGRectMake(margin, margin, size.width - 2 * margin, 32);
    self.imageControl.frame = frame;
    
    frame.origin.y += frame.size.height + margin;
    self.textControl.frame = frame;
    
    frame.origin.y += frame.size.height + margin;
    frame.size.height = size.height - frame.origin.y;
    frame.origin.x = 0;
    frame.size.width = size.width;
    self.tableView.frame = frame;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.array.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *key = @"header";
    static NSInteger viewTag = 666;
    UITableViewHeaderFooterView *view = ({
        UITableViewHeaderFooterView *view = nil;
        view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:key];
        if (!view) {
            view = [[UITableViewHeaderFooterView alloc] init];
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentLeft;
            label.tag = viewTag;
            label.frame = view.bounds;
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [view.contentView addSubview:label];
        }
        view;
    });
    
    UILabel *label = [view viewWithTag:viewTag];
    label.text = [NSString stringWithFormat:@"    section %@", @(section)];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rows = self.array[section];
    return rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *key = @"key";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.textLabel.text = self.array[indexPath.section][indexPath.row];
    return cell;
}

@end
