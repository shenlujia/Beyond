//
//  AnimationController.m
//  Demo
//
//  Created by SLJ on 2020/5/7.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AnimationController.h"

static UIColor * kRandomColor()
{
    CGFloat r = (arc4random() % 256) / 255.0;
    CGFloat g = (arc4random() % 256) / 255.0;
    CGFloat b = (arc4random() % 256) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@interface AnimationController ()

@property (nonatomic, strong) UIButton *testView1;
@property (nonatomic, strong) UIButton *testView2;
@property (nonatomic, strong) CALayer *testLayer1;

@end

@implementation AnimationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WEAKSELF;
    
    self.testView1 = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, 64, 64)];
    [self.testView1 setTitle:@"点我1" forState:UIControlStateNormal];
    [self.view addSubview:self.testView1];
    self.testView1.backgroundColor = kRandomColor();
    [self.testView1 addTarget:self action:@selector(test1Action) forControlEvents:UIControlEventTouchUpInside];
    
    self.testView2 = [[UIButton alloc] initWithFrame:CGRectMake(20, 200, 64, 64)];
    [self.testView2 setTitle:@"点我2" forState:UIControlStateNormal];
    [self.view addSubview:self.testView2];
    self.testView2.backgroundColor = kRandomColor();
    [self.testView2 addTarget:self action:@selector(test2Action) forControlEvents:UIControlEventTouchUpInside];
    
    self.testLayer1 = [[CALayer alloc] init];
    self.testLayer1.frame = CGRectMake(0, 0, 32, 32);
    self.testLayer1.backgroundColor = kRandomColor().CGColor;
    [self.testView1.layer addSublayer:self.testLayer1];
    
    [self test:@"LayerColor" tap:^(UIButton *button) {
        
        NSLog(@"Step1 testView1: %@", [self.testView1 actionForLayer:self.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step1 testLayer1: %@", [self.testView1 actionForLayer:self.testLayer1 forKey:@"backgroundColor"]);
        
        weak_self.testLayer1.backgroundColor = kRandomColor().CGColor;
        weak_self.testView1.layer.backgroundColor = kRandomColor().CGColor;
        
        NSLog(@"Step2 testView1: %@", [self.testView1 actionForLayer:self.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step2 testLayer1: %@", [self.testView1 actionForLayer:self.testLayer1 forKey:@"backgroundColor"]);
    }];
    
    [self test:@"CATransaction + LayerColor" tap:^(UIButton *button) {
        
        NSLog(@"Step1 testView1: %@", [self.testView1 actionForLayer:self.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step1 testLayer1: %@", [self.testView1 actionForLayer:self.testLayer1 forKey:@"backgroundColor"]);
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:2];
        
        NSLog(@"Step2 testView1: %@", [self.testView1 actionForLayer:self.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step2 testLayer1: %@", [self.testView1 actionForLayer:self.testLayer1 forKey:@"backgroundColor"]);
        
        weak_self.testLayer1.backgroundColor = kRandomColor().CGColor;
        weak_self.testView1.layer.backgroundColor = kRandomColor().CGColor;
        
        NSLog(@"Step3 testView1: %@", [self.testView1 actionForLayer:self.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step3 testLayer1: %@", [self.testView1 actionForLayer:self.testLayer1 forKey:@"backgroundColor"]);
        
        [CATransaction commit];
        
        NSLog(@"Step4 testView1: %@", [self.testView1 actionForLayer:self.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step4 testLayer1: %@", [self.testView1 actionForLayer:self.testLayer1 forKey:@"backgroundColor"]);
    }];
    
    [self test:@"animateWithDuration + LayerColor" tap:^(UIButton *button) {
        
        NSLog(@"Step1 testView1: %@", [self.testView1 actionForLayer:self.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step1 testLayer1: %@", [self.testView1 actionForLayer:self.testLayer1 forKey:@"backgroundColor"]);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        
        NSLog(@"Step2 testView1: %@", [self.testView1 actionForLayer:self.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step2 testLayer1: %@", [self.testView1 actionForLayer:self.testLayer1 forKey:@"backgroundColor"]);
        
        weak_self.testLayer1.backgroundColor = kRandomColor().CGColor;
        weak_self.testView1.layer.backgroundColor = kRandomColor().CGColor;
        
        NSLog(@"Step3 testView1: %@", [self.testView1 actionForLayer:self.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step3 testLayer1: %@", [self.testView1 actionForLayer:self.testLayer1 forKey:@"backgroundColor"]);
        
        [UIView commitAnimations];
        
        NSLog(@"Step4 testView1: %@", [self.testView1 actionForLayer:self.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step4 testLayer1: %@", [self.testView1 actionForLayer:self.testLayer1 forKey:@"backgroundColor"]);
    }];
    
    [self test:@"ViewColor" tap:^(UIButton *button) {
        weak_self.testView2.backgroundColor = kRandomColor();
    }];
    
    [self test:@"CATransaction + ViewColor" tap:^(UIButton *button) {
        
        NSLog(@"Step1: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"backgroundColor"]);
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:2];
        
        NSLog(@"Step2: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"backgroundColor"]);
        
        weak_self.testView2.backgroundColor = kRandomColor();
        
        NSLog(@"Step3: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"backgroundColor"]);
        
        [CATransaction commit];
        
        NSLog(@"Step4: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"backgroundColor"]);
    }];
    
    [self test:@"animateWithDuration + ViewColor" tap:^(UIButton *button) {
        
        NSLog(@"Step1: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"backgroundColor"]);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        
        NSLog(@"Step2: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"backgroundColor"]);
        
        weak_self.testView2.backgroundColor = kRandomColor();
        
        NSLog(@"Step3: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"backgroundColor"]);
        
        [UIView commitAnimations];
        
        NSLog(@"Step4: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"backgroundColor"]);
    }];
    
    [self test:@"断点后还会继续动画" tap:^(UIButton *button) {
        
        NSLog(@"Step1: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"transform"]);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:5];
        
        NSLog(@"Step2: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"transform"]);
        
        CGAffineTransform t = weak_self.testView2.transform;
        t = t.tx == 200 ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(200, 200);
        weak_self.testView2.transform = t;
        
        NSLog(@"Step3: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"transform"]);
        
        [UIView commitAnimations];
        
        NSLog(@"Step4: %@", [self.testView2 actionForLayer:self.testView2.layer forKey:@"transform"]);
    }];
    
    [self test:@"触摸响应位于动画末端" tap:^(UIButton *button) {
    }];
}

- (void)test1Action
{
    NSLog(@"test1Action");
}

- (void)test2Action
{
    NSLog(@"test2Action");
}

@end
