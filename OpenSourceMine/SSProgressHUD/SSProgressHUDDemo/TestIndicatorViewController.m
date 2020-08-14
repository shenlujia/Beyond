//
//  TestIndicatorViewController.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/16.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "TestIndicatorViewController.h"
#import "SSProgressHUD.h"

@interface TestIndicatorViewController ()

@property (nonatomic, copy) NSArray *array;

@end

@implementation TestIndicatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.array = @[@"UIActivityIndicatorViewStyleWhiteLarge",
                   @"UIActivityIndicatorViewStyleWhite",
                   @"UIActivityIndicatorViewStyleGray",
                   @"多个横",
                   @"多个竖",
                   @"多上一下",
                   @"一上多下",
                   @"复杂情况"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *key = @"key";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.textLabel.text = self.array[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                style.layout = @[@(SSProgressHUDItemIndicator)];
                style.indicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
            }];
            
            break;
        }
        case 1: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                style.layout = @[@(SSProgressHUDItemIndicator)];
                style.indicatorStyle = UIActivityIndicatorViewStyleWhite;
            }];
            
            break;
        }
        case 2: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                style.layout = @[@(SSProgressHUDItemIndicator)];
                style.indicatorStyle = UIActivityIndicatorViewStyleGray;
                style.contentView.backgroundColor = [UIColor yellowColor];
            }];
            
            break;
        }
        case 3: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                NSNumber *item = @(SSProgressHUDItemIndicator);
                style.layout = @[@[item, item, item, item, item, item]];
                style.indicatorStyle = UIActivityIndicatorViewStyleWhite;
            }];
            
            break;
        }
        case 4: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                NSNumber *item = @(SSProgressHUDItemIndicator);
                style.layout = @[item, item, item, item, item, item];
                style.indicatorStyle = UIActivityIndicatorViewStyleWhite;
            }];
            
            break;
        }
        case 5: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                NSNumber *item = @(SSProgressHUDItemIndicator);
                style.layout = @[@[item, item, item], item];
                style.indicatorStyle = UIActivityIndicatorViewStyleWhite;
            }];
            
            break;
        }
        case 6: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                NSNumber *item = @(SSProgressHUDItemIndicator);
                style.layout = @[item, @[item, item, item]];
                style.indicatorStyle = UIActivityIndicatorViewStyleWhite;
            }];
            
            break;
        }
        case 7: {
            
            [[SSProgressHUD sharedHUD] showInfoWithStyle:^(SSProgressHUDStyle *style) {
                NSNumber *item = @(SSProgressHUDItemIndicator);
                style.layout = @[item, @[item, item], @[item, item, item], @[item, item, item, item], @[item, item, item, item, item], @[item, item, item, item, item, item]];
                style.indicatorStyle = UIActivityIndicatorViewStyleWhite;
            }];
            
            break;
        }
        default: {
            break;
        }
    }
}

@end
