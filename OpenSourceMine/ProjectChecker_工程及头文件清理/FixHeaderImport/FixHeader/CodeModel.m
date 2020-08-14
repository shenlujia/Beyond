//
//  CodeModel.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/8/7.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "CodeModel.h"
#import "CodeFile.h"

@interface CodeModel ()

@end

@implementation CodeModel

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = [path copy];
    }
    return self;
}

- (void)updateWithHeaders:(NSDictionary *)headers
{
    // files whiteListHeaders
    NSMutableDictionary *files = [NSMutableDictionary dictionary];
    NSSet *set = [NSSet setWithArray:@[@"h", @"m", @"mm"]];
    NSMutableSet *whiteListHeaders = [NSMutableSet set];
    for (NSString *subpath in [self filesInPath:self.path]) {
        NSString *subname = subpath.lastPathComponent;
        if (subname.pathExtension) {
            if ([set containsObject:subname.pathExtension]) {
                CodeFile *file = [[CodeFile alloc] initWithPath:subpath];
                files[subpath] = file;
            }
            if ([subname.pathExtension isEqualToString:@"h"]) {
                [whiteListHeaders addObject:subname.lowercaseString];
            }
        }
    }
    
    // podspecPath
    NSString *parentPath = [self.path stringByDeletingLastPathComponent];
    NSString *podspecPath = nil;
    for (NSString *name in [NSFileManager.defaultManager contentsOfDirectoryAtPath:parentPath error:nil]) {
        if ([name.pathExtension isEqualToString:@"podspec"]) {
            podspecPath = [parentPath stringByAppendingPathComponent:name];
        }
    }
    if (podspecPath && [NSFileManager.defaultManager fileExistsAtPath:podspecPath]) {
        CodeFile *file = [[CodeFile alloc] initWithPath:podspecPath];
        files[podspecPath] = file;
    }
    
    for (CodeFile *file in files.allValues) {
        [file updateWithHeaders:headers whiteListHeaders:whiteListHeaders];
    }
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
