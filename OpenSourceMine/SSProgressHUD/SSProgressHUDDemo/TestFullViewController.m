//
//  TestFullViewController.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/16.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "TestFullViewController.h"

@implementation TestFullViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.array = @[@[@"字上    图 + 圈",
                     @"字上    圈 + 图",
                     @"字下    图 + 圈",
                     @"字下    圈 + 图"],
                   @[@"图上    字 + 圈",
                     @"图上    圈 + 字",
                     @"图下    字 + 圈",
                     @"图下    圈 + 字"],
                   @[@"圈上    字 + 图",
                     @"圈上    图 + 字",
                     @"圈下    字 + 图",
                     @"圈下    图 + 字"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    const NSInteger imageTypeIndex = self.imageControl.selectedSegmentIndex;
    const NSInteger textTypeIndex = self.textControl.selectedSegmentIndex;
    UIImage *image = [UIImage imageNamed:[TestParameter imageNameArray][imageTypeIndex]];
    NSString *text = [TestParameter textArray][textTypeIndex];
    
    NSNumber *itemText = @(SSProgressHUDItemText);
    NSNumber *itemImage = @(SSProgressHUDItemImage);
    NSNumber *itemIndicator = @(SSProgressHUDItemIndicator);
    
    NSNumber *item0 = nil;
    NSArray *item1 = nil;
    switch (indexPath.section) {
        case 0: {
            item0 = itemText;
            if (indexPath.row % 2 == 0) {
                item1 = @[itemImage, itemIndicator];
            } else {
                item1 = @[itemIndicator, itemImage];
            }
            break;
        }
        case 1: {
            item0 = itemImage;
            if (indexPath.row % 2 == 0) {
                item1 = @[itemText, itemIndicator];
            } else {
                item1 = @[itemIndicator, itemText];
            }
            break;
        }
        case 2: {
            item0 = itemIndicator;
            if (indexPath.row % 2 == 0) {
                item1 = @[itemText, itemImage];
            } else {
                item1 = @[itemImage, itemText];
            }
            break;
        }
        default: {
            break;
        }
    }
    
    NSParameterAssert(item0 && item1);
    NSArray *layout = nil;
    if (indexPath.row <= 1) {
        layout = @[item0, item1];
    } else {
        layout = @[item1, item0];
    }
    
    [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
        style.layout = layout;
        style.image = image;
        style.text = text;
    }];
}

@end
