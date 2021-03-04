//
//  SSLiveObjectsViewController.m
//  Beyond
//
//  Created by ZZZ on 2021/3/4.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SSLiveObjectsViewController.h"
#import "SimpleLeakDetector.h"

@interface SSLiveObjectsCell : UITableViewCell

@end

@implementation SSLiveObjectsCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    return self;
}

- (void)updateWithObject:(NSString *)text
{
    self.textLabel.text = text;
}

@end

@interface SSLiveObjectsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SSLeakDetectorRecord *object;

@end

@implementation SSLiveObjectsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.titleView = self.indicatorView;
    [self.indicatorView stopAnimating];

    self.navigationItem.leftBarButtonItem = ({
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(backAction)];
    });

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (void)showWithObject:(SSLeakDetectorRecord *)object
{
    SSLiveObjectsViewController *contentController = [[SSLiveObjectsViewController alloc] init];
    contentController.object = object;

    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.viewControllers = @[contentController];
    navigationController.navigationBar.translucent = NO;

    UIViewController *currentController = UIApplication.sharedApplication.delegate.window.rootViewController;
    [currentController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.object.business.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *key = @"SSLiveObjectsCell";
    SSLiveObjectsCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[SSLiveObjectsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
    }

    [cell updateWithObject:[self contentAtIndexPath:indexPath]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.indicatorView startAnimating];

    NSString *text = [self contentAtIndexPath:indexPath];
    text = [text componentsSeparatedByString:@"|"].lastObject;
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSSet *set = [SimpleLeakDetector findRetainCyclesWithClasses:@[text] maxCycleLength:10];
    NSLog(@"%@", set);

    [self.indicatorView stopAnimating];
}

- (NSString *)contentAtIndexPath:(NSIndexPath *)indexPath
{
    return self.object.business[indexPath.row];
}

@end
