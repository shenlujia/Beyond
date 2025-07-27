//
//  AssetViewer.m
//  Beyond
//
//  Created by ZZZ on 2025/7/2.
//  Copyright © 2025 SLJ. All rights reserved.
//

#import "AssetViewer.h"

@interface AAAInternalAssetCollectionViewCell : UICollectionViewCell

@property (nonatomic, copy, readonly) NSString *object;

@property (nonatomic, strong) UIView *displayView;
@property (nonatomic, strong) UIView *interactionView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation AAAInternalAssetCollectionViewCell

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.displayView = ({
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        view;
    });
    
    self.interactionView = ({
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        view;
    });
    
    self.imageView = ({
        UIImageView *view = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.displayView addSubview:view];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.contentMode = UIViewContentModeScaleAspectFit;
        
        view;
    });
    
    return self;
}

- (void)updateWithObject:(NSString *)object
{
    _object = object;
    self.imageView.image = [UIImage imageWithContentsOfFile:object];
}

- (void)willDisplayCell
{
    
}

- (void)didEndDisplayingCell
{
    
}

@end

@interface AAAInternalAssetViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation AAAInternalAssetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    
    self.collectionView = ({
        NSInteger insetX = 5;
        CGSize size = self.view.bounds.size;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 2 * insetX;
        layout.sectionInset = UIEdgeInsetsMake(0, insetX, 0, insetX);
        layout.itemSize = CGSizeMake(size.width - 2 * insetX, size.height);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        collectionView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [self.view addSubview:collectionView];
        
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.pagingEnabled = YES;
        [collectionView registerClass:[AAAInternalAssetCollectionViewCell class] forCellWithReuseIdentifier:[AAAInternalAssetCollectionViewCell reuseIdentifier]];
        
        collectionView;
    });
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AAAInternalAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[AAAInternalAssetCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    [cell updateWithObject:[self.objects objectAtIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(AAAInternalAssetCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell willDisplayCell];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(AAAInternalAssetCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [cell didEndDisplayingCell];
}

@end

@implementation AssetViewer

+ (void)showObjects:(NSArray *)objects inContainer:(UIViewController *)container
{
    AAAInternalAssetViewController *controller = [[AAAInternalAssetViewController alloc] init];
    controller.objects = objects;

    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.viewControllers = @[controller];
    navigationController.navigationBar.translucent = NO;
    navigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        navigationController.navigationBar.standardAppearance = appearance;
        navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    
    if (!container) {
        container = UIApplication.sharedApplication.delegate.window.rootViewController;
    }
    [container presentViewController:navigationController animated:YES completion:nil];
}

@end
