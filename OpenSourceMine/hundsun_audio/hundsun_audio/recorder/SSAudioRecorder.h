//
//  SSAudioRecorder.h
//  hs_audio_demo
//
//  Created by shenlujia on 16/6/5.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSAudioRecorder;
@protocol SSAudioRecorderDelegate <NSObject>
@optional
- (void)audioRecorder:(SSAudioRecorder *)recorder currentMeter:(CGFloat)meter;
@end

@interface SSAudioRecorder : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, weak) id<SSAudioRecorderDelegate> delegate;
@property (nonatomic, assign) CGFloat sampleRate;

- (BOOL)record:(NSError **)error;
- (void)stop;
- (BOOL)isRecording;

@end
