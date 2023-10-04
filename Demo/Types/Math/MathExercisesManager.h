//
//  MathExercisesManager.h
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
    
    SSMathEnableCarry = 100, // 开启进位
    SSMathEnableNegative = 101, // 开启负数
    
    SSMathNumberDescription1EnableDigit1 = 1001, // 数字1 启用一位数
    SSMathNumberDescription1EnableDigit2 = 1002, // 数字1 启用二位数
    SSMathNumberDescription1EnableDigit3 = 1003, // 数字1 启用三位数
    
    SSMathNumberDescription2EnableDigit1 = 2001, // 数字2 启用一位数
    SSMathNumberDescription2EnableDigit2 = 2002, // 数字2 启用二位数
    SSMathNumberDescription2EnableDigit3 = 2003, // 数字2 启用三位数
    SSMathNumberDescription2EnablePlus = 2100, // 数字2 启用加法
    SSMathNumberDescription2EnableMinus = 2101, // 数字2 启用减法
    
    SSMathNumberDescription3Enable = 3000, // 启用数字3
    SSMathNumberDescription3EnableDigit1 = 3001, // 数字3 启用一位数
    SSMathNumberDescription3EnableDigit2 = 3002, // 数字3 启用二位数
    SSMathNumberDescription3EnableDigit3 = 3003, // 数字3 启用三位数
    SSMathNumberDescription3EnablePlus = 3100, // 数字3 启用加法
    SSMathNumberDescription3EnableMinus = 3101, // 数字3 启用减法
    
    SSMathNumberDescription4Enable = 4000, // 启用数字4
    SSMathNumberDescription4EnableDigit1 = 4001, // 数字4 启用一位数
    SSMathNumberDescription4EnableDigit2 = 4002, // 数字4 启用二位数
    SSMathNumberDescription4EnableDigit3 = 4003, // 数字4 启用三位数
    SSMathNumberDescription4EnablePlus = 4100, // 数字4 启用加法
    SSMathNumberDescription4EnableMinus = 4101, // 数字4 启用减法
};

@interface MathExercisesManager : NSObject

@property (nonatomic, class, readonly) MathExercisesManager *manager;

- (void)setObject:(id)object forFeature:(SSMathFeature)feature;

- (NSString *)objectForFeature:(SSMathFeature)feature;

- (NSInteger)integerForFeature:(SSMathFeature)feature;

- (BOOL)boolForFeature:(SSMathFeature)feature;

@end
