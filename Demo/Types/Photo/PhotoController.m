//
//  PhotoController.m
//  Beyond
//
//  Created by ZZZ on 2021/5/31.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "PhotoController.h"
#import <Photos/Photos.h>
#import "Logger.h"
#import "ImagePickerHandler.h"
#import "DeviceAuthority.h"

@interface PhotoController ()

@property (nonatomic, strong) ImagePickerHandler *handler;

@end

@implementation PhotoController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [DeviceAuthority requestPhotoAuthorization:^(PHAuthorizationStatus status) {
        NSLog(@"authorizationStatus %@", @([PHPhotoLibrary authorizationStatus]));
        if (@available(iOS 14, *)) {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
            NSLog(@"authorizationStatusForAccessLevel %@", @(status));
        }
        NSLog(@"requestPhotoAuthorization %@", @(status));
    }];

    WEAKSELF
    
    [self test:@"选图" tap:^(UIButton *button, NSDictionary *userInfo) {
        STRONGSELF
        self.handler = [[ImagePickerHandler alloc] init];
        self.handler.assetBlock = ^(PHAsset *asset) {
            STRONGSELF
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

@end
