//
//  ImagePickerHandler.m
//  Beyond
//
//  Created by ZZZ on 2021/5/31.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "ImagePickerHandler.h"

@interface ImagePickerHandler () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ImagePickerHandler

- (void)dealloc
{
    [self.picker dismissViewControllerAnimated:NO completion:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
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

- (void)requestImageDataForAsset:(PHAsset *)asset handler:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))handler
{
    if (!asset) {
        if (handler) {
            handler(nil, nil, UIImageOrientationUp, nil);
        }
        return;
    }
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
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

@end
