//
//  TFPopContainerView.m
//  TFPop
//
//  Created by admin on 2018/5/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "TFPopContainerView.h"

@interface TFPopContainerView ()

@property (nonatomic, assign) CGSize contentSize;

@end

@implementation TFPopContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contentSize = CGSizeZero;
        
        _maskView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
            [self addSubview:view];
            CGRect frame = view.superview.bounds;
            frame.origin = CGPointZero;
            view.frame = frame;
            view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                     UIViewAutoresizingFlexibleHeight);
            [view addGestureRecognizer:({
                [[UITapGestureRecognizer alloc] initWithTarget:self
                                                        action:@selector(tapMaskAction)];
            })];
            view;
        });
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGSize contentSize = self.bounds.size;
    
    if (!CGSizeEqualToSize(self.contentSize, contentSize) &&
        !CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
        [self.delegate containerViewFrameDidChange:self];
    }
    
    self.contentSize = contentSize;
}

- (void)tapMaskAction
{
    [self.delegate containerViewDidTapMask:self];
}

@end
