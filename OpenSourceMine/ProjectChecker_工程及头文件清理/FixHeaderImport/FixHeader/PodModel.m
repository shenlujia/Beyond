//
//  PodModel.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/8/7.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "PodModel.h"
#import "SSCommon.h"

@implementation PodItem

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = [path copy];
        [self privateInit];
    }
    return self;
}

- (void)privateInit
{
    _name = [self.path lastPathComponent];
    NSMutableDictionary *items = [NSMutableDictionary dictionary];
    NSSet *headerSet = [NSSet setWithArray:@[@"h"]];
    for (NSString *subpath in [self filesInPath:self.path]) {
        NSString *subname = subpath.lastPathComponent;
        if (subname.pathExtension) {
            if ([headerSet containsObject:subname.pathExtension]) {
                items[subname] = [NSString stringWithFormat:@"#import <%@/%@>", _name, subname];
            }
        }
    }
    _items = items;
}

- (NSArray *)filesInPath:(NSString *)path
{
    NSMutableArray *ret = [NSMutableArray array];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    for (NSString *name in [fileManager contentsOfDirectoryAtPath:path error:nil]) {
        NSString *subpath = [path stringByAppendingPathComponent:name];
        BOOL isDirectory = NO;
        if ([fileManager fileExistsAtPath:subpath isDirectory:&isDirectory]) {
            if (isDirectory) {
                NSArray *files = [self filesInPath:subpath];
                if (files.count) {
                    [ret addObjectsFromArray:files];
                }
            } else {
                [ret addObject:subpath];
            }
        }
    }
    return ret;
}

@end

@interface PodModel ()

@end

@implementation PodModel

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = [path copy];
        [self privateInit];
    }
    return self;
}

- (void)privateInit
{
    NSError *error = nil;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *path = self.path;
    
    // Pods里面的Headers文件夹
    NSString *podPath = [path stringByAppendingPathComponent:@"Pods/Headers/Public"];
    if (![fileManager fileExistsAtPath:podPath]) {
        _error = [SSCommon errorWithError:error description:@"找不到Pods文件夹"];
        return;
    }
    
    // 读取所有pod
    NSArray *podsArray = [fileManager contentsOfDirectoryAtPath:podPath error:&error];
    if (error) {
        _error = [SSCommon errorWithError:error description:@"读取Pods文件夹失败"];
        return;
    }
    
    NSMutableDictionary *models = [NSMutableDictionary dictionary];
    for (NSString *string in podsArray) {
        NSString *subpath = [podPath stringByAppendingPathComponent:string];
        BOOL isDirectory = NO;
        if ([fileManager fileExistsAtPath:subpath isDirectory:&isDirectory]) {
            if (isDirectory) {
                PodItem *model = [[PodItem alloc] initWithPath:subpath];
                if (model.name) {
                    models[model.name] = model;
                }
            }
        }
    }
    _pods = models;
}

@end
