//
//  CornerController.m
//  Beyond
//
//  Created by ZZZ on 2021/10/21.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "CornerController.h"
#import "HollowView.h"

@implementation CornerController

- (void)viewDidLoad
{
    WEAKSELF
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.cyanColor;
    
    [self test:@"展示镂空部分并动画" tap:^(UIButton *button, NSDictionary *userInfo) {
        HollowView *testView = [[HollowView alloc] initWithFrame:CGRectMake(100, 100, 200, 300)];
        [weak_s.view addSubview:testView];
        testView.backgroundColor = UIColor.redColor;
//        testView.animationDuration = 2;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:testView.bounds];
        [testView addSubview:imageView];
        
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"test_video1-0001" ofType:@"jpg"];
        imageView.image = [UIImage imageWithContentsOfFile:imagePath];
        imageView.backgroundColor = UIColor.brownColor;
        
        CGFloat interval = 1.6 ;//* testView.animationDuration;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(10, 10, 100, 100) cornerRadius:20];
        [testView resetHollowPath:path];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(10, 10, 50, 50) cornerRadius:20];
            [testView resetHollowPath:path];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(30, 30, 60, 60) cornerRadius:20];
                [testView resetHollowPath:path];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UIBezierPath *path = nil;
                    [testView resetHollowPath:path];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [testView removeFromSuperview];
                    });
                });
            });
        });
        
//        
//        UIBezierPath *toBezierPath = nil;
//        {
//            toBezierPath = [UIBezierPath bezierPathWithRect:imageView.bounds];
//            UIBezierPath *subPath2 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(10, 10, 50, 50) cornerRadius:20];
//            
//            [toBezierPath appendPath:subPath2];
////            let bezierPath = UIBezierPath(rect: testView1.bounds)
////                    // 圆形 arcCenter中心点 endAngle 一般写2pi
////                    let subPath = UIBezierPath(arcCenter: CGPoint(x: 100, y: 100), radius: 50, startAngle: 0.0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
////
//                    // 矩形 roundedRect 矩形位置  cornerRadius 矩形圆边
////                    let subPath2 = UIBezierPath(roundedRect: CGRect(x: 10, y: 10, width: 180, height: 180), cornerRadius: 10)
//                    
////                    bezierPath.append(subPath2)
//                    
////                    let maskLayer = CAShapeLayer()
////                    maskLayer.path = bezierPath.cgPath
////                    maskLayer.fillRule = .evenOdd
//
//        }
//        
//        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
//        pathAnimation.toValue = (__bridge id _Nullable)(toBezierPath.CGPath);
//        pathAnimation.duration = 3.0;
//        pathAnimation.fillMode = kCAFillModeForwards;
//        pathAnimation.removedOnCompletion = NO;
//        [maskLayer addAnimation:pathAnimation forKey:@"pathAnimation"];
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            UIBezierPath *toBezierPath = [UIBezierPath bezierPathWithRect:imageView.bounds];
//            
//            
//            [toBezierPath appendPath:subPath2];
//            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
//            pathAnimation.toValue = (__bridge id _Nullable)(toBezierPath.CGPath);
//            pathAnimation.duration = 3.0;
//            pathAnimation.fillMode = kCAFillModeForwards;
//            pathAnimation.removedOnCompletion = NO;
//            [maskLayer addAnimation:pathAnimation forKey:@"pathAnimation"];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [imageView removeFromSuperview];
//            });
//        });
    }];
    
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
