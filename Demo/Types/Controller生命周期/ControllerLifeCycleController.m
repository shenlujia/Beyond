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

    WEAKSELF

    [self test:@"push child" tap:^(UIButton *button, NSDictionary *userInfo) {
        ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
        [weak_s.navigationController pushViewController:c animated:YES];
    }];

    [self test:@"add child" tap:^(UIButton *button, NSDictionary *userInfo) {
        ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
        __weak ControllerLifeCycleChildController *weak_c = c;
        [weak_c test:@"remove child" tap:^(UIButton *button, NSDictionary *userInfo) {
            [weak_c removeFromParentViewController];
            [weak_c.view removeFromSuperview];
        }];

        [weak_s addChildViewController:c];
        [weak_s.view addSubview:c.view];
    }];

    [self test:@"present child" tap:^(UIButton *button, NSDictionary *userInfo) {
        // iOS13+ UIModalPresentationAutomatic
        // iOS12- UIModalPresentationFullScreen
        ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
        __weak ControllerLifeCycleChildController *weak_c = c;
        [weak_c test:@"dismiss child" tap:^(UIButton *button, NSDictionary *userInfo) {
            [weak_c dismissViewControllerAnimated:YES completion:nil];
        }];
        [weak_s presentViewController:c animated:YES completion:nil];
    }];
    
    [self test:@"present child" tap:^(UIButton *button, NSDictionary *userInfo) {
        ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
        c.modalPresentationStyle = UIModalPresentationFullScreen;
        __weak ControllerLifeCycleChildController *weak_c = c;
        [weak_c test:@"dismiss child" tap:^(UIButton *button, NSDictionary *userInfo) {
            [weak_c dismissViewControllerAnimated:YES completion:nil];
        }];
        [weak_s presentViewController:c animated:YES completion:nil];
    }];
    
    [self test:@"present child" tap:^(UIButton *button, NSDictionary *userInfo) {
        ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
        c.modalPresentationStyle = UIModalPresentationOverFullScreen;
        __weak ControllerLifeCycleChildController *weak_c = c;
        [weak_c test:@"dismiss child" tap:^(UIButton *button, NSDictionary *userInfo) {
            [weak_c dismissViewControllerAnimated:YES completion:nil];
        }];
        [weak_s presentViewController:c animated:YES completion:nil];
    }];
    
    [self test:@"present child" tap:^(UIButton *button, NSDictionary *userInfo) {
        ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
        c.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        __weak ControllerLifeCycleChildController *weak_c = c;
        [weak_c test:@"dismiss child" tap:^(UIButton *button, NSDictionary *userInfo) {
            [weak_c dismissViewControllerAnimated:YES completion:nil];
        }];
        [weak_s presentViewController:c animated:YES completion:nil];
    }];
}

@end
