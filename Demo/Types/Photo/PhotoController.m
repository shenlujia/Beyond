//
//  PhotoController.m
//  Beyond
//
//  Created by ZZZ on 2021/5/31.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "PhotoController.h"
#import <Photos/Photos.h>
#import "SSEasy.h"
#import "ImagePickerHandler.h"
#import "DeviceAuthority.h"
#import "PhotoPrivacyChecker.h"

@interface PhotoController () <PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) ImagePickerHandler *handler;
@property (nonatomic, strong) PHAsset *lastSelectedAsset;

@end

@implementation PhotoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    WEAKSELF
    
    [self test:@"隐私校验" tap:^(UIButton *button, NSDictionary *userInfo) {
        [PhotoPrivacyChecker test];
    }];
    
    [self test:@"读最后选中的图" tap:^(UIButton *button, NSDictionary *userInfo) {
        STRONGSELF
        [self.handler requestImageForAsset:self.lastSelectedAsset handler:^(UIImage *image, NSDictionary *info) {
            STRONGSELF
            if (image) {
                PRINT_BLANK_LINE
                NSLog(@"info: %@", info);
                NSLog(@"size: (%.2f, %.2f)", image.size.width, image.size.height);
                PRINT_BLANK_LINE
                NSData *data1 = UIImageJPEGRepresentation(image, 0.3);
                NSLog(@"UIImageJPEGRepresentation 会丢失 exif: %@", [self exifInData:data1]);

                PRINT_BLANK_LINE
                NSData *data2 = UIImagePNGRepresentation(image);
                NSLog(@"UIImagePNGRepresentation 会丢失 exif: %@", [self exifInData:data2]);
            }
        }];
    }];
    
    [self test:@"选图" tap:^(UIButton *button, NSDictionary *userInfo) {
        STRONGSELF
        self.handler = [[ImagePickerHandler alloc] init];
        self.handler.assetBlock = ^(PHAsset *asset) {
            STRONGSELF
            self.lastSelectedAsset = asset;
            // option.synchronous = YES，回调才只走一次
            NSLog(@"requestImageForAsset start");
            [self.handler requestImageForAsset:asset handler:^(UIImage *image, NSDictionary *info) {
                STRONGSELF
                if (image) {
                    PRINT_BLANK_LINE
                    NSLog(@"info: %@", info);
                    NSLog(@"size: (%.2f, %.2f)", image.size.width, image.size.height);
                    PRINT_BLANK_LINE
                    NSData *data1 = UIImageJPEGRepresentation(image, 0.3);
                    NSLog(@"UIImageJPEGRepresentation 会丢失 exif: %@", [self exifInData:data1]);

                    PRINT_BLANK_LINE
                    NSData *data2 = UIImagePNGRepresentation(image);
                    NSLog(@"UIImagePNGRepresentation 会丢失 exif: %@", [self exifInData:data2]);
                }
            }];
            NSLog(@"requestImageDataForAsset start");
            [self.handler requestImageDataForAsset:asset handler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                STRONGSELF
                if (imageData) {
                    PRINT_BLANK_LINE
                    NSLog(@"original exif: %@", [self exifInData:imageData]);
                }
            }];
        };
        [self.handler present];
    }];
    
    [self test:@"选图 读取metadata" tap:^(UIButton *button, NSDictionary *userInfo) {
        STRONGSELF
        self.handler = [[ImagePickerHandler alloc] init];
        self.handler.assetBlock = ^(PHAsset *asset) {
            STRONGSELF
            NSData *data = [self.handler dataFromAsset:asset];
            CIImage *image = [CIImage imageWithData:data];
            NSDictionary *properties = [image properties];
            NSLog(@"exif: %@", properties[(NSString *)kCGImagePropertyExifDictionary]);
        };
        [self.handler present];
    }];
    
    [self test:@"选图 修改metadata 写入相册" tap:^(UIButton *button, NSDictionary *userInfo) {
        STRONGSELF
        self.handler = [[ImagePickerHandler alloc] init];
        self.handler.assetBlock = ^(PHAsset *asset) {
            STRONGSELF
            UIImage *image = [self.handler imageFromAsset:asset];
            NSData *data = [self p_image:image setUserComment:[self p_UUIDString]];
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCreationRequest *req = [PHAssetCreationRequest creationRequestForAsset];
                [req addResourceWithType:PHAssetResourceTypePhoto data:data options:nil];
            } completionHandler:^(BOOL success, NSError *error) {
                if (error) {
                    NSLog(@"error = %@", error);
                } else {
                    NSLog(@"success");
                }
            }];
        };
        [self.handler present];
    }];
    
    [self test:@"选图 修改metadata 写入本地" tap:^(UIButton *button, NSDictionary *userInfo) {
        STRONGSELF
        self.handler = [[ImagePickerHandler alloc] init];
        self.handler.assetBlock = ^(PHAsset *asset) {
            STRONGSELF
            UIImage *image = [self.handler imageFromAsset:asset];
            NSString *name = [[NSUUID UUID] UUIDString];
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", name]];
            NSData *data = [self p_image:image setUserComment:[self p_UUIDString]];
            [data writeToFile:path atomically:YES];
            
            NSDictionary *exif1 = nil;
            // CIImage
            {
                CIImage *image = [CIImage imageWithData:data];
                NSDictionary *properties = [image properties];
                exif1 = properties[(NSString *)kCGImagePropertyExifDictionary];
            }
            
            // data
            NSDictionary *exif2 = nil;
            {
                CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
                CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSource, 0,NULL);
                exif2 = (__bridge NSDictionary *)CFDictionaryGetValue(imageInfo, kCGImagePropertyExifDictionary);
                CFRelease(imageInfo);
                CFRelease(imageSource);
            }
            
            // file
            NSDictionary *exif3 = nil;
            {
                NSURL *URL = [NSURL fileURLWithPath:path];
                CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)URL, NULL);
                CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
                exif3 = (__bridge NSDictionary *)CFDictionaryGetValue(imageInfo, kCGImagePropertyExifDictionary);
                CFRelease(imageInfo);
                CFRelease(imageSource);
            }
            PRINT_BLANK_LINE
            NSLog(@"exif: %@", exif3);
            NSParameterAssert([exif1 isEqual:exif2] && [exif2 isEqual:exif3]);
        };
        [self.handler present];
    }];
    
    ss_easy_log(@"PHAuthorizationStatus = %@", @([PHPhotoLibrary authorizationStatus]));
    
    [self test:@"申请老接口权限" tap:^(UIButton *button, NSDictionary *userInfo) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [weak_s p_logAuthorizationStatus:status];
        }];
    }];
    
    [self test:@"申请读写权限" tap:^(UIButton *button, NSDictionary *userInfo) {
        if (@available(iOS 14, *)) {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                [weak_s p_logAuthorizationStatus:status];
            }];
        }
    }];
    
    [self test:@"申请只写权限" tap:^(UIButton *button, NSDictionary *userInfo) {
        if (@available(iOS 14, *)) {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus status) {
                [weak_s p_logAuthorizationStatus:status];
            }];
        }
    }];
}

