//
//  ViewController.m
//  Demo
//
//  Created by shenlujia on 2018/5/16.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import "ViewController.h"
#import <TFAppearance/TFAppearance.h>
#import <TFViewDecorator/TFViewDecorator.h>
#import "HSViewDebugger.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [HSViewDebugger install];
    });
    
    [super viewDidLoad];
   
    [self test_button];
    [self test_cell];
    [self test_color_type];
    [self test_font];
    [self test_color];
    [self test_text];
    
    self.navigationItem.rightBarButtonItem = ({
        [[UIBarButtonItem alloc] initWithTitle:@"换肤"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(changeAction)];
    });
}

- (void)test_color_type
{
    TFAppearance.color.theme.backgroundType.decorate([self p_clearCase:@"color_type backgroundType"]);
    
    TFAppearance.color.theme.textType.decorate([self p_normalCase:@"color_type textType"]);
    
    TFAppearance.color.theme.borderType.decorate(({
        UIButton *button = [self p_clearCase:@"color_type borderType"];
        button.tf_decorator.borderWidth = 5;
        button;
    }));
    
    TFAppearance.color.theme.shadowType.decorate(({
        UIButton *button = [self p_normalCase:@"color_type shadowType"];
        button.tf_decorator.shadowOffset = CGSizeMake(0, 5);
        button;
    }));
}

- (void)test_cell
{
    TFAppearance.cell.normal.backgroundColor.backgroundType.decorate([self p_clearCase:@"cell.normal backgroundColor"]);
    TFAppearance.cell.normal.highlightedBackgroundColor.backgroundType.decorate([self p_clearCase:@"cell.normal highlightedBackgroundColor"]);
    TFAppearance.cell.normal.selectedBackgroundColor.backgroundType.decorate([self p_clearCase:@"cell.normal selectedBackgroundColor"]);
}

- (void)test_font
{
    TFAppearance.font.size16.decorate([self p_normalCase:@"font 123456 普通"]);
    
    TFAppearance.font.size16.bold(YES).decorate([self p_normalCase:@"font 123456 加粗"]);
    
    TFAppearance.font.size8.size(16).name(@"Oswald-SemiBold").decorate([self p_normalCase:@"font 123456 自定义字体"]);
    
    TFAppearance.font.size8.size(38).decorate([self p_normalCase:@"font 123456 很大"]);
    
    TFAppearance.font.size(38).bold(YES).name(@"Oswald-SemiBold").decorate([self p_normalCase:@"font 123456 组合"]);
}

- (void)test_color
{
    TFAppearance.color.theme.backgroundType.decorate([self p_clearCase:@"color theme"]);
    TFAppearance.color.theme.alpha(0.8).backgroundType.decorate([self p_clearCase:@"color theme alpha = 0.75"]);
    TFAppearance.color.theme.alpha(0.1).alpha(0.5).backgroundType.decorate([self p_clearCase:@"color theme alpha = 0.5"]);
    TFAppearance.color.lightTheme.backgroundType.decorate([self p_clearCase:@"color lightTheme"]);
    TFAppearance.color.contrast.backgroundType.decorate([self p_clearCase:@"color contrast"]);
    TFAppearance.color.contrast.alpha(0.8).backgroundType.decorate([self p_clearCase:@"color contrast alpha = 0.8"]);

    TFAppearance.color.white.backgroundType.decorate([self p_clearCase:@"color white"]);
    TFAppearance.color.black.backgroundType.decorate([self p_clearCase:@"color black"]);

    TFAppearance.color.darkText.backgroundType.decorate([self p_clearCase:@"color darkText"]);
    TFAppearance.color.lightText1.backgroundType.decorate([self p_clearCase:@"color lightText1"]);
    TFAppearance.color.lightText2.backgroundType.decorate([self p_clearCase:@"color lightText2"]);
    TFAppearance.color.lightText3.backgroundType.decorate([self p_clearCase:@"color lightText3"]);

    TFAppearance.color.line.backgroundType.decorate([self p_clearCase:@"color line"]);
}

- (void)test_button
{
    TFAppearance.button.normalStyle.decorate(({
        UIButton *button = [self addCaseWithTitle:@"button 普通 1秒disabled" block:^(UIButton *button) {
            button.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                button.enabled = YES;
            });
        }];
        button.backgroundColor = nil;
        button.tf_decorator.cornerRadius = 5;
        button;
    }));
    
    TFAppearance.button.lightStyle.decorate(({
        UIButton *button = [self addCaseWithTitle:@"button 浅色 1秒disabled" block:^(UIButton *button) {
            button.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                button.enabled = YES;
            });
        }];
        button.backgroundColor = nil;
        button.tf_decorator.cornerRadius = 5;
        button;
    }));
    
    TFAppearance.button.hollowStyle.decorate(({
        UIButton *button = [self addCaseWithTitle:@"button 中空 1秒disabled" block:^(UIButton *button) {
            button.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                button.enabled = YES;
            });
        }];
        button.backgroundColor = nil;
        button.tf_decorator.cornerRadius = 5;
        button;
    }));
}

- (void)test_text
{
    TFAppearance.text.titleStyle.decorate([self addCaseWithTitle:@"text 主标题" block:nil]);
    TFAppearance.text.detailTitleStyle.decorate([self addCaseWithTitle:@"text 详情标题" block:nil]);
    TFAppearance.text.listTitleStyle.decorate([self addCaseWithTitle:@"text 列表标题" block:nil]);

    TFAppearance.text.bodyStyle.decorate([self addCaseWithTitle:@"text 正文" block:nil]);

    TFAppearance.text.other1Style.decorate([self addCaseWithTitle:@"text 其他1" block:nil]);
    TFAppearance.text.other2Style.decorate([self addCaseWithTitle:@"text 其他2" block:nil]);
    TFAppearance.text.other3Style.decorate([self addCaseWithTitle:@"text 其他3" block:nil]);
}

- (void)changeAction
{
    static NSArray *paths = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *array = [NSMutableArray array];
        NSString *test = [NSBundle.mainBundle pathForResource:@"appearance_test" ofType:@"json"];
        [array addObject:test];
        NSString *bundlePath = [NSBundle.mainBundle pathForResource:@"TFAppearance" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *defaultPath = [bundle pathForResource:@"appearance_default" ofType:@"json"];
        [array addObject:defaultPath];
        paths = [array copy];
    });
    
    static NSInteger index = 0;
    NSString *path = paths[index++ % paths.count];
    
    TFAppearance *appearance = [TFAppearance appearanceWithContentsOfFile:path];
    [appearance install];
}

- (UIButton *)p_normalCase:(NSString *)title
{
    return [self p_normalCase:title block:nil];
}

- (UIButton *)p_clearCase:(NSString *)title
{
    return [self p_clearCase:title block:nil];
}

- (UIButton *)p_normalCase:(NSString *)title block:(void (^)(UIButton *button))block
{
    return [self addCaseWithTitle:title block:block];
}

- (UIButton *)p_clearCase:(NSString *)title block:(void (^)(UIButton *button))block
{
    UIButton *button = [self addCaseWithTitle:title block:block];
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    [button setBackgroundImage:nil forState:UIControlStateHighlighted];
    return button;
}

@end
