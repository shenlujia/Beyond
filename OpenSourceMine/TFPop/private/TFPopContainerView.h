//
//  TFPopContainerView.h
//  TFPop
//
//  Created by admin on 2018/5/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFPopContainerView;

@protocol TFPopContainerViewDelegate <NSObject>
@required
- (void)containerViewFrameDidChange:(TFPopContainerView *)containerView;
- (void)containerViewDidTapMask:(TFPopContainerView *)containerView;
@end

@interface TFPopContainerView : UIView

@property (nonatomic, weak) id <TFPopContainerViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *maskView;

@end
