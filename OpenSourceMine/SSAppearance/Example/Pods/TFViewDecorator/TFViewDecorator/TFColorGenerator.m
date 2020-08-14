//
//  TFColorGenerator.m
//  JZNavigationExtension
//
//  Created by admin on 2018/6/13.
//

#import "TFColorGenerator.h"

@implementation TFColorGenerator

- (UIColor *)color
{
    const CGFloat alpha = ({
        CGFloat ret = 1;
        if (self.alpha.length) {
            ret = self.alpha.floatValue;
        }
        ret = MAX(ret, 0);
        MIN(ret, 1);
    });
    
    if (self.rgb.length) {
        NSString *rgb = [self.rgb stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *components = [rgb componentsSeparatedByString:@","];
        if (components.count == 3) {
            const CGFloat r = [components[0] floatValue] / 255;
            const CGFloat g = [components[1] floatValue] / 255;
            const CGFloat b = [components[2] floatValue] / 255;
            return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
        }
    }
    
    if (self.hex.length) {
        NSString *hex = [self.hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
        NSScanner *scanner = [NSScanner scannerWithString:hex];
        unsigned int value = 0;
        [scanner scanHexInt:&value];
        return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16)) / 255.0
                               green:((float)((value & 0xFF00) >> 8)) / 255.0
                                blue:((float)(value & 0xFF)) / 255.0
                               alpha:alpha];
    }
    
    return nil;
}

@end
