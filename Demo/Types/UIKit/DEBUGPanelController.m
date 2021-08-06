//
//  DEBUGPanelController.m
//  Beyond
//
//  Created by ZZZ on 2021/7/31.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "DEBUGPanelController.h"
#import "Logger.h"
#import "SSDEBUGViewPanel.h"
#import "SSDEBUGTextViewController.h"

@interface DEBUGPanelController ()

@property (nonatomic, strong) SSDEBUGViewPanel *panel;

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
    [self test:@"左上 空" tap:^(UIButton *button, NSDictionary *userInfo) {
        weak_s.panel = [weak_s createEmptyPanel];
        [weak_s.panel showInView:view startPoint:CGPointMake(0, 0)];
    }];
    [self test:@"左上 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view startPoint:CGPointMake(0, 0)];
    }];
    [self test:@"右上 空" tap:^(UIButton *button, NSDictionary *userInfo) {
        weak_s.panel = [weak_s createEmptyPanel];
        [weak_s.panel showInView:view startPoint:CGPointMake(size.width, 0)];
    }];
    [self test:@"右上 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view startPoint:CGPointMake(size.width, 0)];
    }];
    [self test:@"右中 空" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createEmptyPanel];
        [weak_s.panel showInView:view startPoint:CGPointMake(size.width, size.height / 2)];
    }];
    [self test:@"右中 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view startPoint:CGPointMake(size.width, size.height / 2)];
    }];
    [self test:@"左下 空" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createEmptyPanel];
        [weak_s.panel showInView:view startPoint:CGPointMake(0, size.height)];
    }];
    [self test:@"左下 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view startPoint:CGPointMake(0, size.height)];
    }];
    [self test:@"右下 空" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createEmptyPanel];
        [weak_s.panel showInView:view startPoint:CGPointMake(size.width, size.height)];
    }];
    [self test:@"右下 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view startPoint:CGPointMake(size.width, size.height)];
    }];
    
    [self test:@"不指定point 满" tap:^(UIButton *button, NSDictionary *userInfo) {
        UIView *view = weak_s.view;
        weak_s.panel = [weak_s createNormalPanel];
        [weak_s.panel showInView:view];
    }];

    [self test:@"DEBUGTextView xxx" tap:^(UIButton *button, NSDictionary *userInfo) {
        [SSDEBUGTextViewController showText:@"xxx"];
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

        [SSDEBUGTextViewController showJSONObject:h];
    }];
}

- (SSDEBUGViewPanel *)createEmptyPanel
{
    SSDEBUGViewPanel *panel = [[SSDEBUGViewPanel alloc] init];
    return panel;
}

- (SSDEBUGViewPanel *)createNormalPanel
{
    SSDEBUGViewPanel *panel = [[SSDEBUGViewPanel alloc] init];
    for (NSInteger idx = 1; idx <= 20; ++idx) {
        NSString *title = @(idx).stringValue;
        [panel test:title action:^{
            NSLog(title);
        }];
    }
    return panel;
}

@end
