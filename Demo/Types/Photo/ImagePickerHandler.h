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

@property (nonatomic, copy) void (^assetBlock)(PHAsset *asset);

- (void)present;

- (void)requestImageDataForAsset:(PHAsset *)asset handler:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))handler;

@end
