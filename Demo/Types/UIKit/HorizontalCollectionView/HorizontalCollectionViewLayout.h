//
//  HorizontalCollectionViewLayout.h
//  Beyond
//
//  Created by ZZZ on 2020/12/31.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HorizontalCollectionViewLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, assign) CGFloat spacingX;
@property (nonatomic, assign) CGFloat SpacingY;

@end

NS_ASSUME_NONNULL_END
