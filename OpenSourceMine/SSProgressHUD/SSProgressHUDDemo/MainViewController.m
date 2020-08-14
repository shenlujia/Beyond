//
//  ViewController.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, copy) NSArray *array;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.array = @[@[@"复合视图", @"TestCompoundViewController"],
                   @[@"自定义属性", @"TestPropertyViewController"],
                   @[@"转圈", @"TestIndicatorViewController"],
                   @[@"文字 + 图片", @"TestTextImageViewController"],
                   @[@"文字 + 图片 + 转圈", @"TestFullViewController"],
                   @[@"不使用单例", @"TestMoreViewController"]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *key = @"key";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = [self.array[indexPath.row] firstObject];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *className = self.array[indexPath.row][1];
    UIViewController *controller = [[NSClassFromString(className) alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
