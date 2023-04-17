//
//  SSAssetImageGenerator.m
//  Beyond
//
//  Created by ZZZ on 2023/3/1.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSAssetImageGenerator.h"
#import "SSEasy.h"

#define NSLog ss_easy_log

@implementation AVAsset (SS)

- (AVCaptureVideoOrientation)ss_fixedOrientation
{
    NSArray *tracks = [self tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *track = tracks.firstObject;
    if(!track) {
        return AVCaptureVideoOrientationPortrait;
    }
    CGAffineTransform t = track.preferredTransform;
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
        // Portrait
        return AVCaptureVideoOrientationLandscapeRight;
    } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
        // PortraitUpsideDown
        return AVCaptureVideoOrientationLandscapeLeft;
    } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
        // LandscapeLeft
        return AVCaptureVideoOrientationPortraitUpsideDown;
    } else {
        return AVCaptureVideoOrientationPortrait;
    }
}

- (CGSize)ss_videoSize
{
    CGSize size = CGSizeZero;
    for (AVAssetTrack *track in self.tracks) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            size = track.naturalSize;
            AVCaptureVideoOrientation orientation = [self ss_fixedOrientation];
            if (orientation != AVCaptureVideoOrientationPortrait && orientation != AVCaptureVideoOrientationPortraitUpsideDown) {
                size = CGSizeMake(size.height, size.width);
            }
            
            break;
        }
    }
    return (size.width > 0 && size.height > 0) ? size : CGSizeZero;
}

- (CMTime)ss_videoDuration
{
    AVAssetTrack *track = [self tracksWithMediaType:AVMediaTypeVideo].firstObject;
    return track ? track.timeRange.duration : kCMTimeZero;
}

@end

@interface SSAssetImageGenerator()

@property (nonatomic, strong) AVAssetImageGenerator *generator;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, assign) CMTime duration;

@end

@implementation SSAssetImageGenerator

- (instancetype)initWithAsset:(AVAsset *)asset size:(CGSize)size
{
    if (self = [super init]) {
        _asset = asset;
        _generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        _generator.appliesPreferredTrackTransform = YES;
        _generator.maximumSize = size;
        _generator.requestedTimeToleranceBefore = kCMTimeZero;
        _generator.requestedTimeToleranceAfter = kCMTimeZero;
    }
    return self;
}

- (UIImage *)generaImageWithEdgeInset:(UIEdgeInsets)edgeInset atTime:(CMTime)time
{
    if (!self.generator) {
        NSAssert(NO, @"LVAssetImageGenerator.generator isEmpty!!");
        return nil;
    }
    CMTime duration = self.asset.duration;
    if (CMTimeCompare(time, duration) > 0) {
        NSAssert(NO, @"LVAssetImageGenerator 时间大于duration");
        time = duration;
    }
    
    if (CMTimeCompare(time, kCMTimeZero) < 0) {
        NSAssert(NO, @"LVAssetImageGenerator 时间小于0");
        time = kCMTimeZero;
    }
    NSError *error = nil;
    CMTime actualTime = kCMTimeZero;
    CGImageRef imageRef = [self.generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if (error) {
        NSLog(@"抽帧失败 %@", error);
    }
    if (!imageRef) {
        return nil;
    }
    
    NSLog(@"time=%.3f actualTime=%.3f", CMTimeGetSeconds(time), CMTimeGetSeconds(actualTime));
    
    CGFloat imageWidth = CGImageGetWidth(imageRef);
    CGFloat imageHeight = CGImageGetHeight(imageRef);
    
    
    CGFloat x = imageWidth * edgeInset.left;
    CGFloat y = imageHeight * edgeInset.top;
    CGFloat w = imageWidth * (1.0 - edgeInset.left - edgeInset.right);
    CGFloat h = imageHeight * (1.0 - edgeInset.top - edgeInset.bottom);
    
    CGRect rect = CGRectMake(x, y, w, h);
    
    CGImageRef cropImage = CGImageCreateWithImageInRect(imageRef, rect);
    if (cropImage == NULL) {
        NSAssert(NO, @"LVAssetImageGenerator cropImage是空的!!");
        return nil;
    }
    
    UIImage *image = [UIImage imageWithCGImage:cropImage];
    CGImageRelease(imageRef);
    CGImageRelease(cropImage);
    return image;
}

@end
