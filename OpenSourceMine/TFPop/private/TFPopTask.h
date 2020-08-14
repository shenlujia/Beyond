//
//  TFPopTask.h
//  TFPop
//
//  Created by admin on 2018/5/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFPopConfiguration.h"

@interface TFPopTask : NSObject

@property (nonatomic, strong, readonly) UIView *view;
@property (nonatomic, strong, readonly) TFPopConfiguration *configuration;

- (instancetype)initWithView:(UIView *)view
               configuration:(TFPopConfiguration *)configuration;

- (CGRect)viewBeginFrame;
- (void)getShowFrame:(CGRect *)viewFrame backgroundViewFrame:(CGRect *)backgroundViewFrame;
- (CGRect)viewEndFrame;

- (CGFloat)viewBeginAlpha;
- (CGFloat)viewShowAlpha;
- (CGFloat)viewEndAlpha;

@end
