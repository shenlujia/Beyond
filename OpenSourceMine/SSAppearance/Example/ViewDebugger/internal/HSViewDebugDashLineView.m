//
//  HSViewDebugDashLineView.m
//  AFNetworking
//
//  Created by shenlujia on 2017/12/21.
//

#import "HSViewDebugDashLineView.h"

@interface HSViewDebugDashLineView ()

@end

@implementation HSViewDebugDashLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = UIColor.clearColor;
    self.userInteractionEnabled = NO;
    
    self.dash = 1;
    self.spacing = 1;
    
    self.lineColor = UIColor.blackColor;
    self.horizontal = YES;
    
    return self;
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

- (void)setHorizontal:(BOOL)horizontal
{
    _horizontal = horizontal;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    const CGSize size = self.bounds.size;
    [self drawDashLine:self.lineColor
                  dash:self.dash
               spacing:self.spacing
             thickness:self.horizontal ? size.width : size.height];
}

- (void)drawDashLine:(UIColor *)color
                dash:(CGFloat)dash
             spacing:(CGFloat)spacing
           thickness:(CGFloat)thickness
{
    if (!color) {
        return;
    }
    
    CGFloat (^checkValue)(CGFloat) = ^CGFloat(CGFloat f) {
        f = MAX(f, 0);
        const CGFloat scale = UIScreen.mainScreen.scale;
        NSInteger pixels = f * scale;
        return pixels / scale;
    };
    
    const CGSize size = self.bounds.size;
    dash = checkValue(dash);
    spacing = checkValue(spacing);
    thickness = checkValue(thickness);
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapButt);
    CGFloat lengths[] = {dash, spacing};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, color.CGColor);
    
    CGContextSetLineWidth(line, thickness);
    CGContextSetLineDash(line, 0, lengths, 2);
    
    if (self.horizontal) {
        CGFloat y = thickness / 2;
        CGContextMoveToPoint(line, 0, y);
        CGContextAddLineToPoint(line, size.width, y);
        CGContextStrokePath(line);
    } else {
        CGFloat x = thickness / 2;
        CGContextMoveToPoint(line, x, 0);
        CGContextAddLineToPoint(line, x, size.height);
        CGContextStrokePath(line);
    }
}

@end
