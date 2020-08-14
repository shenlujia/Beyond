//
//  TFPopConfiguration.m
//  TFPop
//
//  Created by admin on 2018/5/11.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "TFPopConfiguration.h"

@implementation TFPopConfiguration

- (instancetype)init
{
    self = [super init];
   
    if (self) {
        _beginOptions = TFPopBottom | TFPopMiddle;
        _showOptions = TFPopBottom | TFPopMiddle;
        _endOptions = TFPopBottom | TFPopMiddle;
        
        _dismissMode = TFPopDismissModeNone;
        _automaticallyAdjustsSafeAreaInsets = NO;
        
        _offset = UIOffsetZero;
        
        _showAnimationDuration = 0.25;
        _dismissAnimationDuration = 0.25;
    }

    return self;
}

@end
