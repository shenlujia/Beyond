//
//  ControlController.m
//  Demo
//
//  Created by SLJ on 2020/4/20.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ControlController.h"

@interface ControlController ()

@end

@implementation ControlController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIControl *c = [[UIControl alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:c];
    c.backgroundColor = UIColor.redColor;

    [c addTarget:self action:@selector(touchDownRepeat) forControlEvents:UIControlEventTouchDownRepeat];
    [c addTarget:self action:@selector(touchDragInside) forControlEvents:UIControlEventTouchDragInside];
    [c addTarget:self action:@selector(touchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    [c addTarget:self action:@selector(touchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    [c addTarget:self action:@selector(touchDragExit) forControlEvents:UIControlEventTouchDragExit];
    [c addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [c addTarget:self action:@selector(touchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [c addTarget:self action:@selector(touchCancel) forControlEvents:UIControlEventTouchCancel];
}

- (void)touchDownRepeat
{
    NSLog(@"touchDownRepeat");
}

- (void)touchDragInside
{
    NSLog(@"touchDragInside");
}

- (void)touchDragOutside
{
    NSLog(@"touchDragOutside");
}

- (void)touchDragEnter
{
    NSLog(@"touchDragEnter");
}

- (void)touchDragExit
{
    NSLog(@"touchDragExit");
}

- (void)touchUpInside
{
    NSLog(@"touchUpInside");
}

- (void)touchUpOutside
{
    NSLog(@"touchUpOutside");
}

- (void)touchCancel
{
    NSLog(@"touchCancel");
}

@end
