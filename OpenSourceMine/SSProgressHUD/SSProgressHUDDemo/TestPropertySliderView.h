//
//  TestPropertySliderView.h
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/16.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestPropertySliderView : UIView

@property (nonatomic, copy) NSString *text;

@property(nonatomic, assign) CGFloat value;
@property(nonatomic) float minimumValue;
@property(nonatomic) float maximumValue;

@property (nonatomic, copy) void (^valueBlock)(CGFloat value);

@end
