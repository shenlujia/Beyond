//
//  PhotoController.m
//  Beyond
//
//  Created by ZZZ on 2021/5/31.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "PhotoController.h"
#import <Photos/Photos.h>
#import "ImagePickerHandler.h"
#import "DeviceAuthority.h"

@interface PhotoController ()

@property (nonatomic, strong) ImagePickerHandler *handler;

@end

@implementation PhotoController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [DeviceAuthority requestPhotoAuthorization:nil];

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
                        __unused NSDictionary<NSString *,id> *properties = image.properties;
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
