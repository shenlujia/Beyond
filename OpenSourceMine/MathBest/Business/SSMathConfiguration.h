//
//  SSMathConfiguration.h
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SSMathFeature) {
    SSMathLineLength = 0, // 单行长度
    SSMathNumberDescriptionOfLines = 1, // 行数
    SSMathExercisesCountInLine = 2, // 每行题目数
    SSMathExercisesStart = 3, // 题目开始位置
    SSMathExercisesPadding = 4, // 题目间隔
    
    SSMathEnableCarry10 = 100, // 快捷模式 固定(0~10)两个数字进位加减法
    SSMathEnableCarry20 = 101, // 快捷模式 固定(0~20)两个数字进位加减法
    
    SSMathEnableNegative = 201, // 开启负数
    SSMathCarryMoreThanOnce = 202, // 至少有一次进位或退位
    
    SSMathNumberDescription1EnableDigit1 = 1001, // 数字1 启用一位数
    SSMathNumberDescription1EnableDigit2 = 1002, // 数字1 启用二位数
    SSMathNumberDescription1EnableDigit3 = 1003, // 数字1 启用三位数
    
    SSMathNumberDescription2EnableDigit1 = 2001, // 数字2 启用一位数
    SSMathNumberDescription2EnableDigit2 = 2002, // 数字2 启用二位数
    SSMathNumberDescription2EnableDigit3 = 2003, // 数字2 启用三位数
    SSMathNumberDescription2EnablePlus = 2100, // 数字2 启用加法
    SSMathNumberDescription2EnableMinus = 2101, // 数字2 启用减法
    
    SSMathNumberDescription3EnableDigit1 = 3001, // 数字3 启用一位数
    SSMathNumberDescription3EnableDigit2 = 3002, // 数字3 启用二位数
    SSMathNumberDescription3EnableDigit3 = 3003, // 数字3 启用三位数
    SSMathNumberDescription3EnablePlus = 3100, // 数字3 启用加法
    SSMathNumberDescription3EnableMinus = 3101, // 数字3 启用减法
    
    SSMathNumberDescription4EnableDigit1 = 4001, // 数字4 启用一位数
    SSMathNumberDescription4EnableDigit2 = 4002, // 数字4 启用二位数
    SSMathNumberDescription4EnableDigit3 = 4003, // 数字4 启用三位数
    SSMathNumberDescription4EnablePlus = 4100, // 数字4 启用加法
    SSMathNumberDescription4EnableMinus = 4101, // 数字4 启用减法
};

@interface SSMathConfiguration : NSObject

@property (nonatomic, class, readonly) SSMathConfiguration *shared;

- (void)setObject:(id)object forFeature:(SSMathFeature)feature;

- (NSString *)objectForFeature:(SSMathFeature)feature;

- (NSInteger)integerForFeature:(SSMathFeature)feature;

- (BOOL)boolForFeature:(SSMathFeature)feature;

@end