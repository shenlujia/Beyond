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

    [self test_c:@"FoundationController"];

    [self test_c:@"UselessClassCheckController"];

    [self test_c:@"PhotoController"];

    [self test_c:@"AVKitController"];
    
    [self test_c:@"CallStackController"];
    
    [self test_c:@"FishhookController"];
    
    [self test_c:@"UIKitController"];
    
    [self test_c:@"TimerController"];
    
    [self test_c:@"RunLoopController"];
    
    [self test_c:@"KVCController"];
    
    [self test_c:@"ThreadController"];
    
    [self test_c:@"MemoryController"];
    
    [self test_c:@"SafetyController"];
    
    [self test_c:@"IvarController"];
    
    [self test_c:@"AnimationController"];
    
    [self test_c:@"KVOController"];
    
    [self test_c:@"GCDController"];
    
    [self test_c:@"ExerciseController" title:@"一些题目"];
    
    [self test_c:@"BlockController"];
    
    [self test_c:@"ControllerLifeCycleParentController" title:@"Controller生命周期"];
    
    [self test_c:@"AssociatedObjectController" title:@"关联对象"];
}

@end
