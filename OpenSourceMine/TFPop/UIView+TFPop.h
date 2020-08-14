//
//  UIView+TFPop.h
//  AFNetworking
//
//  Created by admin on 2018/5/10.
//

#import <UIKit/UIKit.h>
#import "TFPopConfiguration.h"

////////////////////////////////////////////////////////////

@interface UIView (TFPop)

@property (nonatomic, strong) UIView *tfpop_backgroundView; // 默认无背景色的view

- (void)tfpop_showWithConfiguration:(TFPopConfiguration *)configuration;
- (void)tfpop_showWithConfiguration:(TFPopConfiguration *)configuration inView:(UIView *)view;
- (void)tfpop_dismiss;

@end

////////////////////////////////////////////////////////////
