//
//  PhotoController.m
//  Beyond
//
//  Created by ZZZ on 2021/5/31.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "PhotoController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import "SSEasy.h"
#import "ImagePickerHandler.h"
#import "DeviceAuthority.h"
#import "PhotoPrivacyChecker.h"
#import "AssetViewer.h"

@interface PhotoController () <PHPhotoLibraryChangeObserver, PHLivePhotoViewDelegate>

@property (nonatomic, strong) ImagePickerHandler *handler;
@property (nonatomic, strong) PHAsset *lastSelectedAsset;

@end

@implementation PhotoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 创建并配置PHLivePhotoView
    PHLivePhotoView *livePhotoView = [[PHLivePhotoView alloc] initWithFrame:CGRectMake(10, 450, (self.view.bounds.size.width - 20) / 3, 100)];
    livePhotoView.backgroundColor = [UIColor.cyanColor colorWithAlphaComponent:0.5];
    livePhotoView.delegate = self;
    livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
    livePhotoView.clipsToBounds = YES;
    [self.view addSubview:livePhotoView];
    
    {
        NSString *photoPath = [NSBundle.mainBundle pathForResource:@"IMG_5664-0002" ofType:@"jpg"];
        NSString *videoPath = [NSBundle.mainBundle pathForResource:@"IMG_5664" ofType:@"mp4"];
        UIImage *placeholderImage = [UIImage imageWithContentsOfFile:photoPath];
        
        NSURL *URL1 = [NSURL fileURLWithPath:photoPath];
        NSURL *URL2 = [NSURL fileURLWithPath:videoPath];
        [PHLivePhoto requestLivePhotoWithResourceFileURLs:@[URL1, URL2] placeholderImage:placeholderImage targetSize:CGSizeZero contentMode:PHImageContentModeAspectFill resultHandler:^(PHLivePhoto *livePhoto, NSDictionary *info) {
            NSLog(@"requestLivePhoto finish: %@ %@", livePhoto, info);
            if ([info[PHLivePhotoInfoIsDegradedKey] boolValue]) {
                return;
            }
            if (livePhoto) {
                livePhotoView.livePhoto = livePhoto;
                [livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
            }
        }];
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHAssetCreationRequest *req = [PHAssetCreationRequest creationRequestForAsset];
            [req addResourceWithType:PHAssetResourceTypePhoto fileURL:URL1 options:nil];
            [req addResourceWithType:PHAssetResourceTypePairedVideo fileURL:URL2 options:nil];

        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
        }];
        
    }
    
//    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];

    WEAKSELF
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test_photo_heic" ofType:@"jpg"];
    NSData *jj = [NSData dataWithContentsOfFile:path];
    
    uint8_t flag = 0;
    [jj getBytes:&flag length:1];
    
    if (flag == 0x00) {
        if (jj.length >= 12) {
            NSString *s = [[NSString alloc] initWithData:[jj subdataWithRange:NSMakeRange(8, 4)] encoding:NSASCIIStringEncoding];
            printf("");
        }
    }
    
//    if let str = String(data: self[8...11], encoding: .ascii) {
//        let HEICBitMaps = Set(["heic", "heis", "heix", "hevc", "hevx"])
//        if HEICBitMaps.contains(str) {
//            return .HEIC
//        }
//        let HEIFBitMaps = Set(["mif1", "msf1"])
//        if HEIFBitMaps.contains(str) {
//            return .HEIF
//        }
//    }
    
    
//    ImageFormat fff = [TestSwiftA typeWithData:jj];
    
    [self test:@"展示图片视频" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:[[NSBundle mainBundle] pathForResource:@"IMG_5664-0002" ofType:@"jpg"]];
        [array addObject:[[NSBundle mainBundle] pathForResource:@"IMG_5665" ofType:@"jpg"]];
        [array addObject:[[NSBundle mainBundle] pathForResource:@"IMG_5664" ofType:@"mp4"]];
        [array addObject:[[NSBundle mainBundle] pathForResource:@"IMG_5664" ofType:@"HEIC"]];
        [AssetViewer showObjects:array inContainer:weak_s];
    }];
    
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
        self.handler.assetBlock = ^(PHAsset *albumAsset) {
            STRONGSELF
            self.lastSelectedAsset = albumAsset;
            // option.synchronous = YES，回调才只走一次
            NSLog(@"requestImageForAsset start");
            [self.handler requestImageForAsset:albumAsset handler:^(UIImage *image, NSDictionary *info) {
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
            [self.handler requestImageDataForAsset:albumAsset handler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                STRONGSELF
                if (imageData) {
                    PRINT_BLANK_LINE
                    NSLog(@"original exif: %@", [self exifInData:imageData]);
                }
            }];
            
            if (albumAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
//                PHImageManager *imageManager = [PHImageManager defaultManager];
//                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//                options.synchronous = NO;
//                
//                [imageManager requestLivePhotoForAsset:asset targetSize:CGSizeMake(300, 300) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
//                    if (livePhoto) {
//                        // 在这里可以对获取到的PHLivePhoto进行操作，比如显示在PHLivePhotoView中
//                        NSLog(@"成功获取到PHLivePhoto");
//                    } else {
//                        NSLog(@"获取PHLivePhoto失败");
//                    }
//                    
//                    if (livePhoto) {
//                        livePhotoView.livePhoto = livePhoto;
//                        [livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
//                    }
//                }];
                
                __block NSData *photoData = nil;
                __block NSString *videoPath = nil;
                dispatch_group_t group = dispatch_group_create();
                
                dispatch_group_enter(group);
                [self.handler requestImageDataForAsset:albumAsset handler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    photoData = imageData;
                    dispatch_group_leave(group);
                }];
                
                dispatch_group_enter(group);
                [self.handler requestVideoForAsset:albumAsset handler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                    AVURLAsset *videoAsset = (AVURLAsset *)asset;
                    videoPath = videoAsset.URL.path;
                    dispatch_group_leave(group);
                }];
                
                dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                    if (photoData && videoPath) {
                        NSString *imageName = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
                        NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
                        [photoData writeToFile:imagePath atomically:YES];
                        
                        NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
                        NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
                        
                        [PHLivePhoto requestLivePhotoWithResourceFileURLs:@[imageURL, videoURL] placeholderImage:nil targetSize:CGSizeZero contentMode:PHImageContentModeAspectFill resultHandler:^(PHLivePhoto *livePhoto, NSDictionary *info) {
                            NSLog(@"requestLivePhoto finish: %@ %@", livePhoto, info);
                            
                            if (livePhoto) {
                                livePhotoView.livePhoto = livePhoto;
                                [livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleHint];
                            }
                        }];
                    }
                });
            }
            
            
//            [PHLivePhoto requestLivePhotoWithResourceFileURLs:@[URL1, URL2] placeholderImage:nil targetSize:CGSizeZero contentMode:PHImageContentModeAspectFill resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nonnull info) {
//                NSLog(@"requestLivePhoto finish: %@ %@", livePhoto, info);
//                
//                if (livePhoto) {
//                    livePhotoView.livePhoto = livePhoto;
//                    [livePhotoView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
//                }
//            }];
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

#pragma mark - PHLivePhotoViewDelegate

- (BOOL)livePhotoView:(PHLivePhotoView *)livePhotoView canBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
    return YES;
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
    
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle
{
    
}

#pragma mark - Private

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
