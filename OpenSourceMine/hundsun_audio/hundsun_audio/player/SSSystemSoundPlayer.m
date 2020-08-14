//
//  SSSystemSoundPlayer.m
//  Pods
//
//  Created by shenlujia on 16/7/13.
//
//

#import "SSSystemSoundPlayer.h"

@class TimerWrapper;

@interface SSSystemSoundPlayer ()

@property (nonatomic, copy) NSString *soundPath;
@property (nonatomic, strong) TimerWrapper *timerWrapper;
@property (nonatomic, assign) NSInteger currentNumberOfLoops;

- (void)playWithDelayImpl:(CGFloat)delay;

@end

static NSMapTable *mapTable = nil;

static void completionProc(SystemSoundID ssID, void *clientData)
{
    NSString *key = [NSString stringWithFormat:@"%p", clientData];
    SSSystemSoundPlayer *player = [mapTable objectForKey:key];
    
    BOOL continuePlaying = NO;
    if (player.isPlaying) {
        if (player.currentNumberOfLoops > 0) {
            player.currentNumberOfLoops--;
        }
        continuePlaying = (player.currentNumberOfLoops != 0);
    }
    
    if (continuePlaying) {
        [player playWithDelayImpl:player.loopInterval];
    } else {
        [player stop];
    }
}

@interface TimerWrapper ()

@property (nonatomic, strong) NSTimer *impl;
@property (nonatomic, copy) TimerWrapperBlock block;

@end

@implementation TimerWrapper

- (void)dealloc
{
    [self invalidate];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                             repeats:(BOOL)yesOrNo
                               block:(TimerWrapperBlock)block
{
    self = [super init];
    
    self.block = block;
    self.impl = [NSTimer scheduledTimerWithTimeInterval:interval
                                                 target:self
                                               selector:@selector(timerAction)
                                               userInfo:nil
                                                repeats:yesOrNo];
    return self;
}

- (void)timerAction
{
    if (self.block) {
        self.block();
    }
}

- (void)invalidate
{
    self.block = nil;
    [self.impl invalidate];
    self.impl = nil;
}

@end

@implementation SSSystemSoundPlayer

#pragma mark - lifecycle

+ (void)load
{
    mapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory
                                         valueOptions:NSPointerFunctionsWeakMemory
                                             capacity:0];
}

- (void)dealloc
{
    [self stop];
}

- (instancetype)init
{
    self = [super init];
    
    _soundID = 0;
    _playing = NO;
    
    NSString *key = [NSString stringWithFormat:@"%p", self];
    [mapTable setObject:self forKey:key];
    
    return self;
}

#pragma mark - public

- (instancetype)initWithSoundID:(SystemSoundID)soundID
{
    self = [self init];
    _soundID = soundID;
    return self;
}

- (instancetype)initWithSoundPath:(NSString *)path
{
    self = [self init];
    self.soundPath = path;
    [self updateSoundIDWithSoundPath:path];
    return self;
}

- (void)play
{
    [self playWithDelay:0];
}

- (void)playWithDelay:(CGFloat)delay
{
    self.currentNumberOfLoops = self.numberOfLoops;
    if (self.currentNumberOfLoops >= 0) {
        self.currentNumberOfLoops++;
    }
    [self playWithDelayImpl:delay];
}

- (void)stop
{
    _playing = NO;
    [self.timerWrapper invalidate];
    self.timerWrapper = nil;
    self.currentNumberOfLoops = 0;
    
    AudioServicesRemoveSystemSoundCompletion(self.soundID);
    AudioServicesDisposeSystemSoundID(self.soundID);
}

#pragma mark - private

- (void)playImpl
{
    _playing = YES;
    if (self.soundPath) {
        [self updateSoundIDWithSoundPath:self.soundPath];
    }
    
    AudioServicesAddSystemSoundCompletion(self.soundID, NULL, NULL, completionProc, (__bridge void *)self);
    AudioServicesPlaySystemSound(self.soundID);
}

- (void)playWithDelayImpl:(CGFloat)delay
{
    if (delay <= 0) {
        [self playImpl];
        return;
    }
    
    _playing = YES;
    __weak typeof (self) weakSelf = self;
    self.timerWrapper = [[TimerWrapper alloc] initWithTimeInterval:delay repeats:NO block:^{
        if (weakSelf.isPlaying) {
            [weakSelf playImpl];
        }
    }];
}

- (void)updateSoundIDWithSoundPath:(NSString *)path
{
    SystemSoundID soundID = 0;
    NSURL *url = nil;
    if (path.length) {
        url = [NSURL fileURLWithPath:path];
    }
    if (url) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    }
    _soundID = soundID;
}

@end
