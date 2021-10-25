//
//  CornerController.m
//  Beyond
//
//  Created by ZZZ on 2021/10/21.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "CornerController.h"

@implementation CornerController

- (void)viewDidLoad
{
    WEAKSELF
    [super viewDidLoad];
    
    [self test:@"反mask 实现圆角" tap:^(UIButton *button, NSDictionary *userInfo) {
        CGSize size = CGSizeMake(100, 100);
        CGFloat radius = 70;
        UIView * (^create)(CGFloat x, CGFloat y) = ^UIView * (CGFloat x, CGFloat y) {
            UIView *p = [[UIView alloc] initWithFrame:CGRectMake(x, y, size.width, size.height)];
            [weak_s.view addSubview:p];
            p.backgroundColor = [UIColor.cyanColor colorWithAlphaComponent:0.5];
            UIView *view = [[UIView alloc] initWithFrame:p.bounds];
            view.backgroundColor = UIColor.redColor;
            [p addSubview:view];
            return view;
        };
        { // 左上
            UIView *view = create(100, 100);
            
            CAShapeLayer *mask = [CAShapeLayer layer];
            mask.frame = CGRectMake(0, 0, size.width, size.height);
            CGRect rect = mask.bounds;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
            [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + radius)];
            [path addArcWithCenter:CGPointMake(CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius) radius:radius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
            [path closePath];
            mask.path = path.CGPath;
            view.layer.mask = mask;
        }
        { // 左下
            UIView *view = create(100, 210);
            
            CAShapeLayer *mask = [CAShapeLayer layer];
            mask.frame = CGRectMake(0, 0, size.width, size.height);
            CGRect rect = mask.bounds;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))];
            [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - radius)];
            [path addArcWithCenter:CGPointMake(CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius) radius:radius startAngle:M_PI endAngle:M_PI_2 clockwise:NO];
            [path closePath];
            mask.path = path.CGPath;
            view.layer.mask = mask;
        }
        { // 右上
            UIView *view = create(210, 100);
            
            CAShapeLayer *mask = [CAShapeLayer layer];
            mask.frame = CGRectMake(0, 0, size.width, size.height);
            CGRect rect = mask.bounds;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect) + radius)];
            [path addArcWithCenter:CGPointMake(CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius) radius:radius startAngle:0 endAngle:-M_PI_2 clockwise:NO];
            [path closePath];
            mask.path = path.CGPath;
            view.layer.mask = mask;
        }
        { // 右下
            UIView *view = create(210, 210);
            
            CAShapeLayer *mask = [CAShapeLayer layer];
            mask.frame = CGRectMake(0, 0, size.width, size.height);
            CGRect rect = mask.bounds;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect) - radius)];
            [path addArcWithCenter:CGPointMake(CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius) radius:radius startAngle:0 endAngle:M_PI_2 clockwise:YES];
            [path closePath];
            mask.path = path.CGPath;
            view.layer.mask = mask;
        }
    }];
}

@end
