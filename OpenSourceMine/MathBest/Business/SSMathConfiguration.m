//
//  SSMathConfiguration.m
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import "SSMathConfiguration.h"

@implementation SSMathConfiguration

+ (SSMathConfiguration *)shared
{
    static dispatch_once_t onceToken;
    static SSMathConfiguration *ret = nil;
    dispatch_once(&onceToken, ^{
        ret = [[self alloc] init];
    });
    return ret;
}

- (void)setObject:(id)object forFeature:(SSMathFeature)feature
{
    NSString *key = [self keyForFeature:feature];
    [NSUserDefaults.standardUserDefaults setObject:object forKey:key];
}

- (NSString *)objectForFeature:(SSMathFeature)feature
{
    NSString *key = [self keyForFeature:feature];
    NSString *object = [NSUserDefaults.standardUserDefaults objectForKey:key];
    if (!object) {
        object = @"";
    }
    if (![object isKindOfClass:[NSString class]]) {
        object = [NSString stringWithFormat:@"%@", object];
    }
    
    if (feature == SSMathLineLength) {
        if (object.integerValue <= 50) {
            object = @"50";
        }
    } else if (feature == SSMathNumberDescriptionOfLines) {
        if (object.integerValue <= 20) {
            object = @"20";
        }
    } else if (feature == SSMathExercisesCountInLine) {
        if (object.integerValue <= 1) {
            object = @"1";
        } else if (object.integerValue >= 10) {
            object = @"10";
        }
    } else if (feature == SSMathExercisesStart) {
        if (object.integerValue <= 0) {
            object = @"0";
        } else if (object.integerValue >= 20) {
            object = @"20";
        }
    } else if (feature == SSMathExercisesPadding) {
        if (object.integerValue <= 2) {
            object = @"2";
        } else if (object.integerValue >= 30) {
            object = @"30";
        }
    } else if (feature == SSMathAnswersPadding) {
        object = [object stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
        object = [object stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
        object = [object stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        if (object.length == 0) {
            object = @" ";
        }
        if (object.length >= 10) {
            object = [object substringToIndex:10];
        }
    }
    
    return object;
}

- (NSString *)keyForFeature:(SSMathFeature)feature
{
    return [NSString stringWithFormat:@"math_key_%@", @(feature)];
}

- (NSInteger)integerForFeature:(SSMathFeature)feature
{
    return [[self objectForFeature:feature] integerValue];
}

- (BOOL)boolForFeature:(SSMathFeature)feature
{
    return [[self objectForFeature:feature] boolValue];
}

@end
