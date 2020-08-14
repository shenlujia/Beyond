//
//  HSViewDebugUtility.m
//  AFNetworking
//
//  Created by shenlujia on 2017/12/20.
//

#import "HSViewDebugUtility.h"
#import "HSViewDebugSizeView.h"
#import "HSViewDebugMarginView.h"

const CGFloat kViewDebugSizeMinValue = 2.0;

@implementation HSViewDebugUtility

+ (UIView *)viewContainsRect:(CGRect)rect inView:(UIView *)view
{
    if (![self isViewValid:view]) {
        return nil;
    }
    if (!CGRectContainsRect(view.bounds, rect)) {
        return nil;
    }
    
    __block UIView *result = nil;
    id enumBlock = ^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect subrect = [view convertRect:rect toView:subview];
        result = [self viewContainsRect:subrect inView:subview];
        if (result) {
            *stop = YES;
        }
    };
    [view.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:enumBlock];
    
    if (result) {
        return result;
    }
    
    return view;
}

+ (NSString *)stringWithFloat:(CGFloat)value
{
    value = fabs(value);
    NSInteger intValue = value;
    if (fabs(intValue - value) < 0.01) {
        return [NSString stringWithFormat:@"%ld", intValue];
    }
    return [NSString stringWithFormat:@"%.1f", value];
}

+ (NSString *)stringWithSize:(CGSize)size
{
    NSString *width = [self stringWithFloat:size.width];
    NSString *height = [self stringWithFloat:size.height];
    return [NSString stringWithFormat:@"(%@, %@)", width, height];
}

+ (BOOL)isViewValid:(UIView *)view
{
    if (!view || view.hidden || view.alpha < 0.1) {
        return NO;
    }
    if ([view isKindOfClass:[HSViewDebugSizeView class]] ||
        [view isKindOfClass:[HSViewDebugMarginView class]]) {
        return NO;
    }
    return YES;
}

+ (BOOL)isView:(UIView *)view intersecting:(UIView *)otherView horizontal:(BOOL)horizontal
{
    if (!view.superview || !otherView.superview) {
        return NO;
    }
    if (view.superview != otherView.superview) {
        return NO;
    }
    
    if (horizontal) {
        const CGFloat min0 = CGRectGetMinX(view.frame);
        const CGFloat maxX0 = CGRectGetMaxX(view.frame);
        const CGFloat min1 = CGRectGetMinX(otherView.frame);
        const CGFloat maxX1 = CGRectGetMaxX(otherView.frame);
        if (min1 <= min0 && min0 <= maxX1) {
            return YES;
        }
        if (min0 <= min1 && min1 <= maxX0) {
            return YES;
        }
    } else {
        const CGFloat min0 = CGRectGetMinY(view.frame);
        const CGFloat max0 = CGRectGetMaxY(view.frame);
        const CGFloat min1 = CGRectGetMinY(otherView.frame);
        const CGFloat max1 = CGRectGetMaxY(otherView.frame);
        if (min1 <= min0 && min0 <= max1) {
            return YES;
        }
        if (min0 <= min1 && min1 <= max0) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isView:(UIView *)view parentViewOfView:(UIView *)other
{
    if (!view || !other) {
        return NO;
    }
    UIView *superview = other.superview;
    while (superview) {
        if (superview == view) {
            return YES;
        }
        superview = superview.superview;
    }
    return NO;
}

+ (UIView *)commonParentViewOfView:(UIView *)view andView:(UIView *)other
{
    if (!view || !other) {
        return nil;
    }
    
    NSArray * (^superviewsBlock)(UIView *) = ^NSArray *(UIView *view) {
        NSMutableArray *array = [NSMutableArray array];
        UIView *superview = view.superview;
        while (superview) {
            [array addObject:superview];
            superview = superview.superview;
        }
        return [array copy];
    };
    
    NSArray *superviews0 = superviewsBlock(view);
    NSArray *superviews1 = superviewsBlock(other);
    for (UIView *superview in superviews0) {
        if ([superviews1 containsObject:superview]) {
            return superview;
        }
    }
    return nil;
}

@end
