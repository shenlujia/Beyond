//
//  SSMathUtil.m
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import "SSMathUtil.h"

@implementation SSMathUtil

+ (NSInteger)randomValueWithLength:(NSInteger)length
{
    NSInteger max = pow(10, MAX(length, 1));
    return [self randomValueWithMax:max];
}

+ (NSInteger)randomValueWithMax:(NSInteger)max
{
    return arc4random_uniform((uint32_t)max);
}

+ (NSInteger)digitCount:(NSInteger)value
{
    NSInteger temp = value < 0 ? -value : value;
    NSInteger ret = 0;
    while (temp > 0) {
        temp /= 10;
        ++ret;
    }
    return ret;
}

@end
