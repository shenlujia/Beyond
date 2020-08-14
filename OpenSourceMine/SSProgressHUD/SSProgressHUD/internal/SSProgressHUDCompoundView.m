//
//  SSProgressHUDCompoundView.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "SSProgressHUDCompoundView.h"

@interface SSProgressHUDCompoundView ()

@property (nonatomic, strong) UIView *view0;
@property (nonatomic, strong) UIView *view1;

@property (nonatomic, assign) BOOL vertical;
@property (nonatomic, assign) CGFloat space;

@end

@implementation SSProgressHUDCompoundView

- (void)dealloc
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.estimatedItemSize = CGSizeMake(50, 50);
    
    return self;
}

- (instancetype)initWithView:(UIView *)view
                       other:(UIView *)other
                    vertical:(BOOL)vertical
                       space:(CGFloat)space
{
    self = [self init];
    
    [view removeFromSuperview];
    [self addSubview:view];
    self.view0 = view;
    
    [other removeFromSuperview];
    [self addSubview:other];
    self.view1 = other;
    
    self.vertical = vertical;
    self.space = space;
    
    return self;
}

- (void)layoutSubviews
{
    const CGSize size = self.bounds.size;
    CGSize size0 = CGSizeZero;
    CGSize size1 = CGSizeZero;
    [self getView0Size:&size0 view1Size:&size1 size:size];
    
    if (self.vertical) {
        CGRect frame = CGRectMake(0, 0, size0.width, size0.height);
        frame.origin.x = (size.width - frame.size.width) / 2;
        self.view0.frame = frame;
        
        if (frame.size.height > 0) {
            frame.origin.y += frame.size.height + self.space;
        }
        frame.size = size1;
        frame.origin.x = (size.width - frame.size.width) / 2;
        self.view1.frame = frame;
    }
    else {
        CGRect frame = CGRectMake(0, 0, size0.width, size0.height);
        frame.origin.y = (size.height - frame.size.height) / 2;
        self.view0.frame = frame;
        
        if (frame.size.width > 0) {
            frame.origin.x += frame.size.width + self.space;
        }
        frame.size = size1;
        frame.origin.y = (size.height - frame.size.height) / 2;
        self.view1.frame = frame;
    }
    
    [super layoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize size0 = CGSizeZero;
    CGSize size1 = CGSizeZero;
    [self getView0Size:&size0 view1Size:&size1 size:size];
    
    if (self.vertical) {
        size.width = MAX(size0.width, size1.width);
        size.height = size0.height + size1.height;
        if (size0.height > 0 && size1.height > 0) {
            size.height += self.space;
        }
    }
    else {
        size.width = size0.width + size1.width;
        if (size0.width > 0 && size1.width > 0) {
            size.width += self.space;
        }
        size.height = MAX(size0.height, size1.height);
    }
    return size;
}

- (void)getView0Size:(CGSize *)view0Size
           view1Size:(CGSize *)view1Size
                size:(CGSize)size
{
    *view0Size = [self.view0 sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    *view1Size = [self.view1 sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    if (view0Size->width == 0 || view0Size->height == 0) {
        *view0Size = CGSizeZero;
        *view1Size = [self.view1 sizeThatFits:size];
        return;
    }
    if (view1Size->width == 0 || view1Size->height == 0) {
        *view0Size = [self.view0 sizeThatFits:size];
        *view1Size = CGSizeZero;
        return;
    }
    
    const CGSize estimatedSize = self.estimatedItemSize;
    if (self.vertical) {
        const CGFloat tryView1Height = MIN(estimatedSize.height, view1Size->height);
        const CGFloat tryView0Height = size.height - tryView1Height - self.space;
        *view0Size = [self.view0 sizeThatFits:CGSizeMake(size.width, tryView0Height)];
        const CGFloat remain = MAX(size.height - view0Size->height - self.space, 0);
        *view1Size = [self.view1 sizeThatFits:CGSizeMake(size.width, remain)];
    }
    else {
        const CGFloat tryView1Width = MIN(estimatedSize.width, view1Size->width);
        const CGFloat tryView0Width = size.width - tryView1Width - self.space;
        *view0Size = [self.view0 sizeThatFits:CGSizeMake(tryView0Width, size.height)];
        const CGFloat remain = MAX(size.width - view0Size->width - self.space, 0);
        *view1Size = [self.view1  sizeThatFits:CGSizeMake(remain, size.height)];
    }
}

@end
