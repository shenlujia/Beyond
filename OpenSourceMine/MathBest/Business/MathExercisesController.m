//
//  MathExercisesController.m
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import "MathExercisesController.h"
#import "SSMathConfiguration.h"
#import "SSEasyAlert.h"
#import "MathExercisesGenerator.h"

@interface MathExercisesController ()

@end

@implementation MathExercisesController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"随机生成" style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
    self.navigationItem.rightBarButtonItem = item;
    
    SSMathConfiguration *configuration = [SSMathConfiguration shared];
    if ([NSUserDefaults.standardUserDefaults boolForKey:@"math_init"] == NO) {
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"math_init"];
        
        [configuration setObject:@"80" forFeature:SSMathLineLength];
        [configuration setObject:@"46" forFeature:SSMathNumberDescriptionOfLines];
        [configuration setObject:@"3" forFeature:SSMathExercisesCountInLine];
        [configuration setObject:@"0" forFeature:SSMathExercisesStart];
        [configuration setObject:@"10" forFeature:SSMathExercisesPadding];
        
        [configuration setObject:@"0" forFeature:SSMathEnableCarry10];
        [configuration setObject:@"0" forFeature:SSMathEnableCarry20];
        [configuration setObject:@"0" forFeature:SSMathEnableNegative];
        
        [configuration setObject:@"1" forFeature:SSMathNumberDescription1EnableDigit1];
        
        [configuration setObject:@"1" forFeature:SSMathNumberDescription2EnableDigit1];
        [configuration setObject:@"1" forFeature:SSMathNumberDescription2EnablePlus];
    }
    
    self.title = @"习题";
    
    {
        [self p_test_hint:@"基础参数"];
        
        [self p_test_input:@"单行长度" feature:SSMathLineLength];
        [self p_test_input:@"行数" feature:SSMathNumberDescriptionOfLines];
        [self p_test_input:@"每行题目数" feature:SSMathExercisesCountInLine];
        [self p_test_input:@"题目开始位置" feature:SSMathExercisesStart];
        [self p_test_input:@"题目间隔" feature:SSMathExercisesPadding];
        
        [self p_test_switch:@"启用负数" feature:SSMathEnableNegative];
        [self p_test_switch:@"至少有一次进位或退位" feature:SSMathCarryMoreThanOnce];
    }
    
    {
        [self p_test_hint:@"快捷模式"];
        
        [self p_test_switch:@"快捷模式 固定(0~10)两个数字进位退位加减法" feature:SSMathEnableCarry10];
        [self p_test_switch:@"快捷模式 固定(0~20)两个数字进位退位加减法" feature:SSMathEnableCarry20];
    }
    
    {
        [self p_test_hint:@"数字参数 快捷模式打开时此处参数无效"];
        
        [self p_test_switch:@"数字1 启用一位数" feature:SSMathNumberDescription1EnableDigit1];
        [self p_test_switch:@"数字1 启用二位数" feature:SSMathNumberDescription1EnableDigit2];
        [self p_test_switch:@"数字1 启用三位数" feature:SSMathNumberDescription1EnableDigit3];
        
        [self p_test_switch:@"数字2 启用一位数" feature:SSMathNumberDescription2EnableDigit1];
        [self p_test_switch:@"数字2 启用二位数" feature:SSMathNumberDescription2EnableDigit2];
        [self p_test_switch:@"数字2 启用三位数" feature:SSMathNumberDescription2EnableDigit3];
        [self p_test_switch:@"数字2 启用加法" feature:SSMathNumberDescription2EnablePlus];
        [self p_test_switch:@"数字2 启用减法" feature:SSMathNumberDescription2EnableMinus];
        
        [self p_test_switch:@"数字3 启用一位数" feature:SSMathNumberDescription3EnableDigit1];
        [self p_test_switch:@"数字3 启用二位数" feature:SSMathNumberDescription3EnableDigit2];
        [self p_test_switch:@"数字3 启用三位数" feature:SSMathNumberDescription3EnableDigit3];
        [self p_test_switch:@"数字3 启用加法" feature:SSMathNumberDescription3EnablePlus];
        [self p_test_switch:@"数字3 启用减法" feature:SSMathNumberDescription3EnableMinus];
        
        [self p_test_switch:@"数字4 启用一位数" feature:SSMathNumberDescription4EnableDigit1];
        [self p_test_switch:@"数字4 启用二位数" feature:SSMathNumberDescription4EnableDigit2];
        [self p_test_switch:@"数字4 启用三位数" feature:SSMathNumberDescription4EnableDigit3];
        [self p_test_switch:@"数字4 启用加法" feature:SSMathNumberDescription4EnablePlus];
        [self p_test_switch:@"数字4 启用减法" feature:SSMathNumberDescription4EnableMinus];
    }
}

