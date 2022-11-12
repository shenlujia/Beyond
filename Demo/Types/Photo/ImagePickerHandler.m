//
//  ImagePickerHandler.m
//  Beyond
//
//  Created by ZZZ on 2021/5/31.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "ImagePickerHandler.h"
#import "DontLikeCommon.h"
#import "SSEasy.h"

@interface ImagePickerHandler () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ImagePickerHandler

- (void)dealloc
{
    NSLog(@"~ImagePickerHandler");
    [self.picker dismissViewControllerAnimated:NO completion:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"ImagePickerHandler");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = NO;
        picker.navigationBar.barTintColor = UIColor.blackColor;
        picker.navigationBar.tintColor = UIColor.cyanColor;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        _picker = picker;
    }
    return self;
}

- (void)present
{
    id<UIApplicationDelegate> appDelegate = UIApplication.sharedApplication.delegate;
    UIViewController *controller = appDelegate.window.rootViewController;
    [controller presentViewController:self.picker animated:YES completion:nil];
}

- (void)requestImageForAsset:(PHAsset *)asset handler:(void (^)(UIImage *image, NSDictionary *info))handler
{
    if (!asset) {
        if (handler) {
            handler(nil, nil);
        }
        return;
    }

    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = YES;

    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:options resultHandler:handler];
}

- (void)requestImageDataForAsset:(PHAsset *)asset handler:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))handler
{
    if (!asset) {
        if (handler) {
            handler(nil, nil, UIImageOrientationUp, nil);
        }
        return;
    }
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.networkAccessAllowed = YES;

    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageDataForAsset:asset options:options resultHandler:handler];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    NSURL *URL = info[UIImagePickerControllerReferenceURL];
    URL = [URL isKindOfClass:[NSURL class]] ? URL : nil;
    if (URL) {
        PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[URL] options:nil];
        PHAsset *asset = result.firstObject;
        if (self.assetBlock && asset) {
            self.assetBlock(asset);
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)imageFromAsset:(PHAsset *)asset
{
    if (!asset) {
        return nil;
    }
    
    __block UIImage *ret = nil;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;

    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        ret = result;
    }];
    return ret;
}

- (NSData *)dataFromAsset:(PHAsset *)asset
{
    if (!asset) {
        return nil;
    }
    
    __block NSData *ret = nil;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.version = PHImageRequestOptionsVersionOriginal;

    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        ret = imageData;
    }];
    return ret;
}

@end
