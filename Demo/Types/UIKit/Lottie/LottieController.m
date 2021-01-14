//
//  LottieController.m
//  Beyond
//
//  Created by ZZZ on 2021/1/13.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "LottieController.h"
#import <Lottie/LOTAnimationView.h>

@interface LottieController ()

@end

@implementation LottieController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self test:@"cover_title" tap:^(UIButton *button, NSDictionary *userInfo) {
        LOTAnimationView *view = [LOTAnimationView animationNamed:@"cover_title"];
        [self.view addSubview:view];
        view.frame = CGRectMake(100, 100, 100, 100);
        [view play];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view removeFromSuperview];
        });
    }];

    [self test:@"moments_plus_guide" tap:^(UIButton *button, NSDictionary *userInfo) {
        LOTAnimationView *view = [LOTAnimationView animationNamed:@"moments_plus_guide"];
        [self.view addSubview:view];
        view.frame = CGRectMake(100, 100, 100, 100);
        [view play];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view removeFromSuperview];
        });
    }];
}

@end
