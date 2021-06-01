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
