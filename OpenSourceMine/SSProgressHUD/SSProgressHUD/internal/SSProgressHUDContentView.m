//
//  SSProgressHUDContentView.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "SSProgressHUDContentView.h"
#import "SSProgressHUDCompoundView.h"
#import "SSProgressHUDLabel.h"
#import "SSProgressHUDImageView.h"
#import "SSProgressHUDStyle.h"

@interface SSProgressHUDContentView ()

@property (nonatomic, strong) SSProgressHUDCompoundView *view;
@property (nonatomic, assign) UIEdgeInsets padding;

@end

@implementation SSProgressHUDContentView

- (void)dealloc
{
    
}

- (void)layoutSubviews
{
    const CGSize size = self.bounds.size;
    const UIEdgeInsets padding = self.padding;
    const CGFloat paddingX = padding.left + padding.right;
    const CGFloat paddingY = padding.top + padding.bottom;
    
    self.view.frame = CGRectMake(padding.left, padding.top, size.width - paddingX, size.height - paddingY);
    
    [super layoutSubviews];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    const UIEdgeInsets padding = self.padding;
    const CGFloat paddingX = padding.left + padding.right;
    const CGFloat paddingY = padding.top + padding.bottom;
    
    size.width -= paddingX;
    size.height -= paddingY;
    size = [self.view sizeThatFits:size];
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return CGSizeZero;
    }
    return CGSizeMake(size.width + paddingX, size.height + paddingY);
}

- (void)updateWithStyle:(SSProgressHUDStyle *)style
{
    for (UIView *view in [self.subviews copy]) {
        [view removeFromSuperview];
    }
    
    self.padding = style.contentPadding;
    _margin = style.contentMargin;
    _offset = style.offset;
    
    UIView * (^createViewWithSubArray)(id) = ^UIView *(NSArray *array) {
        SSProgressHUDCompoundView *view = nil;
        for (id obj in array) {
            UIView *other = [self createViewWithType:obj style:style];
            view = [[SSProgressHUDCompoundView alloc] initWithView:view
                                                             other:other
                                                          vertical:NO
                                                             space:style.horizontalSpace];
        }
        return view;
    };
    
    SSProgressHUDCompoundView *view = nil;
    for (id obj in style.layout) {
        UIView *other = nil;
        if ([obj isKindOfClass:NSArray.class]) {
            other = createViewWithSubArray(obj);
        } else if ([obj isKindOfClass:NSNumber.class]) {
            other = [self createViewWithType:obj style:style];
        }
        view = [[SSProgressHUDCompoundView alloc] initWithView:view
                                                         other:other
                                                      vertical:YES
                                                         space:style.verticalSpace];
    }
    [self addSubview:view];
    self.view = view;
}

- (UIView *)createViewWithType:(NSNumber *)type style:(SSProgressHUDStyle *)style
{
    SSProgressHUDItem item = SSProgressHUDItemInvalid;
    if ([type respondsToSelector:@selector(integerValue)]) {
        item = type.integerValue;
    }
    
    UIView *view = nil;
    switch (item) {
        case SSProgressHUDItemText: {
            if (style.text.length || style.attributedText.length) {
                view = ({
                    UILabel *view = [[SSProgressHUDLabel alloc] init];
                    view.numberOfLines = 0;
                    view.font = style.font;
                    view.textColor = style.textColor;
                    view.text = style.text;
                    if (style.attributedText.length) {
                        view.attributedText = style.attributedText;
                    }
                    view;
                });
            }
            break;
        }
        case SSProgressHUDItemImage: {
            if (style.image) {
                view = ({
                    UIImageView *view = [[SSProgressHUDImageView alloc] init];
                    view.image = style.image;
                    view;
                });
            }
            break;
        }
        case SSProgressHUDItemIndicator: {
            view = ({
                UIActivityIndicatorView *view = nil;
                UIActivityIndicatorViewStyle value = style.indicatorStyle;
                view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:value];
                [view startAnimating];
                view;
            });
            break;
        }
        default: {
            break;
        }
    }
    return view;
}

@end
