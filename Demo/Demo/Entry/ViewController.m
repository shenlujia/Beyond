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
    
    [self test_c:@"AnimationController"];
    
    [self test_c:@"AppearanceController" title:@"UIAppearance"];
    
    [self test_c:@"ControlController" title:@"UIControl"];
    
    [self test_c:@"KVOController"];
    
    [self test_c:@"GCDController"];
    
    [self test_c:@"ExerciseController" title:@"一些题目"];
    
    [self test_c:@"BlockController"];
    
    [self test_c:@"ControllerLifeCycleParentController" title:@"Controller生命周期"];
    
    [self test_c:@"AssociatedObjectController" title:@"关联对象"];
}

@end
