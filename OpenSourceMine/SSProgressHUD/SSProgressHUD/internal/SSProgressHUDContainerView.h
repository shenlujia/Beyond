//
//  SSProgressHUDContainerView.h
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSProgressHUDContentView;

@interface SSProgressHUDContainerView : UIView

- (void)updateWithContentView:(SSProgressHUDContentView *)contentView
               backgroundView:(UIView *)backgroudView;

@end
