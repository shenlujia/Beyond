//
//  MathExercisesGenerator.m
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import "MathExercisesGenerator.h"
#import "MathExercisesManager.h"
#import "SSMathNumberDescription.h"
#import "SSMathProblem.h"
#import "SSMathNumber.h"

@implementation MathExercisesGenerator

+ (NSString *)generate
{
    MathExercisesManager *manager = [MathExercisesManager manager];
    NSString *count = [manager objectForFeature:SSMathNumberDescriptionOfLines];
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger idx = 0; idx < count.integerValue; ++idx) {
        [array addObject:[self generateLine]];
    }
    return [array componentsJoinedByString:@"\n"];
}

+ (NSString *)generateLine
{
    MathExercisesManager *manager = [MathExercisesManager manager];
    
    SSMathNumberDescription *number1 = [[SSMathNumberDescription alloc] init];
    number1.enabled = YES;
    number1.digit1 = [manager boolForFeature:SSMathNumberDescription1EnableDigit1];
    number1.digit2 = [manager boolForFeature:SSMathNumberDescription1EnableDigit2];
    number1.digit3 = [manager boolForFeature:SSMathNumberDescription1EnableDigit3];
    
    SSMathNumberDescription *number2 = [[SSMathNumberDescription alloc] init];
    number2.enabled = YES;
    number2.digit1 = [manager boolForFeature:SSMathNumberDescription2EnableDigit1];
    number2.digit2 = [manager boolForFeature:SSMathNumberDescription2EnableDigit2];
    number2.digit3 = [manager boolForFeature:SSMathNumberDescription2EnableDigit3];
    number2.plus = [manager boolForFeature:SSMathNumberDescription2EnablePlus];
    number2.minus = [manager boolForFeature:SSMathNumberDescription2EnableMinus];
    
    SSMathNumberDescription *number3 = [[SSMathNumberDescription alloc] init];
    number3.enabled = [manager boolForFeature:SSMathNumberDescription3Enable];
    number3.digit1 = [manager boolForFeature:SSMathNumberDescription3EnableDigit1];
    number3.digit2 = [manager boolForFeature:SSMathNumberDescription3EnableDigit2];
    number3.digit3 = [manager boolForFeature:SSMathNumberDescription3EnableDigit3];
    number3.plus = [manager boolForFeature:SSMathNumberDescription3EnablePlus];
    number3.minus = [manager boolForFeature:SSMathNumberDescription3EnableMinus];
    
    SSMathNumberDescription *number4 = [[SSMathNumberDescription alloc] init];
    number4.enabled = [manager boolForFeature:SSMathNumberDescription4Enable];
    number4.digit1 = [manager boolForFeature:SSMathNumberDescription4EnableDigit1];
    number4.digit2 = [manager boolForFeature:SSMathNumberDescription4EnableDigit2];
    number4.digit3 = [manager boolForFeature:SSMathNumberDescription4EnableDigit3];
    number4.plus = [manager boolForFeature:SSMathNumberDescription4EnablePlus];
    number4.minus = [manager boolForFeature:SSMathNumberDescription4EnableMinus];
    
    NSArray *descriptions = @[number1, number2, number3, number4];
    
    NSInteger maxLength = [manager integerForFeature:SSMathLineLength];
    NSMutableString *result = [self p_generateEmptyString:maxLength];
    
    NSMutableArray<id<SSMathProblem>> *problems = [NSMutableArray array];
    for (NSInteger idx = 0; idx < [[manager objectForFeature:SSMathExercisesCountInLine] integerValue]; ++idx) {
        [problems addObject:[self generateProblem:descriptions]];
    }
    
    // 写入答案
    {
        NSMutableArray *anwsers = [NSMutableArray array];
        for (id<SSMathProblem> one in problems) {
            [anwsers addObject:one.answer];
        }
        NSString *text = [anwsers componentsJoinedByString:@"  "];
        if (text.length > result.length) {
            text = [text substringWithRange:NSMakeRange(0, result.length)];
        }
        NSRange range = NSMakeRange(result.length - text.length, text.length);
        [result replaceCharactersInRange:range withString:text];
        
        maxLength -= text.length;
    }
    
    // 写入题目
    {
        NSInteger startX = [manager integerForFeature:SSMathExercisesStart];
        NSInteger padding = [manager integerForFeature:SSMathExercisesPadding];
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
    NSArray *numbers = nil;
    while (YES) {
        NSMutableArray *array = [NSMutableArray array];
        BOOL ret = [self tryToGenerateNumbers:descriptions result:array];
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
    ret.answer = [@(lastNumber.currentResult) stringValue];
    
    return ret;
}

+ (BOOL)tryToGenerateNumbers:(NSArray<id<SSMathNumberDescription>> *)descriptions result:(NSMutableArray<SSMathNumber *> *)result
{
    if (result.count == descriptions.count) {
        return YES;
    }
    
    id<SSMathNumberDescription> description = descriptions[result.count];
    if (!description.enabled) {
        return YES;
    }
    
    SSMathNumber *current = [[SSMathNumber alloc] init];
    current.sign = [description suggestedSign];
    current.stringLength = [description suggestedLength];
    current.value = [description suggestedValue];
    
    // 第一个数
    if (result.count == 0) {
        current.currentResult = current.value;
        [result addObject:current];
        return [self tryToGenerateNumbers:descriptions result:result];
    }
        
    // 后面的数
    SSMathNumber *last = result.lastObject;
    MathExercisesManager *manager = [MathExercisesManager manager];
    
    switch (current.sign) {
        case SSMathNumberSignPlus: {
            current.currentResult = last.currentResult + current.value;
            break;
        }
        case SSMathNumberSignMinus: {
            current.currentResult = last.currentResult - current.value;
            break;
        }
    }
    
    if (![manager boolForFeature:SSMathEnableCarry]) {
        // 进位暂未实现
    }
    
    if (![manager boolForFeature:SSMathEnableNegative]) {
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
