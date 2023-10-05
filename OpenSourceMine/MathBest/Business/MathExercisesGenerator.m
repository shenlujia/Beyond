//
//  MathExercisesGenerator.m
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import "MathExercisesGenerator.h"
#import "SSMathConfiguration.h"
#import "SSMathNumberDescription.h"
#import "SSMathProblem.h"
#import "SSMathNumber.h"
#import "SSMathUtil.h"

@implementation MathExercisesGenerator

+ (NSString *)generate
{
    SSMathConfiguration *configuration = [SSMathConfiguration shared];
    NSInteger count = [configuration integerForFeature:SSMathNumberDescriptionOfLines];
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger idx = 0; idx < count; ++idx) {
        [array addObject:[self generateLine]];
    }
    return [array componentsJoinedByString:@"\n"];
}

+ (NSString *)generateLine
{
    SSMathConfiguration *configuration = [SSMathConfiguration shared];
    
    SSMathNumberDescription *description1 = [[SSMathNumberDescription alloc] init];
    description1.digit1 = [configuration boolForFeature:SSMathNumberDescription1EnableDigit1];
    description1.digit2 = [configuration boolForFeature:SSMathNumberDescription1EnableDigit2];
    description1.digit3 = [configuration boolForFeature:SSMathNumberDescription1EnableDigit3];
    [description1 repair];
    
    SSMathNumberDescription *description2 = [[SSMathNumberDescription alloc] init];
    description2.digit1 = [configuration boolForFeature:SSMathNumberDescription2EnableDigit1];
    description2.digit2 = [configuration boolForFeature:SSMathNumberDescription2EnableDigit2];
    description2.digit3 = [configuration boolForFeature:SSMathNumberDescription2EnableDigit3];
    description2.plus = [configuration boolForFeature:SSMathNumberDescription2EnablePlus];
    description2.minus = [configuration boolForFeature:SSMathNumberDescription2EnableMinus];
    [description2 repair];
    
    SSMathNumberDescription *description3 = [[SSMathNumberDescription alloc] init];
    description3.digit1 = [configuration boolForFeature:SSMathNumberDescription3EnableDigit1];
    description3.digit2 = [configuration boolForFeature:SSMathNumberDescription3EnableDigit2];
    description3.digit3 = [configuration boolForFeature:SSMathNumberDescription3EnableDigit3];
    description3.plus = [configuration boolForFeature:SSMathNumberDescription3EnablePlus];
    description3.minus = [configuration boolForFeature:SSMathNumberDescription3EnableMinus];
    
    SSMathNumberDescription *description4 = [[SSMathNumberDescription alloc] init];
    description4.digit1 = [configuration boolForFeature:SSMathNumberDescription4EnableDigit1];
    description4.digit2 = [configuration boolForFeature:SSMathNumberDescription4EnableDigit2];
    description4.digit3 = [configuration boolForFeature:SSMathNumberDescription4EnableDigit3];
    description4.plus = [configuration boolForFeature:SSMathNumberDescription4EnablePlus];
    description4.minus = [configuration boolForFeature:SSMathNumberDescription4EnableMinus];
    
    NSArray *descriptions = @[description1, description2, description3, description4];
    
    NSInteger maxLength = [configuration integerForFeature:SSMathLineLength];
    NSMutableString *result = [self p_generateEmptyString:maxLength];
    
    NSMutableArray<id<SSMathProblem>> *problems = [NSMutableArray array];
    for (NSInteger idx = 0; idx < [configuration integerForFeature:SSMathExercisesCountInLine]; ++idx) {
        [problems addObject:[self generateProblem:descriptions]];
    }
    
    // 写入答案
    {
        NSMutableArray *anwsers = [NSMutableArray array];
        for (id<SSMathProblem> one in problems) {
            [anwsers addObject:one.answer];
        }
        NSString *join = [configuration objectForFeature:SSMathAnswersPadding];
        NSString *text = [anwsers componentsJoinedByString:join];
        if (text.length > result.length) {
            text = [text substringWithRange:NSMakeRange(0, result.length)];
        }
        [self p_tryToCoverEnd:result newText:text];
        
        maxLength -= text.length;
    }
    
    // 写入题目
    {
        NSInteger startX = [configuration integerForFeature:SSMathExercisesStart];
        NSInteger padding = [configuration integerForFeature:SSMathExercisesPadding];
        for (NSInteger idx = 0; idx < problems.count; ++idx) {
            id<SSMathProblem> one = problems[idx];
            NSString *text = one.string;
            NSRange range = NSMakeRange(startX, text.length);
            if (startX + text.length <= maxLength) {
                [result replaceCharactersInRange:range withString:text];
            }
            startX += text.length + padding;
        }
    }
    
    return result;
}

