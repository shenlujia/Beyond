//
//  ImagePickerHandler.h
//  Beyond
//
//  Created by ZZZ on 2021/5/31.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface ImagePickerHandler : NSObject

@property (nonatomic, strong, readonly) UIImagePickerController *picker;

@property (nonatomic, copy) void (^assetBlock)(PHAsset *albumAsset);

- (void)present;

- (UIImage *)imageFromAsset:(PHAsset *)asset;

- (NSData *)dataFromAsset:(PHAsset *)asset;

- (void)requestImageForAsset:(PHAsset *)asset handler:(void (^)(UIImage *image, NSDictionary *info))handler;

- (void)requestImageDataForAsset:(PHAsset *)asset handler:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))handler;

- (void)requestVideoForAsset:(PHAsset *)asset handler:(void (^)(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info))handler;

@end
