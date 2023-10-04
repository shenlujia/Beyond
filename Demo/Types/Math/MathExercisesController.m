//
//  MathExercisesController.m
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import "MathExercisesController.h"
#import "MathExercisesManager.h"
#import "SSEasyAlert.h"
#import "UISwitch+SSUIKit.h"
#import "MathExercisesGenerator.h"

@interface MathExercisesController ()

@end

@implementation MathExercisesController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)];
    self.navigationItem.rightBarButtonItem = item;
    
    MathExercisesManager *manager = [MathExercisesManager manager];
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"math_init"] == NO) {
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"math_init"];
        
        [manager setObject:@"80" forFeature:SSMathLineLength];
        [manager setObject:@"46" forFeature:SSMathNumberDescriptionOfLines];
        [manager setObject:@"3" forFeature:SSMathExercisesCountInLine];
        [manager setObject:@"0" forFeature:SSMathExercisesStart];
        [manager setObject:@"10" forFeature:SSMathExercisesPadding];
        
        [manager setObject:@"0" forFeature:SSMathEnableCarry];
        [manager setObject:@"0" forFeature:SSMathEnableNegative];
        
        [manager setObject:@"1" forFeature:SSMathNumberDescription1EnableDigit1];
        
        [manager setObject:@"1" forFeature:SSMathNumberDescription2EnableDigit1];
        [manager setObject:@"1" forFeature:SSMathNumberDescription2EnablePlus];
        
        [manager setObject:@"0" forFeature:SSMathNumberDescription3Enable];
        [manager setObject:@"1" forFeature:SSMathNumberDescription3EnableDigit1];
        [manager setObject:@"1" forFeature:SSMathNumberDescription3EnablePlus];
        
        [manager setObject:@"0" forFeature:SSMathNumberDescription4Enable];
        [manager setObject:@"1" forFeature:SSMathNumberDescription4EnableDigit1];
        [manager setObject:@"1" forFeature:SSMathNumberDescription4EnablePlus];
    }
    
    self.title = @"习题";
    
    [self p_test_input:@"单行长度" feature:SSMathLineLength];
    [self p_test_input:@"行数" feature:SSMathNumberDescriptionOfLines];
    [self p_test_input:@"每行题目数" feature:SSMathExercisesCountInLine];
    [self p_test_input:@"题目开始位置" feature:SSMathExercisesStart];
    [self p_test_input:@"题目间隔" feature:SSMathExercisesPadding];
    
    [self p_test_switch:@"开启进位 开启后固定为两个数字进位加减法" feature:SSMathEnableCarry];
    [self p_test_switch:@"启用负数" feature:SSMathEnableNegative];
    
    [self p_test_switch:@"数字1 启用一位数" feature:SSMathNumberDescription1EnableDigit1];
    [self p_test_switch:@"数字2 启用二位数" feature:SSMathNumberDescription1EnableDigit2];
    [self p_test_switch:@"数字3 启用三位数" feature:SSMathNumberDescription1EnableDigit3];
    
    [self p_test_switch:@"数字2 启用一位数" feature:SSMathNumberDescription2EnableDigit1];
    [self p_test_switch:@"数字2 启用二位数" feature:SSMathNumberDescription2EnableDigit2];
    [self p_test_switch:@"数字2 启用三位数" feature:SSMathNumberDescription2EnableDigit3];
    [self p_test_switch:@"数字2 启用加法" feature:SSMathNumberDescription2EnablePlus];
    [self p_test_switch:@"数字2 启用减法" feature:SSMathNumberDescription2EnableMinus];
    
    [self p_test_switch:@"开启数字3" feature:SSMathNumberDescription3Enable];
    [self p_test_switch:@"数字3 启用一位数" feature:SSMathNumberDescription3EnableDigit1];
    [self p_test_switch:@"数字3 启用二位数" feature:SSMathNumberDescription3EnableDigit2];
    [self p_test_switch:@"数字3 启用三位数" feature:SSMathNumberDescription3EnableDigit3];
    [self p_test_switch:@"数字3 启用加法" feature:SSMathNumberDescription3EnablePlus];
    [self p_test_switch:@"数字3 启用减法" feature:SSMathNumberDescription3EnableMinus];
    
    [self p_test_switch:@"开启数字4" feature:SSMathNumberDescription4Enable];
    [self p_test_switch:@"数字4 启用一位数" feature:SSMathNumberDescription4EnableDigit1];
    [self p_test_switch:@"数字4 启用二位数" feature:SSMathNumberDescription4EnableDigit2];
    [self p_test_switch:@"数字4 启用三位数" feature:SSMathNumberDescription4EnableDigit3];
    [self p_test_switch:@"数字4 启用加法" feature:SSMathNumberDescription4EnablePlus];
    [self p_test_switch:@"数字4 启用减法" feature:SSMathNumberDescription4EnableMinus];
}

#pragma mark - action

- (void)switchAction:(UISwitch *)s
{
    NSString *value  = s.on ? @"1" : @"0";
    [[MathExercisesManager manager] setObject:value forFeature:s.tag];
}

- (void)shareAction
{
    NSString *text = [MathExercisesGenerator generate];
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentPath stringByAppendingPathComponent:@"share.txt"];
    [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *activityItems = @[[NSURL fileURLWithPath:path]];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    controller.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
    };
    
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

#pragma mark - private

- (void)p_test_input:(NSString *)title feature:(SSMathFeature)feature
{
    MathExercisesManager *manager = [MathExercisesManager manager];
    [self test:@"" set:^(UIButton *button, NSDictionary *userInfo) {
        NSString *value = [manager objectForFeature:feature];
        [button setTitle:[NSString stringWithFormat:@"%@: %@", title, value] forState:UIControlStateNormal];
    } tap:^(UIButton *button, NSDictionary *userInfo) {
        ss_easy_alert(^(SSEasyAlertConfiguration *configuration) {
            configuration.title = title;
            [configuration addTextFieldWithHandler:^(UITextField *textField) {
                textField.placeholder = [manager objectForFeature:feature];
            }];
            [configuration addAction:@"确定" handler:^(UIAlertController *alert) {
                NSString *text = alert.textFields.firstObject.text;
                [manager setObject:text forFeature:feature];
                NSString *value = [manager objectForFeature:feature];
                [button setTitle:[NSString stringWithFormat:@"%@: %@", title, value] forState:UIControlStateNormal];
            }];
        });
    }];
}

- (void)p_test_switch:(NSString *)title feature:(SSMathFeature)feature
{
    MathExercisesManager *manager = [MathExercisesManager manager];
    [self test:title set:^(UIButton *button, NSDictionary *userInfo) {
        UISwitch *s = [[UISwitch alloc] init];
        s.frame = ({
            CGSize maxSize = button.bounds.size;
            CGSize size = s.frame.size;
//            size.width = MAX(size.width, 51);
//            size.height = MAX(size.height, 31);
            CGRectMake(maxSize.width - size.width - 35, (maxSize.height - size.height) / 2, size.width, size.height);
        });
        [button addSubview:s];
        s.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        NSString *value = [manager objectForFeature:feature];
        s.on = value.boolValue;
        s.tag = feature;
        [s addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    } tap:^(UIButton *button, NSDictionary *userInfo) {
        
    }];
}

@end