- (void)p_logAuthorizationStatus:(PHAuthorizationStatus)status
{
    if (@available(iOS 14, *)) {
        PHAuthorizationStatus readwrite = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
        PHAuthorizationStatus add = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelAddOnly];
        ss_easy_log(@"current = %@, readwrite = %@, add = %@", @(status), @(readwrite), @(add));
    }
}

- (NSDictionary *)exifInData:(NSData *)data
{
    NSDictionary *ret = nil;
    if (data.length) {
        CGImageSourceRef imageRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        if (imageRef) {
            NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageRef, 0, NULL));
            ret = [properties objectForKey:(NSString *)kCGImagePropertyExifDictionary];
            CFRelease(imageRef);
        }
    }
    return ret;
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
//    PHObjectChangeDetails *details = changeInstance changeDetailsForObject:<#(nonnull PHObject *)#>
    NSLog(@"%@", changeInstance);
}

- (NSData *)p_image:(UIImage *)image setUserComment:(NSString *)comment
{
    NSData *imageData = UIImagePNGRepresentation(image);
    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    CFStringRef UTI = CGImageSourceGetType(sourceRef);
    
    NSMutableData *destData = [NSMutableData data];
    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)destData, UTI, 1, NULL);
    
    CFDictionaryRef propertiesRef = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL);
    NSDictionary *imageInfo = (__bridge NSDictionary *)propertiesRef;
    
    NSMutableDictionary *metaData = [imageInfo mutableCopy];
    NSMutableDictionary *exif = [[metaData objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    if (!exif) {
        exif = [NSMutableDictionary dictionary];
    }
    exif[(NSString *)kCGImagePropertyExifUserComment] = comment;

    metaData[(NSString *)kCGImagePropertyExifDictionary] = exif;
    
    CGImageDestinationAddImageFromSource(destinationRef, sourceRef, 0, (__bridge CFDictionaryRef)metaData);
    BOOL success = NO;
    success = CGImageDestinationFinalize(destinationRef);
    
    CFRelease(propertiesRef);
    CFRelease(destinationRef);
    CFRelease(sourceRef);
    
    return destData;
}

- (NSString *)p_UUIDString
{
    static NSInteger index = 0;
    NSString *text = [[NSUUID UUID] UUIDString];
    return [NSString stringWithFormat:@"%@: %@", @(++index), text];
}

@end
