//
//  ViewController.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak typeof(self) weak_self = self;

    [self test:@"UIAppearance"
           set:nil
           tap:^(UIButton *button) {
               UIViewController *c = [[NSClassFromString(@"AppearanceController") alloc] init];
               [weak_self.navigationController pushViewController:c animated:YES];
           }];

    [self test:@"UIControl"
           set:nil
           tap:^(UIButton *button) {
               UIViewController *c = [[NSClassFromString(@"ControlController") alloc] init];
               [weak_self.navigationController pushViewController:c animated:YES];
           }];

    [self test:@"KVO"
           set:nil
           tap:^(UIButton *button) {
               UIViewController *c = [[NSClassFromString(@"KVOController") alloc] init];
               [weak_self.navigationController pushViewController:c animated:YES];
           }];

    [self test:@"GCD"
           set:nil
           tap:^(UIButton *button) {
               UIViewController *c = [[NSClassFromString(@"GCDController") alloc] init];
               [weak_self.navigationController pushViewController:c animated:YES];
           }];

    [self test:@"一些题目"
           set:nil
           tap:^(UIButton *button) {
               UIViewController *c = [[NSClassFromString(@"ExerciseController") alloc] init];
               [weak_self.navigationController pushViewController:c animated:YES];
           }];

    [self test:@"Block"
           set:nil
           tap:^(UIButton *button) {
               UIViewController *c = [[NSClassFromString(@"BlockController") alloc] init];
               [weak_self.navigationController pushViewController:c animated:YES];
           }];

    [self test:@"Controller生命周期"
           set:nil
           tap:^(UIButton *button) {
               UIViewController *c = [[NSClassFromString(@"ControllerLifeCycleParentController") alloc] init];
               [weak_self.navigationController pushViewController:c animated:YES];
           }];

    [self test:@"关联对象"
           set:nil
           tap:^(UIButton *button) {
               UIViewController *c = [[NSClassFromString(@"AssociatedObjectController") alloc] init];
               [weak_self.navigationController pushViewController:c animated:YES];
           }];
}

@end
