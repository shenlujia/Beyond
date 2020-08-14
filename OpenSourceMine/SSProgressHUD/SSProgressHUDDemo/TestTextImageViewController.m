//
//  TestTextImageViewController.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/16.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "TestTextImageViewController.h"

@implementation TestTextImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.array = @[@[@"图左",
                     @"图右",
                     @"图上",
                     @"图下"]];
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
    switch (indexPath.row) {
        case 0: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                style.layout = @[@[itemImage, itemText]];
                style.image = image;
                style.text = text;
            }];
            
            break;
        }
        case 1: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                style.layout = @[@[itemText, itemImage]];
                style.image = image;
                style.text = text;
            }];
            
            break;
        }
        case 2: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                style.layout = @[itemImage, itemText];
                style.image = image;
                style.text = text;
            }];
            
            break;
        }
        case 3: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                style.layout = @[itemText, itemImage];
                style.image = image;
                style.text = text;
            }];
            
            break;
        }
        default: {
            break;
        }
    }
}

@end
