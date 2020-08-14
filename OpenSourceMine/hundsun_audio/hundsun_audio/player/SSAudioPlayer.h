//
//  SSAudioPlayer.h
//  hs_audio_demo
//
//  Created by shenlujia on 16/6/5.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSAudioPlayer : NSObject

@property (nonatomic, copy) NSString *filePath;

- (BOOL)play:(NSError **)error;
- (void)stop;
- (BOOL)isPlaying;

@end
