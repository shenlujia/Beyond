//
//  AVKitController.m
//  Beyond
//
//  Created by ZZZ on 2020/12/9.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AVKitController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <AVKit/AVKit.h>
#import "SSAssetImageGenerator.h"
#import "SSEasy.h"

@interface AVKitController () <PHLivePhotoViewDelegate>

@end

@implementation AVKitController

- (BOOL)livePhotoView:(PHLivePhotoView *)livePhotoView canBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
    return YES;
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
    
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path1 = [NSBundle.mainBundle pathForResource:@"test_avkit2" ofType:@"mp4"];
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path1]];
    const CGFloat duration_float1 = CMTimeGetSeconds(asset1.duration);
    
    {
        NSString *path2 = [NSBundle.mainBundle pathForResource:@"test_video1" ofType:@"mp4"];
        AVURLAsset *asset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path2]];
        const CGFloat duration_float2 = CMTimeGetSeconds(asset2.duration);
        
        NSString *path3 = [NSBundle.mainBundle pathForResource:@"test_video2" ofType:@""];
        NSURL *url3_0 = [NSURL fileURLWithPath:@"12345"];
        NSURL *url3_1 = [NSURL fileURLWithPath:path3];
        BOOL yes333_0 = [[NSFileManager defaultManager] fileExistsAtPath:url3_0.path];
        BOOL yes333_1 = [[NSFileManager defaultManager] fileExistsAtPath:url3_1.path];
        AVURLAsset *asset3 = [AVURLAsset assetWithURL:url3_1];
        const CGFloat duration_float3 = CMTimeGetSeconds(asset3.duration);
    }
    
    {
        NSString *path3 = [NSBundle.mainBundle pathForResource:@"test_video3" ofType:@"mov"];
        NSURL *url3_0 = [NSURL fileURLWithPath:@"12345"];
        NSURL *url3_1 = [NSURL fileURLWithPath:path3];
        BOOL yes333_0 = [[NSFileManager defaultManager] fileExistsAtPath:url3_0.path];
        BOOL yes333_1 = [[NSFileManager defaultManager] fileExistsAtPath:url3_1.path];
        AVURLAsset *asset3 = [AVURLAsset assetWithURL:url3_1];
        const CGFloat duration_float3 = CMTimeGetSeconds(asset3.duration);
        printf("");
    }

    WEAKSELF
    [self test:@"AVAsset" tap:^(UIButton *button, NSDictionary *userInfo) {
        STRONGSELF
        NSLog(@"duration=%f", duration_float1);
        CMTime actualTime = kCMTimeZero;
        @autoreleasepool {
            NSLog(@"====== tolerance:MAX ======");
            AVAssetImageGenerator *g = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
            @autoreleasepool {
                CMTime t = kCMTimeZero;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                NSLog(@"begin: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
            @autoreleasepool {
                CMTime t = asset1.duration;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                NSLog(@"end: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
        }
        @autoreleasepool {
            NSLog(@"====== tolerance:0.1 ======");
            AVAssetImageGenerator *g = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
            g.requestedTimeToleranceBefore = CMTimeMake(1, 10);
            g.requestedTimeToleranceAfter = CMTimeMake(1, 10);
            @autoreleasepool {
                CMTime t = kCMTimeZero;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                NSLog(@"begin: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
            @autoreleasepool {
                CMTime t = asset1.duration;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                NSLog(@"end: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
        }
        @autoreleasepool {
            NSLog(@"====== tolerance:0 ======");
            AVAssetImageGenerator *g = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
            g.requestedTimeToleranceBefore = kCMTimeZero;
            g.requestedTimeToleranceAfter = kCMTimeZero;
            @autoreleasepool {
                CMTime t = kCMTimeZero;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                ss_easy_log(@"begin: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
            @autoreleasepool {
                CMTime t = asset1.duration;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                ss_easy_log(@"end: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
        }
    }];
    
    [self test:@"抽帧失败 tolerance=0 部分失败" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"export_part_error_without_tolerance" ofType:@"mov"];
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
        CMTime duration = asset.duration;
        SSAssetImageGenerator *generator = [[SSAssetImageGenerator alloc] initWithAsset:asset size:CGSizeMake(360, 640)];
        generator.generator.requestedTimeToleranceBefore = CMTimeMake(0 * duration.timescale, duration.timescale);
        generator.generator.requestedTimeToleranceAfter = generator.generator.requestedTimeToleranceBefore;
        [weak_s testWithGenerator:generator];
    }];
    
    [self test:@"抽帧失败 tolerance=0.1 都成功" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"export_part_error_without_tolerance" ofType:@"mov"];
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
        CMTime duration = asset.duration;
        SSAssetImageGenerator *generator = [[SSAssetImageGenerator alloc] initWithAsset:asset size:CGSizeMake(360, 640)];
        generator.generator.requestedTimeToleranceBefore = CMTimeMake(0.1 * duration.timescale, duration.timescale);
        generator.generator.requestedTimeToleranceAfter = generator.generator.requestedTimeToleranceBefore;
        [weak_s testWithGenerator:generator];
    }];
    
    [self test:@"抽帧失败 tolerance=0.1 都成功" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"test_avkit2" ofType:@"mp4"];
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
        CMTime duration = asset.duration;
        SSAssetImageGenerator *generator = [[SSAssetImageGenerator alloc] initWithAsset:asset size:CGSizeMake(360, 640)];
        generator.generator.requestedTimeToleranceBefore = CMTimeMake(0.1 * duration.timescale, duration.timescale);
        generator.generator.requestedTimeToleranceAfter = generator.generator.requestedTimeToleranceBefore;
        [weak_s testWithGenerator:generator];
    }];
}

- (void)testWithGenerator:(SSAssetImageGenerator *)generator
{
    CMTime duration = generator.generator.asset.duration;
    NSTimeInterval interval = 0.5;
    
    NSMutableArray *times = @[].mutableCopy;
    CMTime start = kCMTimeZero;
    CMTime end = CMTimeAdd(start, duration);
    
    CMTimeValue increment = interval * duration.timescale;
    CMTimeValue currentValue = start.value;
    
    do {
        CMTime time = CMTimeMake(currentValue, duration.timescale);
        [times addObject:[NSValue valueWithCMTime:time]];
        currentValue += increment;
    } while (currentValue <= end.value);
    
    for (NSValue *timeValue in times) {
        CMTime time = [timeValue CMTimeValue];
        @autoreleasepool {
            // 抽帧
            UIImage *image = [generator generaImageWithEdgeInset:UIEdgeInsetsZero atTime:time];
            if (image) {
                ss_easy_log(@"[generate] generate image success at time: %.2f", CMTimeGetSeconds(time));
            } else {
                ss_easy_log(@"[generate] generate image failed at time: %.2f", CMTimeGetSeconds(time));
            }
        }
    }
}

- (UIImage *)imageWithGenerator:(AVAssetImageGenerator *)generator atTime:(CMTime)requestedTime actualTime:(nullable CMTime *)actualTime error:(NSError * _Nullable * _Nullable)outError
{
    CGImageRef imageRef = [generator copyCGImageAtTime:requestedTime actualTime:actualTime error:outError];
    if (!imageRef) {
        return nil;
    }
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CFRelease(imageRef);
    return image;
}

@end
