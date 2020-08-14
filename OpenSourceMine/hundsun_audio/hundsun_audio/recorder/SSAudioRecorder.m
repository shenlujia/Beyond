//
//  SSAudioRecorder.m
//  hs_audio_demo
//
//  Created by shenlujia on 16/6/5.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "SSAudioRecorder.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "SSAudioUtility.h"

@interface SSAudioRecorder() <AVAudioRecorderDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVAudioRecorder *recorder;

@end

@implementation SSAudioRecorder

- (void)dealloc
{
    [self stop];
}

- (instancetype)init
{
    self = [super init];
    
    self.sampleRate = 44100;
    
    return self;
}

- (BOOL)record:(NSError **)error
{
    [self stop];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if (![session setCategory:AVAudioSessionCategoryPlayAndRecord error:error]) {
        return NO;
    }
    
    if (![session setActive:YES error:error]) {
        return NO;
    }
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:self.filePath error:nil];
    NSString *directory = [self.filePath stringByDeletingLastPathComponent];
    BOOL writable = [fileManager isWritableFileAtPath:directory];
    if (!writable) {
        [SSAudioUtility resetError:error exception:nil info:@"file not writable"];
        return NO;
    }
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    settings[AVSampleRateKey] = [NSNumber numberWithFloat:self.sampleRate];
    settings[AVFormatIDKey] = [NSNumber numberWithInt:kAudioFormatLinearPCM];
    settings[AVNumberOfChannelsKey] = [NSNumber numberWithInt:2];
    settings[AVEncoderAudioQualityKey] = [NSNumber numberWithInt:AVAudioQualityHigh];
    
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:error];
    if (!self.recorder) {
        return NO;
    }
    
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    [self.recorder record];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(timerRefresh)
                                                userInfo:nil
                                                 repeats:YES];
    return YES;
}

- (void)stop
{
    [self.timer invalidate];
    
    [self.recorder stop];
    self.recorder = nil;
}

- (BOOL)isRecording
{
    return self.recorder.isRecording;
}

#pragma mark - private

- (void)timerRefresh
{
    if (!self.delegate) {
        [self.timer invalidate];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(audioRecorder:currentMeter:)]) {
        [self.recorder updateMeters];
        CGFloat power = [self.recorder averagePowerForChannel:0];
        CGFloat value = [SSAudioUtility valueAt:power];
        [self.delegate audioRecorder:self currentMeter:value];
    }
}

@end
