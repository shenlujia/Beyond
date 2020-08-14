//
//  SSProgressHUDRecord.h
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSProgressHUDStyle;

@interface SSProgressHUDRecord : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) SSProgressHUDStyle *style;
@property (nonatomic, strong, readonly) NSTimer *timer;

@property (nonatomic, assign, readonly) CGFloat fadeInDuration;
@property (nonatomic, assign, readonly) CGFloat fadeOutDuration;

- (instancetype)initWithIdentifier:(NSString *)identifier
                             style:(SSProgressHUDStyle *)style
                             timer:(NSTimer *)timer
                    fadeInDuration:(CGFloat)fadeInDuration
                   fadeOutDuration:(CGFloat)fadeOutDuration;

@end
