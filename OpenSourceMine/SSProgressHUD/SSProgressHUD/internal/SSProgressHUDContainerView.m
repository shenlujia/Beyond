//
//  SSProgressHUDContainerView.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "SSProgressHUDContainerView.h"
#import "SSProgressHUDContentView.h"

@interface SSProgressHUDContainerView ()

@property (nonatomic, strong, readonly) SSProgressHUDContentView *contentView;
@property (nonatomic, strong, readonly) UIView *backgroundView;

@end

@implementation SSProgressHUDContainerView

- (void)dealloc
{
    
}

- (void)layoutSubviews
{
    // 不要在这里重设contentView的frame 因为有动画 可能导致不对
    [super layoutSubviews];
}

- (void)updateWithContentView:(SSProgressHUDContentView *)contentView
               backgroundView:(UIView *)backgroundView
{
    const CGSize size = self.bounds.size;
    
    if (backgroundView != self.backgroundView) {
        [self.backgroundView removeFromSuperview];
        if (backgroundView.superview != self) {
            backgroundView.frame = CGRectMake(0, 0, size.width, size.height);
            backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:backgroundView];
            backgroundView.alpha = 0;
        }
        _backgroundView = backgroundView;
    }
    
    if (self.contentView != contentView) {
        [self.contentView removeFromSuperview];
        if (contentView.superview != self) {
            [self addSubview:contentView];
            contentView.alpha = 0;
        }
        _contentView = contentView;
    }
    
    const CGPoint offset = self.contentView.offset;
    const UIEdgeInsets margin = self.contentView.margin;
    const CGFloat marginX = margin.left + margin.right;
    const CGFloat marginY = margin.top + margin.bottom;
    CGSize contentSize = CGSizeMake(size.width - marginX, size.height - marginY);
    contentSize = [self.contentView sizeThatFits:contentSize];
    CGRect frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    frame.origin.x = MAX(margin.left, (size.width - contentSize.width) / 2) + offset.x;
    frame.origin.y = MAX(margin.top, (size.height - contentSize.height) / 2) + offset.y;
    self.contentView.frame = frame;
    
    [self setNeedsLayout];
}

@end
