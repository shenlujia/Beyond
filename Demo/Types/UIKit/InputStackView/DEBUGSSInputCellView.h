//
//  DEBUGSSInputCellView.h
//  ZZZ
//
//  Created by ZZZ on 2025/6/13.
//  Copyright © 2025 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DEBUGSSInputCategoryView;

@protocol DEBUGSSInputCategoryViewDelegate <NSObject>

- (void)inputCategoryViewShouldLayout:(DEBUGSSInputCategoryView *)categoryView;

@end

@interface DEBUGSSInputCellView : UIView

- (CGFloat)viewHeight;

@end

@interface DEBUGSSInputTitleView : UIView

- (CGFloat)viewHeight;

@end

@interface DEBUGSSInputCategoryView : UIView

@property (nonatomic, weak) id<DEBUGSSInputCategoryViewDelegate> delegate;

- (void)insertItemWithText:(NSString *)text;

- (CGFloat)viewHeight;

@end
