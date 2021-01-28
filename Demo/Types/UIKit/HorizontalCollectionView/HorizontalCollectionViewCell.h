//
//  HorizontalCollectionViewCell.h
//  Beyond
//
//  Created by ZZZ on 2020/12/31.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HorizontalCollectionViewCell : UICollectionViewCell

- (void)updateWithTitle:(NSString *)title selected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
