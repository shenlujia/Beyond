//
//  HSViewDebugLocation.m
//  AFNetworking
//
//  Created by shenlujia on 2017/12/21.
//

#import "HSViewDebugViewPosition.h"
#import "HSViewDebugUtility.h"

@interface HSViewDebugViewPosition ()

@end

@implementation HSViewDebugViewPosition

- (instancetype)initWithView:(UIView *)view
{
    self = [self init];
    if (self) {
        _view = view;
        [self refresh];
    }
    return self;
}

- (void)refresh
{
    UIView *superview = self.view.superview;
    CGRect rect = self.view.frame;
    
    _left = CGRectGetMinX(rect);
    _leftView = superview;
    
    _right = CGRectGetWidth(superview.frame) - CGRectGetMaxX(rect);
    _rightView = superview;
    
    _top = CGRectGetMinY(rect);
    _topView = superview;
    
    _bottom = CGRectGetHeight(superview.frame) - CGRectGetMaxY(rect);
    _bottomView = superview;
}

- (void)updateWithSiblingView:(UIView *)siblingView
{
    if (self.view.superview != siblingView.superview ||
        !siblingView.superview) {
        return;
    }
    
    CGRect rect = self.view.frame;
    CGRect siblingRect = siblingView.frame;
    
    // left
    if ([HSViewDebugUtility isView:self.view intersecting:siblingView horizontal:NO]) {
        const CGFloat minDiff = CGRectGetMinX(rect) - CGRectGetMaxX(siblingRect);
        const CGFloat maxDiff = CGRectGetMinX(rect) - CGRectGetMinX(siblingRect);
        if (minDiff >= 0 && minDiff < self.left) {
            _left = minDiff;
            _leftView = siblingView;
        } else if (maxDiff > 0 && maxDiff < self.left) {
            _left = maxDiff;
            _leftView = siblingView;
        }
    }
    // right
    if ([HSViewDebugUtility isView:self.view intersecting:siblingView horizontal:NO]) {
        const CGFloat minDiff = CGRectGetMinX(siblingRect) - CGRectGetMaxX(rect);
        const CGFloat maxDiff = CGRectGetMaxX(siblingRect) - CGRectGetMaxX(rect);
        if (minDiff >= 0 && minDiff < self.right) {
            _right = minDiff;
            _rightView = siblingView;
        } else if (maxDiff > 0 && maxDiff < self.right) {
            _right = maxDiff;
            _rightView = siblingView;
        }
    }
    // top
    if ([HSViewDebugUtility isView:self.view intersecting:siblingView horizontal:YES]) {
        const CGFloat minDiff = CGRectGetMinY(rect) - CGRectGetMaxY(siblingRect);
        const CGFloat maxDiff = CGRectGetMinY(rect) - CGRectGetMinY(siblingRect);
        if (minDiff >= 0 && minDiff < self.top) {
            _top = minDiff;
            _topView = siblingView;
        } else if (maxDiff > 0 && maxDiff < self.top) {
            _top = maxDiff;
            _topView = siblingView;
        }
    }
    // bottom
    if ([HSViewDebugUtility isView:self.view intersecting:siblingView horizontal:YES]) {
        const CGFloat minDiff = CGRectGetMinY(siblingRect) - CGRectGetMaxY(rect);
        const CGFloat maxDiff = CGRectGetMaxY(siblingRect) - CGRectGetMaxY(rect);
        if (minDiff >= 0 && minDiff < self.bottom) {
            _bottom = minDiff;
            _bottomView = siblingView;
        } else if (maxDiff > 0 && maxDiff < self.bottom) {
            _bottom = maxDiff;
            _bottomView = siblingView;
        }
    }
}

@end
