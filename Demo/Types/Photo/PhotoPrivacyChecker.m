//
//  PhotoPrivacyChecker.m
//  Beyond
//
//  Created by ZZZ on 2022/10/9.
//  Copyright © 2022 SLJ. All rights reserved.
//

#import "PhotoPrivacyChecker.h"
#import "SSEasy.h"
#import <Photos/Photos.h>


@implementation PhotoPrivacyChecker

+ (void)install
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
    }];
    
    if (@available(iOS 14, *)) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus status) {
            
        }];
    }
}

@end
