//
//  SSFoundationController.m
//  Beyond
//
//  Created by ZZZ on 2021/3/17.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SSFoundationController.h"
#import "MacroHeader.h"
#import "DeviceAuth.h"

@interface SSFoundationDEBUGLogA : NSObject

@end

@implementation SSFoundationDEBUGLogA

- (NSString *)description
{
    return @"SSFoundationDEBUGLogA";
}

@end

@interface SSFoundationDEBUGLogB : NSObject

@end

@implementation SSFoundationDEBUGLogB

- (NSString *)debugDescription
{
    return @"SSFoundationDEBUGLogB";
}

@end

@interface SSFoundationController ()

@end

@implementation SSFoundationController

- (void)viewDidLoad
{
    [super viewDidLoad];

    WEAKSELF
    [self test:@"先将NSObject+DEBUGLog屏蔽 debugDescription用于控制台默认调用description" tap:^(UIButton *button, NSDictionary *userInfo) {
        PRINT_BLANK_LINE
        NSLog(@"%p", weak_s);
        NSLog(@"%@", weak_s);
        NSLog(@"%@", [weak_s description]);
        NSLog(@"%@", [weak_s debugDescription]);

        PRINT_BLANK_LINE
        SSFoundationDEBUGLogA *a = [[SSFoundationDEBUGLogA alloc] init];
        NSLog(@"%p", a);
        NSLog(@"%@", a);
        NSLog(@"%@", [a description]);
        NSLog(@"%@", [a debugDescription]);

        PRINT_BLANK_LINE
        SSFoundationDEBUGLogB *b = [[SSFoundationDEBUGLogB alloc] init];
        NSLog(@"%p", b);
        NSLog(@"%@", b);
        NSLog(@"%@", [b description]);
        NSLog(@"%@", [b debugDescription]);
    }];

    [self test:@"DeviceAuth requestPhotoLibraryPermission" tap:^(UIButton *button, NSDictionary *userInfo) {
        [DeviceAuth requestPhotoLibraryPermission:^(BOOL success) {
            NSLog(@"requestPhotoLibraryPermission: %@", @(success));
        }];
    }];

    [self test:@"fetchAssets" tap:^(UIButton *button, NSDictionary *userInfo) {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
        NSArray<NSSortDescriptor *> *sortDescriptor = @[
            [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(creationDate)) ascending:YES]
        ];
        fetchOptions.sortDescriptors = sortDescriptor;
        fetchOptions.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary | PHAssetSourceTypeiTunesSynced;
        PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithOptions:fetchOptions];
        NSLog(@"fetchAssetsWithOptions %@", @(result.count));
    }];
}

@end
