//
//  ViewController.m
//  TFLoadingView
//
//  Created by admin on 2018/4/10.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "ViewController.h"
#import <TFLoadingView/TFLoadingView.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TFLoadingConfiguration.defaultConfiguration updateStyleWithBlock:^(TFLoadingStyle *style) {
        style.buttonStyle = TFAppearance.button.normalStyle;
    } forState:TFLoadingStateNoNetwork];
    
    [TFLoadingConfiguration.defaultConfiguration updateStyleWithBlock:^(TFLoadingStyle *style) {
        style.buttonStyle = TFAppearance.button.lightStyle;
    } forState:TFLoadingStateError];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.navigationItem.rightBarButtonItem = ({
        [[UIBarButtonItem alloc] initWithTitle:@"切换"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(changeAction)];
    });
    
    self.view.tf_loadingView.tapBlock = ^(TFLoadingView *loadingView) {
        NSLog(@"tf_loadingView state = %@", @(loadingView.state));
    };
    
    self.view.tf_loadingView.state = TFLoadingStateLoading;
}

- (void)changeAction
{
    TFLoadingState state = self.view.tf_loadingView.state;
    self.view.tf_loadingView.state = (state + 1) % (TFLoadingStateHidden + 1);
}

@end
