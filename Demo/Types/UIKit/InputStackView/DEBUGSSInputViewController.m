//
//  DEBUGSSInputViewController.m
//  ZZZ
//
//  Created by ZZZ on 2025/6/13.
//  Copyright © 2025 SLJ. All rights reserved.
//

#import "DEBUGSSInputViewController.h"
#import "DEBUGSSInputCellView.h"

@interface DEBUGSSInputViewController ()

@property (nonatomic, strong) UIStackView *stackView;

@end

@implementation DEBUGSSInputViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:self.view.bounds];
    stackView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:stackView];
    self.stackView = stackView;
    
    for (NSInteger idx = 0; idx < 10; ++idx) {
        DEBUGSSInputCellView *view1 = [[DEBUGSSInputCellView alloc] init];
        view1.frame = CGRectMake(10, 10, 200, 50);
        view1.backgroundColor = [UIColor colorWithRed:[self randomFloatValue] green:[self randomFloatValue] blue:[self randomFloatValue] alpha:1];
        [stackView addArrangedSubview:view1];
    }
}

- (CGFloat)randomFloatValue
{
    return (arc4random() % 100) / 99.0;
}

@end
