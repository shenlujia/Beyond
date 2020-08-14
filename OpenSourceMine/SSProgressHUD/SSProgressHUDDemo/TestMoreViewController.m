//
//  TestMoreViewController.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/18.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "TestMoreViewController.h"

@implementation TestMoreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.array = @[@[@"和单例类似 也可以屏蔽点击 持续3.6秒",
                     @"不强引用 直接dismiss 所以只会显示一下就消失",
                     @"duration100秒 强引用2秒 只显示2秒",
                     @"不同的颜色",
                     @"显示6秒 此时点击其他 当前HUD不会消失"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    const NSInteger imageTypeIndex = self.imageControl.selectedSegmentIndex;
    const NSInteger textTypeIndex = self.textControl.selectedSegmentIndex;
    UIImage *image = [UIImage imageNamed:[TestParameter imageNameArray][imageTypeIndex]];
    NSString *text = [TestParameter textArray][textTypeIndex];
    
    SSProgressHUDStyle *object = [[SSProgressHUDStyle alloc] init];
    object.layout = @[@(SSProgressHUDItemIndicator), @[@(SSProgressHUDItemText), @(SSProgressHUDItemImage)]];
    object.image = image;
    object.text = text;
    object.backgroundView.backgroundColor = nil;
    object.ignoreInteractionEvents = NO;
    
    switch (indexPath.row) {
        case 0: {
            
            SSProgressHUDStyle *style = [object copy];
            style.duration = 3.6;
            style.ignoreInteractionEvents = YES;
            style.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
            
            static SSProgressHUD *HUD = nil;
            HUD = [[SSProgressHUD alloc] init];
            [HUD showWithStyle:style];
            
            break;
        }
        case 1: {
            
            SSProgressHUDStyle *style = [object copy];
            
            SSProgressHUD *HUD = [[SSProgressHUD alloc] init];
            [HUD showWithStyle:style];
            
            break;
        }
        case 2: {
            
            SSProgressHUDStyle *style = [object copy];
            style.duration = 100;
            
            __block SSProgressHUD *HUD = [[SSProgressHUD alloc] init];
            [HUD showWithStyle:style];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                HUD = nil;
            });
            
            break;
        }
        case 3: {
            
            SSProgressHUDStyle *style = [object copy];
            style.textColor = [self randomColor];
            style.contentView.backgroundColor = [self randomColor];
            style.contentView.layer.borderColor = [[self randomColor] CGColor];
            style.contentView.layer.borderWidth = 3;
            style.contentView.layer.cornerRadius = 0;
            style.backgroundView.backgroundColor = [[self randomColor] colorWithAlphaComponent:0.3];
            style.backgroundView.layer.borderColor = [[self randomColor] CGColor];
            style.backgroundView.layer.borderWidth = 3;
            style.backgroundView.layer.cornerRadius = 0;
            
            __block SSProgressHUD *HUD = [[SSProgressHUD alloc] init];
            [HUD showWithStyle:style];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                HUD = nil;
            });
            
            break;
        }
        case 4: {
            
            SSProgressHUDStyle *style = [object copy];
            style.text = @"KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK";
            
            __block SSProgressHUD *HUD = [[SSProgressHUD alloc] init];
            [HUD showWithStyle:style];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                HUD = nil;
            });
            
            break;
        }
        default: {
            break;
        }
    }
}
                               
- (UIColor *)randomColor
{
    CGFloat r = (arc4random() % 256) / 256.0;
    CGFloat g = (arc4random() % 256) / 256.0;
    CGFloat b = (arc4random() % 256) / 256.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
