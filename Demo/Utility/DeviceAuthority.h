//
//  DeviceAuthority.h
//  Beyond
//
//  Created by ZZZ on 2021/6/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@interface DeviceAuthority : NSObject

+ (PHAuthorizationStatus)authorizationStatusForPhoto;

+ (AVAuthorizationStatus)authorizationStatusForVideo;

+ (AVAuthorizationStatus)authorizationStatusForAudio;

+ (BOOL)isiOS14PhotoLimited;

+ (void)requestPhotoAuthorization:(void(^)(PHAuthorizationStatus status))completion;

@end
