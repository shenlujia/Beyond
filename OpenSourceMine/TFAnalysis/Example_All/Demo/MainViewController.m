//
//  MainViewController.m
//  Demo
//
//  Created by TF020283 on 2018/9/27.
//  Copyright © 2018 TF020283. All rights reserved.
//

#import "MainViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#import "SSGaugeMemory.h"
#import "SSGaugeFPS.h"
#import "SSGaugeCPU.h"

@interface MainViewController ()

@property (nonatomic, strong) SSGaugeMemory *memory;
@property (nonatomic, strong) SSGaugeFPS *FPS;
@property (nonatomic, strong) SSGaugeCPU *CPU;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak typeof (self) weak_c = self;
    
    self.memory = [[SSGaugeMemory alloc] init];
    self.FPS = [[SSGaugeFPS alloc] init];
    self.CPU = [[SSGaugeCPU alloc] init];
    
    self.FPS.callback = ^(CGFloat value) {
        printf("Memory=%.2fMB CPU=%.2f%% FPS=%.0f\n", [weak_c.memory gauge], [weak_c.CPU gauge], value);
    };
    
    [self addCaseWithTitle:@"kk" block:^(UIButton * _Nonnull button) {
        
    }];
    
    
}

- (void)ss
{
    
}

@end
