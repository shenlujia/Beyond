//
//  GestureController.m
//  Demo
//
//  Created by SLJ on 2020/7/30.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "GestureController.h"
#import "SSEasy.h"

@interface GestureTestView : UIView

@property (nonatomic, copy) NSString *name;

@end

@implementation GestureTestView

- (void)setupLongPress
{
    UIGestureRecognizer *g = nil;
    g = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:g];
}

- (void)cleanup
{
    for (UIGestureRecognizer *g in [self.gestureRecognizers copy]) {
        [self removeGestureRecognizer:g];
    }
}

- (void)setupDoubleTap
{
    UITapGestureRecognizer *g = nil;
    g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    g.numberOfTapsRequired = 2;
    [self addGestureRecognizer:g];
}

- (void)setupTap
{
    UIGestureRecognizer *g = nil;
    g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:g];
}

- (void)longPress:(UILongPressGestureRecognizer *)g
{
    if (g.state == UIGestureRecognizerStateBegan) {
        NSLog(@"longPress Began: %@", self.name);
    } else if (g.state == UIGestureRecognizerStateEnded) {
        NSLog(@"longPress Ended: %@", self.name);
    }
}

- (void)tap:(UILongPressGestureRecognizer *)g
{
    if (g.state == UIGestureRecognizerStateBegan) {
        NSLog(@"tap Began: %@", self.name);
    } else if (g.state == UIGestureRecognizerStateEnded) {
        NSLog(@"tap Ended: %@", self.name);
    }
}

- (void)doubleTap:(UILongPressGestureRecognizer *)g
{
    if (g.state == UIGestureRecognizerStateBegan) {
        NSLog(@"doubleTap Began: %@", self.name);
    } else if (g.state == UIGestureRecognizerStateEnded) {
        NSLog(@"doubleTap Ended: %@", self.name);
    }
}

@end

@interface GestureController ()

@end

@implementation GestureController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WEAKSELF
    
    GestureTestView *bigView = [[GestureTestView alloc] initWithFrame:CGRectMake(64, 64, 200, 200)];
    bigView.backgroundColor = [UIColor.darkGrayColor colorWithAlphaComponent:0.5];
    bigView.name = @"bigView";
    [weak_s.view addSubview:bigView];
    
    GestureTestView *smallView = [[GestureTestView alloc] initWithFrame:CGRectMake(64, 64, 80, 80)];
    smallView.backgroundColor = [UIColor.brownColor colorWithAlphaComponent:0.5];
    smallView.name = @"smallView";
    
    [self test:@"兄弟 tap" tap:^(UIButton *button, NSDictionary *userInfo) {
        [bigView cleanup];
        [smallView cleanup];
        [bigView setupTap];
        [smallView setupTap];
        [weak_s.view addSubview:smallView];
    }];
    
    [self test:@"兄弟 longPress" tap:^(UIButton *button, NSDictionary *userInfo) {
        [bigView cleanup];
        [smallView cleanup];
        [bigView setupLongPress];
        [smallView setupLongPress];
        [weak_s.view addSubview:smallView];
    }];
    
    [self test:@"父子 tap" tap:^(UIButton *button, NSDictionary *userInfo) {
        [bigView cleanup];
        [smallView cleanup];
        [bigView setupTap];
        [smallView setupTap];
        [bigView addSubview:smallView];
    }];
    
    [self test:@"父子 longPress" tap:^(UIButton *button, NSDictionary *userInfo) {
        [bigView cleanup];
        [smallView cleanup];
        [bigView setupLongPress];
        [smallView setupLongPress];
        [bigView addSubview:smallView];
    }];
    
    [self test:@"兄弟 tap + longPress" tap:^(UIButton *button, NSDictionary *userInfo) {
        [bigView cleanup];
        [smallView cleanup];
        [bigView setupTap];
        [smallView setupTap];
        [bigView setupLongPress];
        [smallView setupLongPress];
        [weak_s.view addSubview:smallView];
    }];
    
    [self test:@"父子 tap + longPress" tap:^(UIButton *button, NSDictionary *userInfo) {
        [bigView cleanup];
        [smallView cleanup];
        [bigView setupTap];
        [smallView setupTap];
        [bigView setupLongPress];
        [smallView setupLongPress];
        [bigView addSubview:smallView];
    }];
    
    [self test:@"父tap + 子longPress" tap:^(UIButton *button, NSDictionary *userInfo) {
        [bigView cleanup];
        [smallView cleanup];
        [bigView setupTap];
        [smallView setupLongPress];
        [bigView addSubview:smallView];
    }];
    
    [self test:@"父子 doubleTap" tap:^(UIButton *button, NSDictionary *userInfo) {
        [bigView cleanup];
        [smallView cleanup];
        [bigView setupDoubleTap];
        [smallView setupDoubleTap];
        [bigView addSubview:smallView];
    }];
    
    [self test:@"tap + swipe" tap:^(UIButton *button, NSDictionary *userInfo) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [weak_s.view addGestureRecognizer:tap];
        UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeUp:)];
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        [weak_s.view addGestureRecognizer:swipeUp];
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeDown:)];
        swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
        [weak_s.view addGestureRecognizer:swipeDown];
    }];
}

- (void)didTap:(UITapGestureRecognizer *)tap
{
    ss_easy_log(@"didTap %@", @(tap.state));
}

- (void)didSwipeUp:(UISwipeGestureRecognizer *)swipe
{
    ss_easy_log(@"didSwipeUp %@", @(swipe.state));
}

- (void)didSwipeDown:(UISwipeGestureRecognizer *)swipe
{
    ss_easy_log(@"didSwipeDown %@", @(swipe.state));
}

@end
