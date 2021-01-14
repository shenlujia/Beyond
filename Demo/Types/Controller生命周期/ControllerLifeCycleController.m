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

    [self test:@"present child 1" tap:^(UIButton *button, NSDictionary *userInfo) {
        // iOS13+ UIModalPresentationAutomatic
        // iOS12- UIModalPresentationFullScreen
        ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
        __weak ControllerLifeCycleChildController *weak_c = c;
        [weak_c test:@"dismiss child" tap:^(UIButton *button, NSDictionary *userInfo) {
            [weak_c dismissViewControllerAnimated:YES completion:nil];
        }];
        [weak_s presentViewController:c animated:YES completion:nil];
    }];
    
    [self test:@"present child 2" tap:^(UIButton *button, NSDictionary *userInfo) {
        ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
        c.modalPresentationStyle = UIModalPresentationFullScreen;
        __weak ControllerLifeCycleChildController *weak_c = c;
        [weak_c test:@"dismiss child" tap:^(UIButton *button, NSDictionary *userInfo) {
            [weak_c dismissViewControllerAnimated:YES completion:nil];
        }];
        [weak_s presentViewController:c animated:YES completion:nil];
    }];
    
    [self test:@"present child 3" tap:^(UIButton *button, NSDictionary *userInfo) {
        ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
        c.modalPresentationStyle = UIModalPresentationOverFullScreen;
        __weak ControllerLifeCycleChildController *weak_c = c;
        [weak_c test:@"dismiss child" tap:^(UIButton *button, NSDictionary *userInfo) {
            [weak_c dismissViewControllerAnimated:YES completion:nil];
        }];
        [weak_s presentViewController:c animated:YES completion:nil];
    }];
    
    [self test:@"present child 4" tap:^(UIButton *button, NSDictionary *userInfo) {
        ControllerLifeCycleChildController *c = [[ControllerLifeCycleChildController alloc] init];
        c.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        __weak ControllerLifeCycleChildController *weak_c = c;
        [weak_c test:@"dismiss child" tap:^(UIButton *button, NSDictionary *userInfo) {
            [weak_c dismissViewControllerAnimated:YES completion:nil];
        }];
        [weak_s presentViewController:c animated:YES completion:nil];
    }];

    [self test:@"present present dismiss to current" tap:^(UIButton *button, NSDictionary *userInfo) {
        ControllerLifeCycleChildController *c1 = [[ControllerLifeCycleChildController alloc] init];
        c1.modalPresentationStyle = UIModalPresentationFullScreen;
        __weak ControllerLifeCycleChildController *weak_c1 = c1;
        [weak_c1 test:@"gogogo add" tap:^(UIButton *button, NSDictionary *userInfo) {
            ControllerLifeCycleChildController *c2 = [[ControllerLifeCycleChildController alloc] init];
            c2.modalPresentationStyle = UIModalPresentationFullScreen;
            __weak ControllerLifeCycleChildController *weak_c2 = c2;
            [weak_c2 test:@"dismiss to upup" tap:^(UIButton *button, NSDictionary *userInfo) {
                [weak_s dismissViewControllerAnimated:YES completion:nil];
            }];
            [weak_c1 presentViewController:c2 animated:YES completion:nil];
        }];
        [weak_s presentViewController:c1 animated:YES completion:nil];
    }];
}

@end
