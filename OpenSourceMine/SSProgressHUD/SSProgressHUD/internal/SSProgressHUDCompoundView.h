//
//  SSProgressHUDCompoundView.h
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSProgressHUDCompoundView : UIView

@property (nonatomic, assign) CGSize estimatedItemSize; // default {50, 50}

- (instancetype)initWithView:(UIView *)view
                       other:(UIView *)other
                    vertical:(BOOL)vertical
                       space:(CGFloat)space;

@end
