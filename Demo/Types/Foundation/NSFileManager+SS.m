//
//  NSFileManager+SS.m
//  Beyond
//
//  Created by ZZZ on 2021/9/14.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "NSFileManager+SS.h"

@implementation NSFileManager (SS)

- (NSArray *)acc_contentsAtPath:(NSString *)path error:(NSError **)error
{
    NSError *outError = nil;
    NSArray *contents = [self contentsOfDirectoryAtPath:path error:&outError];
    if (outError) {
        if (error) {
            *error = outError;
        }
        return nil;
    }
    
    NSMutableArray *ret = [NSMutableArray array];
    for (NSString *content in contents) {
        NSString *subpath = [path stringByAppendingPathComponent:content];
        BOOL isDirectory = NO;
        if ([self fileExistsAtPath:subpath isDirectory:&isDirectory]) {
            if (isDirectory) {
                NSArray *items = [self acc_contentsAtPath:subpath error:&outError];
                if (outError) {
                    break;
                }
                if (items.count) {
                    [ret addObjectsFromArray:items];
                }
            } else {
                [ret addObject:subpath];
            }
        }
    }
    
    if (outError) {
        if (error) {
            *error = outError;
        }
        return nil;
    }
    
    return ret;
}

@end
