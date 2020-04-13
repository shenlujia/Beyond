//
//  ControllerLifeCycleController.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ControllerLifeCycleController.h"

@implementation ControllerLifeCycleController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear: %@", self.title);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear: %@", self.title);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear: %@", self.title);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear: %@", self.title);
}

@end

@interface ControllerLifeCycleChildController : ControllerLifeCycleController

@end

@implementation ControllerLifeCycleChildController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.brownColor;
    self.title = @"child";
}

@end

@interface ControllerLifeCycleParentController ()

@end

@implementation ControllerLifeCycleParentController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"parent";

    __weak typeof(self) weak_self = self;

    [self test:@"push child"
           set:nil
           tap:^(UIButton *button) {
               ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
               [weak_self.navigationController pushViewController:c animated:YES];
           }];

    [self test:@"add child"
           set:nil
           tap:^(UIButton *button) {
               ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
               __weak ControllerLifeCycleChildController *weak_c = c;
               [weak_c test:@"remove child"
                        set:nil
                        tap:^(UIButton *button) {
                            [weak_c removeFromParentViewController];
                            [weak_c.view removeFromSuperview];
                        }];

               [weak_self addChildViewController:c];
               [weak_self.view addSubview:c.view];
           }];

    [self test:@"present child"
           set:nil
           tap:^(UIButton *button) {
               ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
               __weak ControllerLifeCycleChildController *weak_c = c;
               [weak_c test:@"dismiss child"
                        set:nil
                        tap:^(UIButton *button) {
                            [weak_c dismissViewControllerAnimated:YES completion:nil];
                        }];
               [weak_self presentViewController:c animated:YES completion:nil];
           }];
}

@end
