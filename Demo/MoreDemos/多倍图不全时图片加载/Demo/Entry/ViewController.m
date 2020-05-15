//
//  ViewController.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    const CGFloat width = 20;
    
    // 原图
    UIImage *original = [UIImage imageNamed:@"original"];
    NSParameterAssert(original.size.width == width);
    
    // asset内每个set只有一种图 屏幕自动适配 size相等
    UIImage *asset_1x = [UIImage imageNamed:@"asset_1x"];
    UIImage *asset_2x = [UIImage imageNamed:@"asset_2x"];
    UIImage *asset_3x = [UIImage imageNamed:@"asset_3x"];
    NSParameterAssert(asset_1x.size.width == width);
    NSParameterAssert(asset_2x.size.width == width);
    NSParameterAssert(asset_3x.size.width == width);
    
    // bundle内每个名称只有一张图 屏幕自动适配 size相等
    UIImage *bundle_1x = [UIImage imageNamed:@"bundle_1x"];
    UIImage *bundle_2x = [UIImage imageNamed:@"bundle_2x"];
    UIImage *bundle_3x = [UIImage imageNamed:@"bundle_3x"];
    NSParameterAssert(bundle_1x.size.width == width);
    NSParameterAssert(bundle_2x.size.width == width);
    NSParameterAssert(bundle_3x.size.width == width);
    
    // bundle内无后缀 size直接就是图片原大小
    UIImage *bundle_raw_1x = [UIImage imageNamed:@"bundle_raw_1x"];
    UIImage *bundle_raw_2x = [UIImage imageNamed:@"bundle_raw_2x"];
    UIImage *bundle_raw_3x = [UIImage imageNamed:@"bundle_raw_3x"];
    NSParameterAssert(bundle_raw_1x.size.width == width);
    NSParameterAssert(bundle_raw_2x.size.width == width * 2);
    NSParameterAssert(bundle_raw_3x.size.width == width * 3);
    
    NSLog(@"test finish");
}

@end
