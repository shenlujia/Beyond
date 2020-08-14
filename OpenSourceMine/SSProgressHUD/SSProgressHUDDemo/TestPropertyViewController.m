//
//  TestPropertyViewController.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/16.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "TestPropertyViewController.h"
#import "TestPropertySliderView.h"

#define ViewTag 888

typedef NS_ENUM(NSInteger, TestPropertyType) {
    TestProperty_attributedText = 0,
    TestProperty_font,
    TestProperty_ignoreInteractionEvents,
    TestProperty_duration,
    TestProperty_contentView_borderWidth,
    TestProperty_contentView_cornerRadius,
    TestProperty_backView_borderWidth,
    TestProperty_backView_cornerRadius,
    TestProperty_contentPadding_left,
    TestProperty_contentPadding_right,
    TestProperty_contentPadding_top,
    TestProperty_contentPadding_bottom,
    TestProperty_contentMargin_left,
    TestProperty_contentMargin_right,
    TestProperty_contentMargin_top,
    TestProperty_contentMargin_bottom,
    TestProperty_offset_x,
    TestProperty_offset_y,
    TestProperty_verticalSpace,
    TestProperty_horizontalSpace,
    TestProperty_count
};

@interface TestPropertyViewController ()

@property (nonatomic, strong) NSMutableDictionary *values;

@end

@implementation TestPropertyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItems = ({
        UIBarButtonItem *item = nil;
        NSMutableArray *items = [NSMutableArray array];
        item = [[UIBarButtonItem alloc] initWithTitle:@"生成"
                                                style:UIBarButtonItemStylePlain
                                               target:self
                                               action:@selector(generate)];
        [items addObject:item];
        item = [[UIBarButtonItem alloc] initWithTitle:@"重置"
                                                style:UIBarButtonItemStylePlain
                                               target:self
                                               action:@selector(reload)];
        [items addObject:item];
        items;
    });
    
    self.array = @[@[@[@"是否attributedText", @(0), @(1), @(0)],
                     @[@"字体大小", @(8), @(32), @(14)],
                     @[@"屏蔽点击 持续2.8秒", @(0), @(1), @(0)],
                     @[@"持续时间", @(0.2), @(8), @(1.5)],
                     @[@"内容_borderWidth", @(0), @(8), @(0)],
                     @[@"内容_cornerRadius", @(0), @(20), @(5)],
                     @[@"背景_borderWidth", @(0), @(8), @(0)],
                     @[@"背景_cornerRadius", @(0), @(20), @(5)],
                     @[@"内容padding_left", @(-20), @(50), @(10)],
                     @[@"内容padding_right", @(-20), @(50), @(10)],
                     @[@"内容padding_top", @(-20), @(50), @(10)],
                     @[@"内容padding_bottom", @(-20), @(50), @(10)],
                     @[@"内容margin_left", @(-20), @(50), @(10)],
                     @[@"内容margin_right", @(-20), @(50), @(10)],
                     @[@"内容margin_top", @(-20), @(50), @(10)],
                     @[@"内容margin_bottom", @(-20), @(50), @(10)],
                     @[@"偏移_x", @(-100), @(100), @(0)],
                     @[@"偏移_y", @(-100), @(100), @(0)],
                     @[@"行间距", @(-20), @(50), @(10)],
                     @[@"列间距", @(-20), @(50), @(10)]]];
    self.values = [NSMutableDictionary dictionary];
    
    NSArray *rows = self.array.firstObject;
    NSParameterAssert(rows.count == TestProperty_count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"row = %@", @(indexPath.row)];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
        CGRect frame = cell.contentView.frame;
        frame.origin = CGPointZero;
        TestPropertySliderView *view = [[TestPropertySliderView alloc] initWithFrame:frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.tag = ViewTag;
        [cell.contentView addSubview:view];
    }
    
    NSArray *section = self.array[indexPath.section];
    NSArray *object = section[indexPath.row];
    
    TestPropertySliderView *view = [cell.contentView viewWithTag:ViewTag];
    view.text = object[0];
    view.minimumValue = [object[1] floatValue];
    view.maximumValue = [object[2] floatValue];
    view.value = [self valueForType:indexPath.row];
    
    __weak typeof (self) weakSelf = self;
    [view setValueBlock:^(CGFloat value) {
        weakSelf.values[@(indexPath.row)] = @(value);
    }];
    
    return cell;
}

