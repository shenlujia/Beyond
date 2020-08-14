//
//  HSViewDebugUtility.h
//  AFNetworking
//
//  Created by shenlujia on 2017/12/20.
//

#import <UIKit/UIKit.h>

extern const CGFloat kViewDebugSizeMinValue; // 2.0

@interface HSViewDebugUtility : NSObject

+ (UIView *)viewContainsRect:(CGRect)rect inView:(UIView *)view;

+ (NSString *)stringWithFloat:(CGFloat)value;
+ (NSString *)stringWithSize:(CGSize)size;

+ (BOOL)isViewValid:(UIView *)view;

+ (BOOL)isView:(UIView *)view intersecting:(UIView *)otherView horizontal:(BOOL)horizontal;

+ (BOOL)isView:(UIView *)view parentViewOfView:(UIView *)other;

+ (UIView *)commonParentViewOfView:(UIView *)view andView:(UIView *)other;

@end
