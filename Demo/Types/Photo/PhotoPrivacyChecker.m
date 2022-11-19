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
#import <AssetsLibrary/ALAssetsLibrary.h>

@interface AWESSDEBUGUtil : NSObject

@end

@implementation AWESSDEBUGUtil

+ (IMP)swizzle:(Class)c selector:(SEL)selector block:(id)block
{
    return ss_method_swizzle(c, selector, block);
}

@end

@interface PhotoPrivacyChecker () <PHPhotoLibraryChangeObserver>

@end

@implementation PhotoPrivacyChecker

+ (void)install
{
    [self swizzleIfNeeded];
}

+ (void)swizzleIfNeeded
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // PHAsset
        {
            Class c = object_getClass([PHAsset class]);
            SEL selector = @selector(fetchAssetsInAssetCollection:options:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, id a, id b) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a, id b);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a, b);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        {
            Class c = object_getClass([PHAsset class]);
            SEL selector = @selector(fetchAssetsWithLocalIdentifiers:options:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, id a, id b) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a, id b);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a, b);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        {
            Class c = object_getClass([PHAsset class]);
            SEL selector = @selector(fetchKeyAssetsInAssetCollection:options:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, id a, id b) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a, id b);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a, b);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        {
            Class c = object_getClass([PHAsset class]);
            SEL selector = @selector(fetchAssetsWithBurstIdentifier:options:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, id a, id b) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a, id b);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a, b);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        {
            Class c = object_getClass([PHAsset class]);
            SEL selector = @selector(fetchAssetsWithOptions:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, id a) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        {
            Class c = object_getClass([PHAsset class]);
            SEL selector = @selector(fetchAssetsWithMediaType:options:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, PHAssetMediaType a, id b) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, PHAssetMediaType a, id b);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a, b);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
      
        // PHAssetCollection
        {
            Class c = object_getClass([PHAssetCollection class]);
            SEL selector = @selector(fetchAssetCollectionsWithLocalIdentifiers:options:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, id a, id b) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a, id b);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a, b);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        {
            Class c = object_getClass([PHAssetCollection class]);
            SEL selector = @selector(fetchAssetCollectionsWithType:subtype:options:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, PHAssetCollectionType a, PHAssetCollectionSubtype b, id c) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, PHAssetCollectionType a, PHAssetCollectionSubtype b, id c);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a, b, c);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        {
            Class c = object_getClass([PHAssetCollection class]);
            SEL selector = @selector(fetchAssetCollectionsContainingAsset:withType:options:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, id a, PHAssetCollectionType b, id c) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a, PHAssetCollectionType b, id c);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a, b, c);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        {
            Class c = object_getClass([PHAssetCollection class]);
            SEL selector = @selector(fetchAssetCollectionsWithALAssetGroupURLs:options:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, id a, id b) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a, id b);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a, b);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        {
            Class c = object_getClass([PHAssetCollection class]);
            SEL selector = @selector(fetchMomentsInMomentList:options:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, id a, id b) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a, id b);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a, b);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        {
            Class c = object_getClass([PHAssetCollection class]);
            SEL selector = @selector(fetchMomentsWithOptions:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^PHFetchResult *(id obj, id a) {
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a);
                TYPE p = (TYPE)imp;
                PHFetchResult *result = p(obj, selector, a);
                [self checkCall:obj selector:selector count:result.count];
                return result;
            }];
        }
        
        // PHPhotoLibrary
        {
            Class c = [PHPhotoLibrary class];
            SEL selector = @selector(registerChangeObserver:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^(id obj, id a) {
                [self checkCall:obj selector:selector];
                typedef PHFetchResult * (*TYPE)(id obj, SEL selector, id a);
                TYPE p = (TYPE)imp;
                return p(obj, selector, a);
            }];
        }
        {
            Class c = object_getClass([PHPhotoLibrary class]);
            SEL selector = @selector(requestAuthorization:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^(id obj, id a) {
                [self checkCall:obj selector:selector];
                typedef void (*TYPE)(id obj, SEL selector, id a);
                TYPE p = (TYPE)imp;
                p(obj, selector, a);
            }];
        }
        if (@available(iOS 14, *)) {
            Class c = object_getClass([PHPhotoLibrary class]);
            SEL selector = @selector(requestAuthorizationForAccessLevel:handler:);
            __block IMP imp = [AWESSDEBUGUtil swizzle:c selector:selector block:^(id obj, PHAccessLevel a, id b) {
                [self checkCall:obj selector:selector];
                typedef void (*TYPE)(id obj, SEL selector, PHAccessLevel a, id b);
                TYPE p = (TYPE)imp;
                p(obj, selector, a, b);
            }];
        }
    });
}

+ (void)checkCall:(id)obj selector:(SEL)selector
{
    [self checkCall:obj selector:selector count:1];
}

+ (void)checkCall:(id)obj selector:(SEL)selector count:(NSInteger)count
{
    ss_easy_log(@"[%@ %@]", NSStringFromClass([obj class]), NSStringFromSelector(selector));
}

+ (void)test
{
    [self swizzleIfNeeded];
    
    PHAssetCollection *collection = [[PHAssetCollection alloc] init];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    PHAsset *asset = [[PHAsset alloc] init];
    PHCollectionList *list = [[PHCollectionList alloc] init];
    
    // PHAsset
    {
        PRINT_BLANK_LINE
        
        [PHAsset fetchAssetsInAssetCollection:collection options:options];
        [PHAsset fetchAssetsWithLocalIdentifiers:@[] options:options];
        [PHAsset fetchKeyAssetsInAssetCollection:collection options:options];
        [PHAsset fetchAssetsWithBurstIdentifier:@"" options:options];
        [PHAsset fetchAssetsWithOptions:options];
        [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        
        PRINT_BLANK_LINE
    }
    {
        PRINT_BLANK_LINE
        
        [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[] options:options];
        [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:options];
        [PHAssetCollection fetchAssetCollectionsContainingAsset:asset withType:PHAssetCollectionTypeAlbum options:options];
        [PHAssetCollection fetchAssetCollectionsWithALAssetGroupURLs:@[] options:options];
        [PHAssetCollection fetchMomentsInMomentList:list options:options];
        [PHAssetCollection fetchMomentsWithOptions:options];

        PRINT_BLANK_LINE
    }
    {
        PRINT_BLANK_LINE
        
        static PhotoPrivacyChecker *checker = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:checker];
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            ss_easy_log(@"status = %@", @(status));
        }];
        if (@available(iOS 14, *)) {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
                ss_easy_log(@"new status = %@", @(status));
            }];
        }
        
        PRINT_BLANK_LINE
    }
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    
}

@end
