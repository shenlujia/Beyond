//
//  TFImageGenerator.m
//  JZNavigationExtension
//
//  Created by admin on 2018/6/13.
//

#import "TFImageGenerator.h"

@implementation TFImageGenerator

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _size = CGSizeZero;
        
        _color = nil;
        _image = nil;
        
        _cornerRadius = 0;
        _roundingCorners = UIRectCornerAllCorners;
        
        _borderWidth = 0;
        _borderColor = UIColor.blackColor;
    }
    
    return self;
}

- (UIImage *)generate
{
    if (CGSizeEqualToSize(self.size, CGSizeZero)) {
        return nil;
    }
    
    UIImage *image = self.image;
    if (!image) {
        if (!self.color) {
            return nil;
        }
        image = [self imageWithColor:self.color];
    }
    
    return [self imageWithImage:image
                           size:self.size
                   cornerRadius:self.cornerRadius
                roundingCorners:self.roundingCorners
                    borderWidth:self.borderWidth
                    borderColor:self.borderColor];
}

- (UIImage *)imageWithImage:(UIImage *)image
                       size:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius
            roundingCorners:(UIRectCorner)roundingCorners
                borderWidth:(CGFloat)borderWidth
                borderColor:(UIColor *)borderColor
{
    const CGSize imageSize = size;
    const CGFloat deviceScale = UIScreen.mainScreen.scale;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, deviceScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (borderColor && borderWidth > 0) {
        const CGFloat x = borderWidth / 2;
        const CGRect borderRect = CGRectMake(x, x, size.width - 2 * x, size.height - 2 * x);
        const CGSize cornerRadii = CGSizeMake(cornerRadius - x, cornerRadius - x);
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:borderRect
                                                         byRoundingCorners:roundingCorners
                                                               cornerRadii:cornerRadii];
        
        CGContextAddPath(context, borderPath.CGPath);
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        CGContextSetLineWidth(context, borderWidth);
        CGContextStrokePath(context);
    }
    
    UIBezierPath *imagePath = ({
        const CGFloat offset = borderWidth;
        const CGRect imageRect = CGRectMake(offset,
                                            offset,
                                            size.width - 2 * offset,
                                            size.height - 2 * offset);
        const CGFloat radius = MAX(cornerRadius - offset, 0);
        const CGSize cornerRadii = CGSizeMake(radius, radius);
        [UIBezierPath bezierPathWithRoundedRect:imageRect
                              byRoundingCorners:roundingCorners
                                    cornerRadii:cornerRadii];
    });

    CGContextAddPath(context, imagePath.CGPath);
    CGContextClip(context);
    
    [image drawInRect:({
        CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height);
        rect.size.width = ceil(rect.size.width * deviceScale) / deviceScale;
        rect.size.height = ceil(rect.size.height * deviceScale) / deviceScale;
        rect.origin.x = (size.width - rect.size.width) / 2;
        rect.origin.y = (size.height - rect.size.height) / 2;
        rect;
    })];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return ret;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
