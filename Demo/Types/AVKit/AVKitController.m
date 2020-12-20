//
//  AVKitController.m
//  Beyond
//
//  Created by ZZZ on 2020/12/9.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AVKitController.h"
#import <AVKit/AVKit.h>

@interface AVKitController ()

@end

@implementation AVKitController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    - (void)p_fetchFramesWithModel:(AWEVideoPublishViewModel *)model callback:(void (^)(void))callback {
//        CGFloat scale = [UIScreen mainScreen].scale;
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            if (model.isQuickStoryPictureVideoType) {
//                [self.recordFrames removeAllObjects];
//                [self.recordFrames addObject:@[model.toBeUploadedImage]];
//                ACCBLOCK_INVOKE(callback);
//                return;
//            }
//
//            NSMutableArray *frames = [NSMutableArray array];
//            HTSVideoData *video = model.video;
//
//            NSTimeInterval imageGeneratorBegin = CFAbsoluteTimeGetCurrent();
//            __block CGFloat totalDuration = 0.f;
//            [video.videoAssets enumerateObjectsUsingBlock:^(AVAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
//                CMTime vidLength = asset.duration;
//                CGFloat seconds = CMTimeGetSeconds(vidLength);
//                totalDuration += seconds;
//            }];
//
//            __unused CGFloat player_duration = [self.player getDuration];
//            __unused CGFloat data_duration = [video totalVideoDuration];
//    //        self.player getSourcePreviewImageAtTime:<#(NSTimeInterval)#> preferredSize:<#(CGSize)#> compeletion:<#^(UIImage * _Nullable image, NSTimeInterval atTime)compeletion#>

//            CMTimeRange clipRange = model.recordVideoClipRange.CMTimeRangeValue;
//            if (clipRange.duration.value) {
//                totalDuration = CMTimeGetSeconds(clipRange.duration);
//            }
//
//            NSInteger requiredFramesCount;
//            NSInteger videoMinSeconds = [self.videoConfig videoMinSeconds];
//            if (totalDuration < videoMinSeconds) {
//                requiredFramesCount = (NSInteger)totalDuration;
//                if (!requiredFramesCount) {
//                    requiredFramesCount = 1;
//                }
//            } else {
//                requiredFramesCount = self.maxNumForUpload;
//            }
//
//            //the first frame is at 0.5s,the last frame is 0.5s ahead of the end ,others equal step
//            if (!ACC_FLOAT_EQUAL_ZERO(totalDuration) && requiredFramesCount) {
//                CGFloat step = 0.1;
//                if (requiredFramesCount > 1) {
//                    // 略微缩小步长 避免多个asset时查找当前asset错误
//                    step = MAX((totalDuration - 0.1) / (requiredFramesCount - 1), step);
//                }
//                CGFloat value = 0;
//                if (clipRange.start.value) {
//                    value = CMTimeGetSeconds(clipRange.start);
//                }
//
//                for (int i = 0; i < requiredFramesCount; i++) {
//                    __block CGFloat passSeconds = 0.f;
//                    __block AVAsset *curAsset;
//                    [video.videoAssets enumerateObjectsUsingBlock:^(AVAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
//                        if (passSeconds + CMTimeGetSeconds(asset.duration) > value) {
//                            curAsset = asset;
//                            *stop = YES;
//                        } else {
//                            passSeconds += CMTimeGetSeconds(asset.duration);
//                        }
//                    }];
//
//                    if (![curAsset isKindOfClass:AVURLAsset.class]) {
//                        value += step;
//                        continue;;
//                    }
//
//                    if ([((AVURLAsset *)curAsset).URL.path containsString:@"blankown"]) { // photo
//                        if (curAsset.thumbImage) {
//                            [frames addObject:curAsset.thumbImage];
//                        }
//                    } else { // video
//                        CMTime time;
//                        int32_t timeScale = curAsset.duration.timescale;
//                        if (i == 0 && requiredFramesCount > 1 && value == 0) {
//                            time = CMTimeMake([ACCABTest() requestFrameTimeOptimizationEnabled] ? 0 : timeScale / 2.f, timeScale); // first frame at 0 or 0.5s
//                        } else if ((i == requiredFramesCount - 1) && requiredFramesCount > 1) {
//                            time = CMTimeMake(MAX(curAsset.duration.value - timeScale / 2.f, 0), timeScale); //last frame at 0.5s ahead of the end
//                        } else {
//                            time = CMTimeMake((value - passSeconds) * timeScale, timeScale);
//                        }
//
//                        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:curAsset];
//                        imageGenerator.appliesPreferredTrackTransform = YES;
//                        imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
//                        imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
//                        imageGenerator.maximumSize = CGSizeMake(self.frameSizeForUpload * scale, self.frameSizeForUpload * scale);
//
//                        NSError *error = nil;
//                        CMTime actualTime = kCMTimeZero;
//                        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
//                        AWELogToolError(AWELogToolTagMusic, @"AI music fetch first frame image error: %@", error.description);
//
//                        UIImage *tempImage = [UIImage imageWithCGImage:imageRef];
//                        CGImageRelease(imageRef);
//
//                        // imageRef may be nil if requestedTimeToleranceBefore is kCMTimeZero and time approaches the end of the asset
//                        if (!tempImage) {
//                            imageGenerator.requestedTimeToleranceBefore = kCMTimePositiveInfinity;
//                            imageGenerator.requestedTimeToleranceAfter = kCMTimePositiveInfinity;
//                            imageRef = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
//                            tempImage = [UIImage imageWithCGImage:imageRef];
//                            CGImageRelease(imageRef);
//                        }
//
//                        if (tempImage) {
//                            [frames addObject:tempImage];
//                            [self.imageTimeTable setObject:@(passSeconds + CMTimeGetSeconds(actualTime)) forKey:tempImage];
//                        }
//                    }
//                    value += step;
//                }
//            }
//            //performance track
//            [ACCAssetImageGeneratorTracker trackAssetImageGeneratorWithType:ACCAssetImageGeneratorTypeAIMusic
//                                                                     frames:requiredFramesCount
//                                                                  beginTime:imageGeneratorBegin
//                                                                      extra:model.commonTrackInfoDic];
//            //AWELogToolInfo(@"fetch frame spend time %.2f",CFAbsoluteTimeGetCurrent() - start);
//            [self.recordFrames removeAllObjects];
//            [self appendFrames:frames];
//
//            ACCBLOCK_INVOKE(callback);
//        });
//    }

//    NSString *path = [NSBundle.mainBundle pathForResource:@"test_avkit1" ofType:@"mov"];
    NSString *path = [NSBundle.mainBundle pathForResource:@"test_avkit2" ofType:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
    const CGFloat duration_float = CMTimeGetSeconds(asset.duration);

    WEAKSELF
    [self test:@"AVAsset" tap:^(UIButton *button, NSDictionary *userInfo) {
        STRONGSELF
        NSLog(@"duration=%f", duration_float);
        CMTime actualTime = kCMTimeZero;
        @autoreleasepool {
            NSLog(@"====== tolerance:MAX ======");
            AVAssetImageGenerator *g = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            @autoreleasepool {
                CMTime t = kCMTimeZero;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                NSLog(@"begin: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
            @autoreleasepool {
                CMTime t = asset.duration;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                NSLog(@"end: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
        }
        @autoreleasepool {
            NSLog(@"====== tolerance:0.1 ======");
            AVAssetImageGenerator *g = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            g.requestedTimeToleranceBefore = CMTimeMake(1, 10);
            g.requestedTimeToleranceAfter = CMTimeMake(1, 10);
            @autoreleasepool {
                CMTime t = kCMTimeZero;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                NSLog(@"begin: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
            @autoreleasepool {
                CMTime t = asset.duration;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                NSLog(@"end: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
        }
        @autoreleasepool {
            NSLog(@"====== tolerance:0 ======");
            AVAssetImageGenerator *g = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            g.requestedTimeToleranceBefore = kCMTimeZero;
            g.requestedTimeToleranceAfter = kCMTimeZero;
            @autoreleasepool {
                CMTime t = kCMTimeZero;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                NSLog(@"begin: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
            @autoreleasepool {
                CMTime t = asset.duration;
                UIImage *image = [self imageWithGenerator:g atTime:t actualTime:&actualTime error:nil];
                NSLog(@"end: in=%f out=%f image=%p", CMTimeGetSeconds(t), CMTimeGetSeconds(actualTime), image);
            }
        }
    }];
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
