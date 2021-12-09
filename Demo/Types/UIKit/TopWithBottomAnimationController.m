//
//  TopWithBottomAnimationController.m
//  Beyond
//
//  Created by ZZZ on 2021/11/26.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "TopWithBottomAnimationController.h"
#import <Masonry/Masonry.h>
#import "SSEasy.h"

#define kBottomHeight 100

@interface TopWithBottomAnimationController () <
UICollectionViewDelegate,
UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *bottomView;
@property (nonatomic, assign) BOOL showBottom;

@property (nonatomic, assign) NSInteger count;

@end

@implementation TopWithBottomAnimationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.count = 3;
    
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"变更"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(changeAction)],
        [[UIBarButtonItem alloc] initWithTitle:@"insert"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(insertAction)]
    ];
    
    _collectionView = ({
        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 10);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        UICollectionView *view = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        [self.view addSubview:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = UIColor.blackColor;
        view.delegate = self;
        view.dataSource = self;
        [view registerClass:[UICollectionViewCell class]
 forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        view.alwaysBounceVertical = YES;
        if (@available(iOS 11.0, *)) {
            view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

        view;
    });
    
    _bottomView = ({
        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, kBottomHeight);
        frame.origin.y = self.view.bounds.size.height - frame.origin.y;
        UILabel *view = [[UILabel alloc] initWithFrame:frame];
        [self.view addSubview:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        view.text = @"ABCDEFGHIJKLMN";
        view.textAlignment = NSTextAlignmentCenter;
        view.textColor = UIColor.blackColor;
        view.backgroundColor = UIColor.redColor;
        
        view;
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = UIColor.blueColor;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    ss_easy_log(@"willDisplayCell %@", @(indexPath.row));
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = self.view.bounds.size;
    CGFloat width = (size.width - 2) / 3;
    return CGSizeMake(width, width * 4 / 3);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

#pragma mark - action

- (void)changeAction
{
    self.showBottom = !self.showBottom;
    
    [UIView animateWithDuration:1 animations:^{
        {
            CGRect frame = self.bottomView.frame;
            frame.origin.y = self.view.bounds.size.height;
            frame.origin.y -= self.showBottom ? kBottomHeight : 0;
            self.bottomView.frame = frame;
        }
        {
            CGRect frame = self.collectionView.frame;
            frame.size.height = self.view.bounds.size.height - 10;
            frame.size.height -= self.showBottom ? kBottomHeight : 0;
            self.collectionView.frame = frame;
        }
        [self.view layoutIfNeeded];
    }];
}

- (void)insertAction
{
    NSInteger insertCount = 20;
    NSIndexPath *reloadPath = [NSIndexPath indexPathForRow:self.count - 1 inSection:0];
    NSMutableArray *insertPaths = [NSMutableArray array];
    for (NSInteger idx = 0; idx < insertCount; ++idx) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:idx + self.count inSection:0];
        [insertPaths addObject:path];
    }
    self.count += insertCount;
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadItemsAtIndexPaths:@[reloadPath]];
        [self.collectionView insertItemsAtIndexPaths:insertPaths];
    } completion:^(BOOL finished) {
    }];
}

@end
