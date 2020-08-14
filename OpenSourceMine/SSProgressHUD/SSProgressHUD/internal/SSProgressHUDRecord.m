//
//  SSProgressHUDRecord.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "SSProgressHUDRecord.h"
#import "SSProgressHUDStyle.h"

@implementation SSProgressHUDRecord

- (void)dealloc
{
    [self.timer invalidate];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                             style:(SSProgressHUDStyle *)style
                             timer:(NSTimer *)timer
                    fadeInDuration:(CGFloat)fadeInDuration
                   fadeOutDuration:(CGFloat)fadeOutDuration
{
    self = [self init];
    
    _identifier = [identifier copy];
    _style = [style copy];
    _timer = timer;
    _fadeInDuration = MAX(fadeInDuration, 0);
    _fadeOutDuration = MAX(fadeOutDuration, 0);
    
    return self;
}

@end
