//
//  ViewController.m
//  MainThreadMonitor
//
//  Created by shenlujia on 2018/3/5.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import "ViewController.h"
#import "MainThreadMonitor.h"
#import "MainThreadRunLoopObserver.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MainThreadRunLoopObserver *runLoopObserver;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    
    UIBarButtonItem *startItem = ({
        [[UIBarButtonItem alloc] initWithTitle:@"start"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(startAction)];
    });
    UIBarButtonItem *stopItem = ({
        [[UIBarButtonItem alloc] initWithTitle:@"stop"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(stopAction)];
    });
    self.navigationItem.rightBarButtonItems = @[stopItem, startItem];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                          style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)startAction
{
//    self.runLoopObserver = [[MainThreadRunLoopObserver alloc] init];
    
    MainThreadMonitor.sharedMonitor.enabled = YES;
}

- (void)stopAction
{
    self.runLoopObserver = nil;
    
    MainThreadMonitor.sharedMonitor.enabled = NO;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    usleep(0.8 * 1000 * 1000);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
