//
//  DEBUGPanelController.m
//  Beyond
//
//  Created by ZZZ on 2021/7/31.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "DEBUGPanelController.h"
#import "Logger.h"
#import "SSViewDEBUGPanel.h"

@interface DEBUGPanelController ()

@property (nonatomic, strong) SSViewDEBUGPanel *panel;

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
}

- (SSViewDEBUGPanel *)createEmptyPanel
{
    SSViewDEBUGPanel *panel = [[SSViewDEBUGPanel alloc] init];
    return panel;
}

- (SSViewDEBUGPanel *)createNormalPanel
{
    SSViewDEBUGPanel *panel = [[SSViewDEBUGPanel alloc] init];
    for (NSInteger idx = 1; idx <= 20; ++idx) {
        NSString *title = @(idx).stringValue;
        [panel test:title action:^{
            NSLog(title);
        }];
    }
    return panel;
}

@end
