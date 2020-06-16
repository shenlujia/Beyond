//
//  ViewController.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self test_c:@"Thread"];
    
    [self test_c:@"Memory"];
    
    [self test_c:@"Safety"];
    
    [self test_c:@"Ivar"];
    
    [self test_c:@"Animation"];
    
    [self test_c:@"Appearance" title:@"UIAppearance"];
    
    [self test_c:@"ControlController" title:@"UIControl"];
    
    [self test_c:@"KVOController"];
    
    [self test_c:@"GCDController"];
    
    [self test_c:@"ExerciseController" title:@"一些题目"];
    
    [self test_c:@"BlockController"];
    
    [self test_c:@"ControllerLifeCycleParentController" title:@"Controller生命周期"];
    
    [self test_c:@"AssociatedObjectController" title:@"关联对象"];
}

@end
