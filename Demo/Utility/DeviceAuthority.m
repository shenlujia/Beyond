//
//  DeviceAuthority.m
//  Beyond
//
//  Created by ZZZ on 2021/6/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "DeviceAuthority.h"

static NSInteger PhotoLibrayAuthorizationStatus = PHAuthorizationStatusNotDetermined;
static NSInteger VideoAVAuthorizationStatus = AVAuthorizationStatusNotDetermined;
static NSInteger AudioAVAuthorizationStatus = AVAuthorizationStatusNotDetermined;

@implementation DeviceAuthority

+ (PHAuthorizationStatus)authorizationStatusForPhoto
{
    if (PhotoLibrayAuthorizationStatus == PHAuthorizationStatusNotDetermined) {
        PhotoLibrayAuthorizationStatus = [PHPhotoLibrary authorizationStatus];
    }
    return (PHAuthorizationStatus)PhotoLibrayAuthorizationStatus;
}

+ (AVAuthorizationStatus)authorizationStatusForVideo
{
    if (VideoAVAuthorizationStatus == AVAuthorizationStatusNotDetermined) {
        VideoAVAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    }
    return (AVAuthorizationStatus)VideoAVAuthorizationStatus;
}

+ (AVAuthorizationStatus)authorizationStatusForAudio
{
    if (AudioAVAuthorizationStatus == AVAuthorizationStatusNotDetermined) {
        AudioAVAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    }
    return (AVAuthorizationStatus)AudioAVAuthorizationStatus;
}

+ (BOOL)isiOS14PhotoLimited
{
#ifdef __IPHONE_14_0 //xcode12
    if (@available(iOS 14.0, *)) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
        return status == PHAuthorizationStatusLimited;
    }
#endif
    return NO;
}

+ (void)requestPhotoAuthorization:(void(^)(PHAuthorizationStatus status))completion
{
    PHAuthorizationStatus status = [self authorizationStatusForPhoto];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(status);
                }
            });
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(status);
            }
        });
    }
}

@end
