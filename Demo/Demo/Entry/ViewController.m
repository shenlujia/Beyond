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

    [self test:@"使dispatch_once不执行"
           set:nil
           tap:^(UIButton *button) {
               static dispatch_once_t onceToken = ~0l;
               dispatch_once(&onceToken, ^{
                   // 不会调用
                   NSParameterAssert(0);
                   NSLog(@"onceToken设为-1后 内部判定已经执行过不会再调用");
               });
           }];
}

@end
