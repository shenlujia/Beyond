//
//  UIView+TFDEBUG.m
//  SLJ
//
//  Created by shenlujia on 2016/1/25.
//

#import "UIView+TFDEBUG.h"

@implementation UIView (TFDEBUG)

- (void)test_updateBackgroundWithRandomColor
{
    UIView *view = (UIView *)self;
    view = [view isKindOfClass:[UIView class]] ? view : nil;
    if (view) {
        CGFloat r = arc4random() % 256 / 256.0;
        CGFloat g = arc4random() % 256 / 256.0;
        CGFloat b = arc4random() % 256 / 256.0;
        view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1];
        [view.subviews makeObjectsPerformSelector:@selector(test_updateBackgroundWithRandomColor)];
    }
}

@end
