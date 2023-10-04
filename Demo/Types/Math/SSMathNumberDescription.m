//
//  SSMathNumberDescription.m
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import "SSMathNumberDescription.h"
#import "SSMathUtil.h"

@implementation SSMathNumberDescription

- (void)repair
{
    if (!self.digit1 && !self.digit2 && !self.digit3) {
        self.digit1 = YES;
    }
}

- (BOOL)enabled
{
    return self.digit1 || self.digit2 || self.digit3;
}

- (NSInteger)suggestedLength
{
    if (self.digit3) {
        return 3;
    }
    if (self.digit2) {
        return 2;
    }
    return 1;
}

- (SSMathNumberSign)suggestedSign
{
    NSMutableArray *array = [NSMutableArray array];
    if (self.plus) {
        [array addObject:@(SSMathNumberSignPlus)];
    }
    if (self.minus) {
        [array addObject:@(SSMathNumberSignMinus)];
    }
    if (array.count == 0) {
        return SSMathNumberSignPlus;
    }
    NSInteger random = arc4random_uniform((uint32_t)array.count);
    return [array[random] integerValue];
}

- (NSInteger)suggestedValue
{
    NSInteger value = 0;
    NSInteger length = [self suggestedLength];
    while (YES) {
        NSInteger temp = [SSMathUtil randomValueWithLength:length];
        NSInteger count = log(temp) / log(10) + 1;
        if ((count == 1 && self.digit1) ||
            (count == 2 && self.digit2) ||
            (count == 3 && self.digit3)) {
            value = temp;
            break;
        }
    }
    return value;
}

@end