- (void)reload
{
    [self.values removeAllObjects];
    [self.tableView reloadData];
}

- (void)generate
{
    const NSInteger imageTypeIndex = self.imageControl.selectedSegmentIndex;
    const NSInteger textTypeIndex = self.textControl.selectedSegmentIndex;
    UIImage *image = [UIImage imageNamed:[TestParameter imageNameArray][imageTypeIndex]];
    NSString *text = [TestParameter textArray][textTypeIndex];
    
    SSProgressHUDStyle *style = [SSProgressHUDStyle defaultStyleForState:SSProgressHUDStateLoading];
    style.layout = @[@(SSProgressHUDItemIndicator), @[@(SSProgressHUDItemImage), @(SSProgressHUDItemText)]];
    
    CGFloat font = [self valueForType:TestProperty_font];
    style.font = [UIFont systemFontOfSize:font];
    style.textColor = [self randomColor];
    style.text = text;
    style.image = image;
    if (round([self valueForType:TestProperty_attributedText])) {
        NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:text];
        if (ret.length > 0) {
            NSRange range = NSMakeRange(0, 2);
            [ret addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:range];
            [ret addAttribute:NSForegroundColorAttributeName value:[self randomColor] range:range];
        }
        style.attributedText = ret;
    }
    
    style.ignoreInteractionEvents = round([self valueForType:TestProperty_ignoreInteractionEvents]);
    
    style.duration = [self valueForType:TestProperty_duration];
    if (style.ignoreInteractionEvents) {
        style.duration = 2.8;
    }
    
    style.contentView.backgroundColor = [self randomColor];
    style.contentView.layer.borderColor = [self randomColor].CGColor;
    style.contentView.layer.borderWidth = [self valueForType:TestProperty_contentView_borderWidth];
    style.contentView.layer.cornerRadius = [self valueForType:TestProperty_contentView_cornerRadius];
    style.backgroundView.backgroundColor = [[self randomColor] colorWithAlphaComponent:0.3];
    style.backgroundView.layer.borderColor = [self randomColor].CGColor;
    style.backgroundView.layer.borderWidth = [self valueForType:TestProperty_backView_borderWidth];
    style.backgroundView.layer.cornerRadius = [self valueForType:TestProperty_backView_cornerRadius];
    
    style.contentPadding = UIEdgeInsetsMake([self valueForType:TestProperty_contentPadding_top],
                                            [self valueForType:TestProperty_contentPadding_left],
                                            [self valueForType:TestProperty_contentPadding_bottom],
                                            [self valueForType:TestProperty_contentPadding_right]);
    style.contentMargin = UIEdgeInsetsMake([self valueForType:TestProperty_contentMargin_top],
                                           [self valueForType:TestProperty_contentMargin_left],
                                           [self valueForType:TestProperty_contentMargin_bottom],
                                           [self valueForType:TestProperty_contentMargin_right]);
    style.offset = CGPointMake([self valueForType:TestProperty_offset_x],
                               [self valueForType:TestProperty_offset_y]);
    
    style.verticalSpace = [self valueForType:TestProperty_verticalSpace];
    style.horizontalSpace = [self valueForType:TestProperty_horizontalSpace];
    
    [[SSProgressHUD sharedHUD] showWithStyle:style];
}

- (CGFloat)valueForType:(TestPropertyType)type
{
    NSNumber *value = self.values[@(type)];
    if (value != nil) {
        return value.floatValue;
    }
    
    NSArray *section = self.array.firstObject;
    NSArray *object = section[type];
    return [object[3] floatValue];
}

- (UIColor *)randomColor
{
    CGFloat r = (arc4random() % 256) / 256.0;
    CGFloat g = (arc4random() % 256) / 256.0;
    CGFloat b = (arc4random() % 256) / 256.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

@end
