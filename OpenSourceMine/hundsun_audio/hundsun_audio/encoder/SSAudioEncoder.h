//
//  SSAudioEncoder.h
//  hs_audio_demo
//
//  Created by shenlujia on 16/6/5.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSAudioEncoder : NSObject

@property (nonatomic, assign) CGFloat sampleRate;

- (BOOL)convertPCM:(NSString *)PCMPath toMP3:(NSString *)MP3Path error:(NSError **)error;

@end
