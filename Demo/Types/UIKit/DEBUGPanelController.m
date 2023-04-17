//
//  DEBUGPanelController.m
//  Beyond
//
//  Created by ZZZ on 2021/7/31.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "DEBUGPanelController.h"
#import "SSEasy.h"
#import "SSEasyPanel.h"
#import "SSDEBUGTextViewController.h"
#import "NSObject+SSJSON.h"

@interface DEBUGPanelController ()

@property (nonatomic, strong) SSEasyPanel *panel;

@end

@implementation DEBUGPanelController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self testImpl];
    }];
}

- (void)testImpl
{
    WEAKSELF
    UIView *view = weak_s.view;
    const CGSize size = view.bounds.size;
    [self test:@"dismiss" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s.panel dismiss];
    }];
    [self test:@"左上 空" tap:^(UIButton *button, NSDictionary *userInfo) {
        weak_s.panel = [weak_s createEmptyPanel];
        [weak_s.panel showInView:view center:CGPointMake(0, 0)];
    }];
    [self test:@"左上 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view center:CGPointMake(0, 0)];
    }];
    [self test:@"右上 空" tap:^(UIButton *button, NSDictionary *userInfo) {
        weak_s.panel = [weak_s createEmptyPanel];
        [weak_s.panel showInView:view center:CGPointMake(size.width, 0)];
    }];
    [self test:@"右上 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view center:CGPointMake(size.width, 0)];
    }];
    [self test:@"右中 空" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createEmptyPanel];
        [weak_s.panel showInView:view center:CGPointMake(size.width, size.height / 2)];
    }];
    [self test:@"右中 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view center:CGPointMake(size.width, size.height / 2)];
    }];
    [self test:@"左下 空" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createEmptyPanel];
        [weak_s.panel showInView:view center:CGPointMake(0, size.height)];
    }];
    [self test:@"左下 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view center:CGPointMake(0, size.height)];
    }];
    [self test:@"右下 空" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createEmptyPanel];
        [weak_s.panel showInView:view center:CGPointMake(size.width, size.height)];
    }];
    [self test:@"右下 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view center:CGPointMake(size.width, size.height)];
    }];
    
    [self test:@"不指定point 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view];
    }];
    
    [self test:@"isValidJSONObject" tap:^(UIButton *button, NSDictionary *userInfo) {
        {
            NSArray *array_no = @[
                @{@(1):@(2)},
                @{@(NAN):@(NAN)},
                @{@"":@(NAN)},
                @{@"":@(INFINITY)},
                @{@"":@(INFINITY)},
                @{@{@"1":@"2"}:@(2)},
            ];
            NSArray *array_yes = @[
                @{@"":@(2)},
                @{@"":@{@"1":@"2"}},
            ];
            for (NSObject *obj in array_no) {
                NSParameterAssert([NSJSONSerialization isValidJSONObject:obj] == NO);
                NSParameterAssert([NSJSONSerialization isValidJSONObject:[obj ss_JSON]] == YES);
            }
            for (NSObject *obj in array_yes) {
                NSParameterAssert([NSJSONSerialization isValidJSONObject:obj] == YES);
                NSParameterAssert([NSJSONSerialization isValidJSONObject:[obj ss_JSON]] == YES);
            }
        }
        PRINT_BLANK_LINE
    }];

    [self test:@"DEBUGTextView xxx" tap:^(UIButton *button, NSDictionary *userInfo) {
        [SSDEBUGTextViewController showText:@"xxx" inContainer:weak_s];
    }];

    [self test:@"DEBUGTextView JSON" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSDictionary *a = @{@"a1":@"a11",@"a2":@"a22",@"a3":@"a33"};
        NSDictionary *b = @{@"b1":@"b11",@"b2":@"b22",@"b3":@"b33"};
        NSDictionary *c = @{@"ccccccccccc1":[a copy],@"c2":@[@"1",@"2",@"3"]};
        NSDictionary *d = @{@"ddddddddddd1":[c copy], @"d2":[b copy]};
        NSDictionary *e = @{@"eeeeeeeeeee1":[d copy], @"e2":[c copy]};
        NSDictionary *f = @{@"fffffffffff1":[e copy], @"f2":[d copy]};
        NSDictionary *g = @{@"ggggggggggg1":[f copy], @"g2":[e copy]};
        NSDictionary *h = @{@"hhhhhhhhhhh1":[g copy], @"h2":[f copy], @"b":@"b1", @"a":@"a1"};

        NSString *text = [SSDEBUGTextViewController textWithJSONObject:h];
        [SSDEBUGTextViewController showText:text inContainer:weak_s];
    }];
}

- (SSEasyPanel *)createEmptyPanel
{
    SSEasyPanel *panel = [[SSEasyPanel alloc] init];
    return panel;
}

- (SSEasyPanel *)createNormalPanel
{
    SSEasyPanel *panel = [[SSEasyPanel alloc] init];
    for (NSInteger idx = 1; idx <= 25; ++idx) {
        NSString *title = @(idx).stringValue;
        [panel test:^(SSDEBUGPanelItem *item) {
            [item.button setTitle:title forState:UIControlStateNormal];
        } action:^(SSDEBUGPanelItem *item) {
            ss_easy_log_text(title);
        }];
    }
    return panel;
}

@end
