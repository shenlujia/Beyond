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

    [self test_c:@"Foundation"];

    [self test_c:@"UselessClassCheck"];

    [self test_c:@"Photo"];

    [self test_c:@"AVKit"];
    
    [self test_c:@"CallStack"];
    
    [self test_c:@"Fishhook"];
    
    [self test_c:@"UIKit"];
    
    [self test_c:@"Timer"];
    
    [self test_c:@"RunLoop"];
    
    [self test_c:@"KVC"];
    
    [self test_c:@"Thread"];
    
    [self test_c:@"Memory"];
    
    [self test_c:@"Safety"];
    
    [self test_c:@"Ivar"];
    
    [self test_c:@"Animation"];
    
    [self test_c:@"KVOController"];
    
    [self test_c:@"GCDController"];
    
    [self test_c:@"ExerciseController" title:@"一些题目"];
    
    [self test_c:@"BlockController"];
    
    [self test_c:@"ControllerLifeCycleParentController" title:@"Controller生命周期"];
    
    [self test_c:@"AssociatedObjectController" title:@"关联对象"];
}

@end
