//
//  SSAudioPlayer.m
//  hs_audio_demo
//
//  Created by shenlujia on 16/6/5.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "SSAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "SSAudioUtility.h"

@interface SSAudioPlayer ()

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation SSAudioPlayer

- (BOOL)play:(NSError **)error
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
    BOOL readable = [fileManager isReadableFileAtPath:self.filePath];
    if (!readable) {
        [SSAudioUtility resetError:error exception:nil info:@"file not readable"];
        return NO;
    }
    
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:error];
    if (!self.player) {
        return NO;
    }
    
    [self.player play];
    return YES;
}

- (void)stop
{
    [self.player stop];
    self.player = nil;
}

- (BOOL)isPlaying
{
    return self.player.isPlaying;
}

@end
