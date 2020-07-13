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
    
    WEAKSELF
    
    [self add_navi_right_item:@"暂停" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s pauseAnimation:weak_s.testView1];
        [weak_s pauseAnimation:weak_s.testView2];
    }];
    
    [self add_navi_right_item:@"恢复" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s resumeAnimation:weak_s.testView1];
        [weak_s resumeAnimation:weak_s.testView2];
    }];
    
    /*
     隐式动画实现的背后体现了核心动画精心设计的许多机制。在layer的属性发生改变之后，会向它的代理方请求一个CAAction行为来完成后续的工作，系统允许代理方返回nil指针。一旦这么做，修改属性的工作最终移交给CATransaction处理，由修改的属性值决定是否自动生成一个CABasicAnimation。如果满足，此时隐式动画将被触发。
     */
    
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
    
    [weak_s test:@"LayerColor" tap:^(UIButton *button, NSDictionary *userInfo) {
        
        NSLog(@"Step1 testView1: %@", [weak_s.testView1 actionForLayer:weak_s.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step1 testLayer1: %@", [weak_s.testView1 actionForLayer:weak_s.testLayer1 forKey:@"backgroundColor"]);
        
        weak_s.testLayer1.backgroundColor = kRandomColor().CGColor;
        weak_s.testView1.layer.backgroundColor = kRandomColor().CGColor;
        
        NSLog(@"Step2 testView1: %@", [weak_s.testView1 actionForLayer:weak_s.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step2 testLayer1: %@", [weak_s.testView1 actionForLayer:weak_s.testLayer1 forKey:@"backgroundColor"]);
    }];
    
    [weak_s test:@"CATransaction + LayerColor" tap:^(UIButton *button, NSDictionary *userInfo) {
        
        NSLog(@"Step1 testView1: %@", [weak_s.testView1 actionForLayer:weak_s.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step1 testLayer1: %@", [weak_s.testView1 actionForLayer:weak_s.testLayer1 forKey:@"backgroundColor"]);
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:2];
        
        NSLog(@"Step2 testView1: %@", [weak_s.testView1 actionForLayer:weak_s.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step2 testLayer1: %@", [weak_s.testView1 actionForLayer:weak_s.testLayer1 forKey:@"backgroundColor"]);
        
        weak_s.testLayer1.backgroundColor = kRandomColor().CGColor;
        weak_s.testView1.layer.backgroundColor = kRandomColor().CGColor;
        
        NSLog(@"Step3 testView1: %@", [weak_s.testView1 actionForLayer:weak_s.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step3 testLayer1: %@", [weak_s.testView1 actionForLayer:weak_s.testLayer1 forKey:@"backgroundColor"]);
        
        [CATransaction commit];
        
        NSLog(@"Step4 testView1: %@", [weak_s.testView1 actionForLayer:weak_s.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step4 testLayer1: %@", [weak_s.testView1 actionForLayer:weak_s.testLayer1 forKey:@"backgroundColor"]);
    }];
    
    [weak_s test:@"animateWithDuration + LayerColor" tap:^(UIButton *button, NSDictionary *userInfo) {
        
        NSLog(@"Step1 testView1: %@", [weak_s.testView1 actionForLayer:weak_s.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step1 testLayer1: %@", [weak_s.testView1 actionForLayer:weak_s.testLayer1 forKey:@"backgroundColor"]);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        
        NSLog(@"Step2 testView1: %@", [weak_s.testView1 actionForLayer:weak_s.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step2 testLayer1: %@", [weak_s.testView1 actionForLayer:weak_s.testLayer1 forKey:@"backgroundColor"]);
        
        weak_s.testLayer1.backgroundColor = kRandomColor().CGColor;
        weak_s.testView1.layer.backgroundColor = kRandomColor().CGColor;
        
        NSLog(@"Step3 testView1: %@", [weak_s.testView1 actionForLayer:weak_s.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step3 testLayer1: %@", [weak_s.testView1 actionForLayer:weak_s.testLayer1 forKey:@"backgroundColor"]);
        
        [UIView commitAnimations];
        
        NSLog(@"Step4 testView1: %@", [weak_s.testView1 actionForLayer:weak_s.testView1.layer forKey:@"backgroundColor"]);
        NSLog(@"Step4 testLayer1: %@", [weak_s.testView1 actionForLayer:weak_s.testLayer1 forKey:@"backgroundColor"]);
    }];
    
    [weak_s test:@"ViewColor" tap:^(UIButton *button, NSDictionary *userInfo) {
        weak_s.testView2.backgroundColor = kRandomColor();
    }];
    
    [weak_s test:@"CATransaction + ViewColor" tap:^(UIButton *button, NSDictionary *userInfo) {
        
        NSLog(@"Step1: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"backgroundColor"]);
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:2];
        
        NSLog(@"Step2: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"backgroundColor"]);
        
        weak_s.testView2.backgroundColor = kRandomColor();
        
        NSLog(@"Step3: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"backgroundColor"]);
        
        [CATransaction commit];
        
        NSLog(@"Step4: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"backgroundColor"]);
    }];
    
    [weak_s test:@"animateWithDuration + ViewColor" tap:^(UIButton *button, NSDictionary *userInfo) {
        
        NSLog(@"Step1: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"backgroundColor"]);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:2];
        
        NSLog(@"Step2: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"backgroundColor"]);
        
        weak_s.testView2.backgroundColor = kRandomColor();
        
        NSLog(@"Step3: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"backgroundColor"]);
        
        [UIView commitAnimations];
        
        NSLog(@"Step4: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"backgroundColor"]);
    }];
    
    [weak_s test:@"断点后还会继续动画" tap:^(UIButton *button, NSDictionary *userInfo) {
        const BOOL even = [userInfo[kButtonTapCountKey] integerValue] % 2 == 0;
        NSLog(@"Step1: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"transform"]);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:5];
        
        NSLog(@"Step2: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"transform"]);
        
        CGAffineTransform t = weak_s.testView2.transform;
        t = even ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(200, 300);
        weak_s.testView2.transform = t;
        
        NSLog(@"Step3: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"transform"]);
        
        [UIView commitAnimations];
        
        NSLog(@"Step4: %@", [weak_s.testView2 actionForLayer:weak_s.testView2.layer forKey:@"transform"]);
    }];
    
    [weak_s test:@"断点后还会继续动画 使用UIViewAnimationBlock transform" tap:^(UIButton *button, NSDictionary *userInfo) {
        [UIView animateWithDuration:5 animations:^{
            const BOOL even = [userInfo[kButtonTapCountKey] integerValue] % 2 == 0;
            CGAffineTransform t = weak_s.testView2.transform;
            t = even ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(200, 300);
            weak_s.testView2.transform = t;
        }];
    }];
    
    [weak_s test:@"断点后还会继续动画 使用UIViewAnimationBlock frame" tap:^(UIButton *button, NSDictionary *userInfo) {
        [UIView animateWithDuration:5 animations:^{
            const BOOL even = [userInfo[kButtonTapCountKey] integerValue] % 2 == 0;
            CGRect frame = weak_s.testView2.frame;
            frame.origin.x = 20 + (even ? 0 : 200);
            frame.origin.y = 200 + (even ? 0 : 300);
            weak_s.testView2.frame = frame;
        }];
    }];
    
    [weak_s test:@"触摸响应位于动画末端 可以试试倒数三个动画" tap:^(UIButton *button, NSDictionary *userInfo) {
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

- (void)pauseAnimation:(UIView *)view
{
    CFTimeInterval pauseTime = [view.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    view.layer.timeOffset = pauseTime;
    view.layer.speed = 0;
}

- (void)resumeAnimation:(UIView *)view
{
    CFTimeInterval pauseTime = view.layer.timeOffset;
    CFTimeInterval timeSincePause = CACurrentMediaTime() - pauseTime;
    
    view.layer.timeOffset = 0;
    view.layer.beginTime = timeSincePause;
    view.layer.speed = 1;
}

@end
