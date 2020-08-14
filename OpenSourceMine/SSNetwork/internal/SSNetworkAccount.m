//
//  SSNetworkAccount.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/14.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSNetworkAccount.h"
#import "SSNetworkConfiguration.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#import <MJExtension.h>
#pragma clang diagnostic pop

@implementation SSNetworkAccount

- (instancetype)init
{
    self = [super init];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    [self mj_decode:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self mj_encode:aCoder];
}

+ (instancetype)unarchivedObject
{
    SSNetworkAccount *object = nil;
    NSString *path = [self archivePath];
    @try {
        object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    } @catch (NSException *exception) {
        
    }
    object = [object isKindOfClass:SSNetworkAccount.class] ? object : nil;
    // 解析失败
    if (!object) {
        // 下面的clearSession会去获取accout，可能死循环
        // 因此这里先archive
        object = [[SSNetworkAccount alloc] init];
        [object archive];
        // 部分请求依赖Account 因此清除session缓存
        SSNetworkConfiguration *configuration = [SSNetworkConfiguration sharedInstance];
        [configuration clearSession];
    }
    return object;
}

- (BOOL)archive
{
    NSString *path = [SSNetworkAccount archivePath];
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

+ (NSString *)archivePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths.firstObject stringByAppendingPathComponent:@"network"];
    NSFileManager *manager = [[NSFileManager alloc] init];
    [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return [path stringByAppendingPathComponent:@"account"];
}

@end