+ (id<SSMathProblem>)generateProblem:(NSArray<id<SSMathNumberDescription>> *)descriptions
{
    SSMathConfiguration *configuration = [SSMathConfiguration shared];
    const BOOL carryEnabled = [configuration boolForFeature:SSMathEnableCarry10] || [configuration boolForFeature:SSMathEnableCarry20];
    const BOOL carryMoreThanOnce = [configuration boolForFeature:SSMathCarryMoreThanOnce];
    
    NSArray *numbers = nil;
    while (YES) {
        NSMutableArray *array = [NSMutableArray array];
        BOOL ret = NO;
        if (carryEnabled) {
            ret = [self tryToGenerateCarryNumbers:descriptions result:array];
        } else {
            ret = [self tryToGenerateNumbers:descriptions result:array];
            if (ret && carryMoreThanOnce) {
                BOOL didCarry = NO;
                for (SSMathNumber *number in array) {
                    if (number.didCarry) {
                        didCarry = YES;
                        break;
                    }
                }
                if (!didCarry) {
                    ret = NO;
                }
            }
        }
        if (ret) {
            numbers = array;
            break;
        }
    }
    
    SSMathNumber *lastNumber = numbers.lastObject;
    
    NSMutableString *text = [NSMutableString string];
    [numbers enumerateObjectsUsingBlock:^(SSMathNumber *obj, NSUInteger idx, BOOL *stop) {
        NSMutableString *numberText = [self p_generateEmptyString:obj.stringLength];
        [self p_tryToCoverEnd:numberText newText:[@(obj.value) stringValue]];
        if (idx == 0) {
            [text appendFormat:@"%@", numberText];
        } else {
            [text appendFormat:@" %@ %@", [obj signText], numberText];
        }
    }];
    [text appendString:@" ="];
    
    SSMathProblem *ret = [[SSMathProblem alloc] init];
    ret.string = text;
    if (carryEnabled && lastNumber.currentResult > 0) {
        NSMutableString *text = [NSMutableString stringWithString:@"  "];
        [self p_tryToCoverEnd:text newText:@(lastNumber.currentResult).stringValue];
        ret.answer = text;
    } else {
        ret.answer = [@(lastNumber.currentResult) stringValue];
    }
    
    return ret;
}

+ (BOOL)tryToGenerateCarryNumbers:(NSArray<id<SSMathNumberDescription>> *)descriptions result:(NSMutableArray<SSMathNumber *> *)result
{
    SSMathConfiguration *configuration = [SSMathConfiguration shared];
    const BOOL carry20Enabled = [configuration boolForFeature:SSMathEnableCarry20];
    const BOOL negativeEnabled = [configuration boolForFeature:SSMathEnableNegative];
    const SSMathNumberSign sign = arc4random_uniform(2) == 0 ? SSMathNumberSignPlus : SSMathNumberSignMinus;
    
    SSMathNumber *number0 = [[SSMathNumber alloc] init];
    number0.stringLength = 2;
    number0.value = ({
        NSInteger max = 0;
        if (carry20Enabled) {
            max = sign == SSMathNumberSignPlus ? 20 : 40;
        } else {
            max = sign == SSMathNumberSignPlus ? 10 : 20;
        }
        [SSMathUtil randomValueWithMax:max];
    });
    number0.sign = SSMathNumberSignPlus;
    [number0 updateWithLastValue:0];
    
    SSMathNumber *number1 = [[SSMathNumber alloc] init];
    number1.stringLength = carry20Enabled ? 2 : 1;
    number1.value = ({
        NSInteger max = 10;
        if (carry20Enabled) {
            max = 20;
        }
        [SSMathUtil randomValueWithMax:max];
    });
    number1.sign = sign;
    [number1 updateWithLastValue:number0.currentResult];
    
    if (!number1.didCarry) {
        return NO;
    }
    
    if (number1.currentResult < 0 && !negativeEnabled) {
        return NO;
    }
    
    [result addObject:number0];
    [result addObject:number1];
    return YES;
}

+ (BOOL)tryToGenerateNumbers:(NSArray<id<SSMathNumberDescription>> *)descriptions result:(NSMutableArray<SSMathNumber *> *)result
{
    if (result.count == descriptions.count) {
        return YES;
    }
    
    id<SSMathNumberDescription> description = descriptions[result.count];
    if (![description enabled]) {
        return YES;
    }
    
    SSMathNumber *current = [[SSMathNumber alloc] init];
    current.sign = [description suggestedSign];
    current.stringLength = [description suggestedLength];
    current.value = [description suggestedValue];
    
    // 第一个数
    if (result.count == 0) {
        [current updateWithLastValue:0];
        [result addObject:current];
        return [self tryToGenerateNumbers:descriptions result:result];
    }
        
    // 后面的数
    SSMathNumber *last = result.lastObject;
    [current updateWithLastValue:last.currentResult];
    
    SSMathConfiguration *configuration = [SSMathConfiguration shared];
    const BOOL negativeEnabled = [configuration boolForFeature:SSMathEnableNegative];
    if (!negativeEnabled) {
        if (current.currentResult < 0) {
            return NO;
        }
    }
    
    [result addObject:current];
    return [self tryToGenerateNumbers:descriptions result:result];
}

+ (NSMutableString *)p_generateEmptyString:(NSInteger)length
{
    NSMutableString *result = [NSMutableString string];
    for (NSInteger idx = 0; idx < length; ++idx) {
        [result appendString:@" "];
    }
    return result;
}

+ (void)p_tryToCoverEnd:(NSMutableString *)origin newText:(NSString *)newText
{
    if (origin.length >= newText.length) {
        NSRange range = NSMakeRange(origin.length - newText.length, newText.length);
        [origin replaceCharactersInRange:range withString:newText];
    }
}

@end
