//
//  TFColorGenerator.h
//  JZNavigationExtension
//
//  Created by admin on 2018/6/13.
//

#import <Foundation/Foundation.h>

#define TFRGB(r, g, b) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1]

@interface TFColorGenerator : NSObject

@property (nonatomic, copy) NSString *hex;
@property (nonatomic, copy) NSString *rgb;
@property (nonatomic, copy) NSString *alpha;

@property (nonatomic, copy, readonly) UIColor *color;

@end
