//
//  SSLiveObjectsViewController.m
//  Beyond
//
//  Created by ZZZ on 2021/3/4.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SSLiveObjectsViewController.h"
#import "SimpleLeakDetector.h"
#import "SSLeakDetectorObject.h"

#define kHasContentSearchBarContent @"包含内容"
#define kFilterPrefixSearchBarContent @"前缀过滤 用空格区分多个"

@interface SSLiveObjectsCell : UITableViewCell

@end

@implementation SSLiveObjectsCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    return self;
}

- (void)updateWithItem:(SSLeakDetectorObjectItem *)item
{
    self.textLabel.text = [NSString stringWithFormat:@"%ld    %@", item.pointers.count, item.name];
}

@end

@interface SSLiveObjectsViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UISearchBar *hasContentSearchBar;
@property (nonatomic, strong) UISearchBar *filterPrefixSearchBar;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) SSLeakDetectorObject *object;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) UISearchBar *currentSearchBar;

@end

@implementation SSLiveObjectsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.indicatorView stopAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];

    self.navigationItem.leftBarButtonItem = ({
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(backAction)];
    });

    static const CGFloat kSearchBarHeight = 44;
    const CGSize size = self.view.bounds.size;
    self.hasContentSearchBar = ({
        CGRect frame = CGRectMake(0, 0, size.width, kSearchBarHeight);
        UISearchBar *view = [[UISearchBar alloc] initWithFrame:frame];
        [self.view addSubview:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        view.placeholder = kHasContentSearchBarContent;
        [self initSearchBar:view];

        view;
    });

    self.filterPrefixSearchBar = ({
        CGRect frame = CGRectMake(0, kSearchBarHeight, size.width, kSearchBarHeight);
        UISearchBar *view = [[UISearchBar alloc] initWithFrame:frame];
        [self.view addSubview:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        view.placeholder = kFilterPrefixSearchBarContent;
        [self initSearchBar:view];

        view;
    });

    self.tableView = ({
        CGRect frame = CGRectMake(0, 2 * kSearchBarHeight, size.width, 0);
        frame.size.height = size.height - frame.origin.y;
        UITableView *view = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [self.view addSubview:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.dataSource = self;
        view.delegate = self;

        view;
    });

    self.object = [[SSLeakDetectorObject alloc] initWithDictionary:[SimpleLeakDetector allDetectedLiveObjects]];

    [self reloadData];
}

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (void)show
{
    SSLiveObjectsViewController *contentController = [[SSLiveObjectsViewController alloc] init];

    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.viewControllers = @[contentController];
    navigationController.navigationBar.translucent = NO;

    UIViewController *currentController = UIApplication.sharedApplication.delegate.window.rootViewController;
    [currentController presentViewController:navigationController animated:YES completion:nil];
}

- (void)reloadData
{
    NSString *content = self.hasContentSearchBar.text;
    NSArray *prefixArray = [self componentsWithString:self.filterPrefixSearchBar.text.uppercaseString];

    NSMutableArray *items = [NSMutableArray array];
    for (SSLeakDetectorObjectItem *item in self.object.items) {
        if ([item hasContent:content]) {
            BOOL hasPrefix = NO;
            for (NSString *prefix in prefixArray) {
                if ([item hasPrefix:prefix]) {
                    hasPrefix = YES;
                    break;
                }
            }
            if (!hasPrefix) {
                [items addObject:item];
            }
        }
    }

    [items sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    self.items = items;

    self.title = @(items.count).stringValue;
    [self.tableView reloadData];
}

- (void)initSearchBar:(UISearchBar *)view
{
    view.autocapitalizationType = UITextAutocapitalizationTypeNone;
    view.autocorrectionType = UITextAutocorrectionTypeNo;
    view.spellCheckingType = UITextAutocorrectionTypeNo;
    view.enablesReturnKeyAutomatically = YES;
    view.delegate = self;

    if (@available(iOS 11.0, *)) {
        view.smartDashesType = UITextSmartQuotesTypeNo;
        view.smartDashesType = UITextSmartDashesTypeNo;
        view.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
    }

    NSString *key = [NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), view.placeholder];
    view.text = [NSUserDefaults.standardUserDefaults objectForKey:key];
}

- (void)endEditing
{
    [self.currentSearchBar resignFirstResponder];
    self.currentSearchBar = nil;
}

- (NSArray *)componentsWithString:(NSString *)text
{
    NSArray *components = [text componentsSeparatedByString:@" "];
    NSMutableArray *ret = [NSMutableArray array];
    for (NSString *component in components) {
        if (component.length) {
            [ret addObject:component];
        }
    }
    return ret;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.currentSearchBar = searchBar;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSString *text = [searchBar.text.uppercaseString stringByReplacingOccurrencesOfString:@"." withString:@" "];
    searchBar.text = [[self componentsWithString:text] componentsJoinedByString:@"  "];

    NSString *key = [NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), searchBar.placeholder];
    [NSUserDefaults.standardUserDefaults setObject:searchBar.text forKey:key];

    [self reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self endEditing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *key = @"SSLiveObjectsCell";
    SSLiveObjectsCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[SSLiveObjectsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
    }

    [cell updateWithItem:[self itemAtIndexPath:indexPath]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.indicatorView startAnimating];

    SSLeakDetectorObjectItem *item = [self itemAtIndexPath:indexPath];

    NSSet *set = [SimpleLeakDetector findRetainCyclesWithClasses:@[item.name] maxCycleLength:10];
    NSLog(@"%@", set);

    [self.indicatorView stopAnimating];
}

- (SSLeakDetectorObjectItem *)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.items[indexPath.row];
}

@end
