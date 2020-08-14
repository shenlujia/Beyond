//
//  SSProgressHUDContentView.h
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSProgressHUDStyle;

@interface SSProgressHUDContentView : UIView

@property (nonatomic, assign, readonly) CGPoint offset;
@property (nonatomic, assign, readonly) UIEdgeInsets margin;

- (void)updateWithStyle:(SSProgressHUDStyle *)style;

@end
