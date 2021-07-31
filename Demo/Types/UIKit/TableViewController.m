//
//  TableViewController.m
//  Beyond
//
//  Created by ZZZ on 2021/7/14.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *texts;

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = ({
        UITableView *view = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        [self.view addSubview:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.delegate = self;
        view.dataSource = self;
        view;
    });

    self.texts = @[@"1", @"2", @"3", @"添加", @"删除", @"数据源和tableView不一致 崩溃"];

    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.texts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *key = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
    }
    cell.textLabel.text = self.texts[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *text = self.texts[indexPath.row];
    if ([text isEqualToString:@"添加"]) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.texts];
        [array insertObject:NSDate.date.description atIndex:1];
        self.texts = array;

        [self.tableView beginUpdates];
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } else if ([text isEqualToString:@"删除"]) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.texts];
        [array removeObjectAtIndex:1];
        self.texts = array;

        [self.tableView beginUpdates];
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    } else if ([text isEqualToString:@"数据源和tableView不一致 崩溃"]) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.texts];
        [array removeObjectAtIndex:1];
        self.texts = array;

        NSLog(@"data_count=%@ cell_count=%@ delegate_count=%@", @(self.texts.count), @([self.tableView numberOfRowsInSection:0]), @([self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:0]));

        [self.tableView beginUpdates];
        NSIndexPath *path1 = [NSIndexPath indexPathForRow:1 inSection:0];
        NSIndexPath *path2 = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[path1, path2] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

@end