#pragma mark - action

- (void)switchAction:(UISwitch *)s
{
    NSString *value  = s.on ? @"1" : @"0";
    [[SSMathConfiguration shared] setObject:value forFeature:s.tag];
}

- (void)shareAction
{
    NSString *text = [MathExercisesGenerator generate];
    NSLog(@"%@", text);
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentPath stringByAppendingPathComponent:@"题目.txt"];
    [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *activityItems = @[[NSURL fileURLWithPath:path]];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    controller.completionWithItemsHandler = ^(UIActivityType activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
    };
    
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

#pragma mark - private

- (void)p_test_hint:(NSString *)title
{
    [self test:title set:^(UIButton *button, NSDictionary *userInfo) {
        button.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.1];
    } tap:^(UIButton *button, NSDictionary *userInfo) {
        
    }];
}

- (void)p_test_input:(NSString *)title feature:(SSMathFeature)feature
{
    SSMathConfiguration *mathConfiguration = [SSMathConfiguration shared];
    [self test:@"" set:^(UIButton *button, NSDictionary *userInfo) {
        NSString *value = [mathConfiguration objectForFeature:feature];
        [button setTitle:[NSString stringWithFormat:@"%@: %@", title, value] forState:UIControlStateNormal];
    } tap:^(UIButton *button, NSDictionary *userInfo) {
        ss_easy_alert(^(SSEasyAlertConfiguration *configuration) {
            configuration.title = title;
            [configuration addTextFieldWithHandler:^(UITextField *textField) {
                textField.placeholder = [mathConfiguration objectForFeature:feature];
            }];
            [configuration addAction:@"确定" handler:^(UIAlertController *alert) {
                NSString *text = alert.textFields.firstObject.text;
                [mathConfiguration setObject:text forFeature:feature];
                NSString *value = [mathConfiguration objectForFeature:feature];
                [button setTitle:[NSString stringWithFormat:@"%@: %@", title, value] forState:UIControlStateNormal];
            }];
        });
    }];
}

- (void)p_test_switch:(NSString *)title feature:(SSMathFeature)feature
{
    SSMathConfiguration *configuration = [SSMathConfiguration shared];
    __block UISwitch *blockSwitch = nil;
    [self test:@"" set:^(UIButton *button, NSDictionary *userInfo) {
        UILabel *label = [[UILabel alloc] initWithFrame:button.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.text = [NSString stringWithFormat:@"    %@", title];
        label.textColor = [button titleColorForState:UIControlStateNormal];
        label.font = button.titleLabel.font;
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = UIColor.clearColor;
        [button addSubview:label];
        
        UISwitch *s = [[UISwitch alloc] init];
        s.frame = ({
            CGSize maxSize = button.bounds.size;
            CGSize size = s.frame.size;
            CGRectMake(maxSize.width - size.width - 15, (maxSize.height - size.height) / 2, size.width, size.height);
        });
        [button addSubview:s];
        s.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        s.on = [configuration boolForFeature:feature];
        s.tag = feature;
        [s addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        blockSwitch = s;
    } tap:^(UIButton *button, NSDictionary *userInfo) {
        if (blockSwitch) {
            [blockSwitch setOn:!blockSwitch.on animated:YES];
            NSString *value = blockSwitch.on ? @"1" : @"0";
            [[SSMathConfiguration shared] setObject:value forFeature:blockSwitch.tag];
        }
    }];
}

@end
