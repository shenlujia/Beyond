//
//  ViewController.m
//  hs_audio_demo
//
//  Created by shenlujia on 16/6/5.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "ViewController.h"
#import "HsAudioEncoder.h"
#import "HsAudioRecorder.h"
#import "HsAudioPlayer.h"

@interface ViewController () <HsAudioRecorderDelegate>

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, copy) NSString *PCMPath;
@property (nonatomic, copy) NSString *MP3Path;
@property (nonatomic, strong) NSDate *recordDate;

@property (nonatomic, strong) HsAudioRecorder *recorder;
@property (nonatomic, strong) HsAudioPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    self.PCMPath = [documentPath stringByAppendingPathComponent:@"pcm.file"];
    self.MP3Path = [documentPath stringByAppendingPathComponent:@"audio.mp3"];
    
    self.recorder = [[HsAudioRecorder alloc] init];
    self.recorder.filePath = self.PCMPath;
    self.recorder.delegate = self;
    
    self.player = [[HsAudioPlayer alloc] init];
    self.player.filePath = self.MP3Path;
    
    CGRect frame = self.view.bounds;
    frame.origin = CGPointZero;
    frame.size.height = 80;
    
    UIButton *beginRecording = [self createButtonWithTitle:@"beginRecording"];
    beginRecording.frame = frame;
    
    frame.origin.y += frame.size.height;
    UIButton *endRecording = [self createButtonWithTitle:@"endRecording"];
    endRecording.frame = frame;
    
    frame.origin.y += frame.size.height;
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = [UIColor brownColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    self.infoLabel = label;
    
    frame.origin.y += frame.size.height;
    UIButton *beginPlaying = [self createButtonWithTitle:@"beginPlaying"];
    beginPlaying.frame = frame;
    
    frame.origin.y += frame.size.height;
    UIButton *endPlaying = [self createButtonWithTitle:@"endPlaying"];
    endPlaying.frame = frame;
}

#pragma mark - action

- (void)beginRecording
{
    NSError *error;
    if (!self.recorder.isRecording) {
        [[NSFileManager defaultManager] removeItemAtPath:self.PCMPath error:nil];
        [self.recorder record:&error];
        self.recordDate = [NSDate date];
    }
}

- (void)endRecording
{
    [self.recorder stop];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.MP3Path error:nil];
    
    NSDate *date = [NSDate date];
    HsAudioEncoder *encoder = [[HsAudioEncoder alloc] init];
    [encoder convertPCM:self.PCMPath toMP3:self.MP3Path error:nil];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    
    CGFloat pcmSize = [self fileSize:self.PCMPath];
    CGFloat mp3Size = [self fileSize:self.MP3Path];
    
    NSMutableString *text = [NSMutableString stringWithFormat:@"convert duration: %.3f\n", interval];
    [text appendFormat:@"PCM:%.1fKB   MP3:%.1fKB", pcmSize / 1024, mp3Size / 1024];
    self.infoLabel.text = text;
}

- (void)beginPlaying
{
    [self.player play:nil];
}

- (void)endPlaying
{
    [self.player stop];
}

#pragma mark - HsAudioRecorderDelegate

- (void)audioRecorder:(HsAudioRecorder *)recorder currentMeter:(CGFloat)meter
{
    NSLog(@"%f", meter);
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.recordDate];
    self.title = [NSString stringWithFormat:@"%.1fs", interval];
}

#pragma mark - private

- (UIButton *)createButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    button.backgroundColor = nil;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:NSSelectorFromString(title) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    return button;
}

- (NSInteger)fileSize:(NSString *)path
{
    NSFileManager *filemanager = [[NSFileManager alloc] init];
    if(![filemanager fileExistsAtPath:path]) {
        return 0;
    }
    NSDictionary *attributes = [filemanager attributesOfItemAtPath:path error:nil];
    NSNumber *theFileSize = attributes[NSFileSize];
    return theFileSize ? theFileSize.integerValue : 0;
}

@end
