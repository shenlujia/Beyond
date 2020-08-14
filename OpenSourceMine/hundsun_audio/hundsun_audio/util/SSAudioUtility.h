//
//  SSAudioUtility.h
//  hs_audio_demo
//
//  Created by shenlujia on 16/6/5.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSAudioUtility : NSObject

+ (CGFloat)valueAt:(CGFloat)inDecibels;
+ (void)resetError:(NSError **)error exception:(NSException *)exception info:(NSString *)info;

@end
