//
//  MainViewController.m
//  HSKVO
//
//  Created by shenlujia on 2016/1/13.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "MainViewController.h"
#import "KVO_FB_Controller.h"
#import "KVO_HS_Controller.h"
#import "KVO_UI_Controller.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = @[@"原生 KVO",
                  @"FBKVO",
                  @"HSKVO"];
}

- (void)didSelectIndex:(NSInteger)index
{
    UIViewController *controller = nil;
    switch (index) {
        case 0: {
            controller = [[KVO_UI_Controller alloc] init];
            break;
        }
        case 1: {
            controller = [[KVO_FB_Controller alloc] init];
            break;
        }
        case 2: {
            controller = [[KVO_HS_Controller alloc] init];
            break;
        }
        default: {
            break;
        }
    }
    if (controller) {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
