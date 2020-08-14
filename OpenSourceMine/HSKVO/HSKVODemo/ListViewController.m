//
//  ListViewController.m
//  HSKVO
//
//  Created by shenlujia on 2016/1/13.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView *tableView = ({
        CGRect rect = self.view.bounds;
        UITableView *view = [[UITableView alloc] initWithFrame:rect
                                                         style:UITableViewStylePlain];
        view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
        view.delegate = self;
        view.dataSource = self;
        view.backgroundColor = UIColor.groupTableViewBackgroundColor;
        view.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        view.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        view;
    });
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *key = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:key];
        cell.textLabel.textColor = UIColor.darkGrayColor;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.numberOfLines = 0;
    }
    
    cell.textLabel.text = self.data[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self didSelectIndex:indexPath.row];
}

- (void)didSelectIndex:(NSInteger)index
{
    
}

@end
