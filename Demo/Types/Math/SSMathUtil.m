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

@end
