//
//  HsPopHandler.h
//  Pods
//
//  Created by shenlujia on 2017/1/19.
//
//

#import <UIKit/UIKit.h>
#import "TFPopConfiguration.h"

@interface TFPopHandler : NSObject

- (instancetype)initWithHostView:(UIView *)hostView;

- (void)show:(UIView *)view configuration:(TFPopConfiguration *)configuration;
- (void)dismiss:(UIView *)view;

@end
