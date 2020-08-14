//
//  SSAudioUtility.m
//  hs_audio_demo
//
//  Created by shenlujia on 16/6/5.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "SSAudioUtility.h"
#import "MeterTable.h"

static MeterTable *meterTable = new MeterTable(-80);

@implementation SSAudioUtility

+ (CGFloat)valueAt:(CGFloat)inDecibels
{
    return meterTable->ValueAt(inDecibels);
}

+ (void)resetError:(NSError **)error exception:(NSException *)exception info:(NSString *)info
{
    if (error) {
        if (exception) {
            *error = [NSError errorWithDomain:exception.reason code:0 userInfo:exception.userInfo];
        } else {
            *error = [NSError errorWithDomain:info code:0 userInfo:nil];
        }
    }
}

@end
