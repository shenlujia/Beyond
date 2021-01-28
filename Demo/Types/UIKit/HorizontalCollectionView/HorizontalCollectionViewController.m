//
//  HorizontalCollectionViewController.m
//  Beyond
//
//  Created by ZZZ on 2020/12/31.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "HorizontalCollectionViewController.h"
#import "HorizontalCollectionViewCell.h"
#import "HorizontalCollectionViewLayout.h"

@interface HorizontalCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy) NSArray *data;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation HorizontalCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *data = [NSMutableArray array];
    for (NSInteger idx = 0; idx < 30; ++idx) {
        if (idx % 2 == 0) {
            [data addObject:[NSString stringWithFormat:@"%@", @(idx)]];
        } else {
            [data addObject:[NSString stringWithFormat:@"%@_SSSSSSSSSS", @(idx)]];
        }
    }
    self.data = data;

    HorizontalCollectionViewLayout *layout = [[HorizontalCollectionViewLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.estimatedItemSize = CGSizeMake(80, 80);
    layout.sectionInset = UIEdgeInsetsMake(5, 10, 15, 20);
    layout.numberOfRows = 2;
    layout.spacingX = 5;
    layout.SpacingY = 10;

    CGRect frame = self.view.bounds;
    frame.origin = CGPointMake(10, 10);
    frame.size = CGSizeMake(frame.size.width - 2 * frame.origin.x, 100);
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.layer.borderWidth = 1 / UIScreen.mainScreen.scale;
    self.collectionView.layer.borderColor = UIColor.darkGrayColor.CGColor;

    Class cellClass = [HorizontalCollectionViewCell class];
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([HorizontalCollectionViewCell class]);
    HorizontalCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell updateWithTitle:self.data[indexPath.item] selected:indexPath.item == self.selectedIndex];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *visibleCells = self.collectionView.visibleCells;
    [self.collectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
        if (obj.item == self.selectedIndex) {
            [visibleCells[idx] updateWithTitle:self.data[obj.item] selected:NO];
        }
        if (obj.item == indexPath.item) {
            [visibleCells[idx] updateWithTitle:self.data[obj.item] selected:YES];
        }
    }];
    self.selectedIndex = indexPath.item;

    NSLog(@"%@", indexPath);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willDisplayCell system %@", @(indexPath.item));
}

@end
