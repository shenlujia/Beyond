//
//  SSSystemSoundPlayer.h
//  Pods
//
//  Created by shenlujia on 16/7/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AudioToolbox/AudioToolbox.h>

typedef void (^TimerWrapperBlock)(void);

@interface TimerWrapper : NSObject

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                             repeats:(BOOL)yesOrNo
                               block:(TimerWrapperBlock)block;

- (void)invalidate;

@end

@interface SSSystemSoundPlayer : NSObject

@property (nonatomic, assign, readonly) SystemSoundID soundID;
@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;

@property (nonatomic, assign) NSInteger numberOfLoops; ///< default is 0
@property (nonatomic, assign) CGFloat loopInterval; ///< default is 0

- (instancetype)initWithSoundID:(SystemSoundID)soundID;
- (instancetype)initWithSoundPath:(NSString *)path;

- (void)play;
- (void)playWithDelay:(CGFloat)delay;
- (void)stop;

@end
