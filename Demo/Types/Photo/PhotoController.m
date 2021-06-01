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
            [self.handler requestImageDataForAsset:asset handler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                if (imageData) {
                    CIImage *image = [CIImage imageWithData:imageData];
                    if (image) {
                        NSDictionary *properties = image.properties;
                        NSDictionary *exif = [properties objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                        __unused id kkk = [exif objectForKey:(NSString *)kCGImagePropertyExifUserComment];
                        NSLog(@"");
                    }

                    CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
                    __unused NSDictionary *dict =  (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(cImageSource, 0, NULL));
                    NSLog(@"");
                }

            }];
        };
        [self.handler present];
    }];
}

@end
