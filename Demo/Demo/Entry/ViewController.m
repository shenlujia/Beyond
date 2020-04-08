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

    [self test:@"Controller生命周期"
           setup:nil
        callback:^(UIButton *button) {
            UIViewController *c = [[NSClassFromString(@"ControllerLifeCycleParentController") alloc] init];
            [weak_self.navigationController pushViewController:c animated:YES];
        }];

    [self test:@"关联对象"
           setup:nil
        callback:^(UIButton *button) {
            UIViewController *c = [[NSClassFromString(@"AssociatedObjectController") alloc] init];
            [weak_self.navigationController pushViewController:c animated:YES];
        }];
}

@end
