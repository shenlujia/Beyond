//
//  PBXHeader.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "PBXHeader.h"
#import <AppKit/AppKit.h>

PBXGroupSourceTreeType PBXGroupSourceTreeTypeValue(NSString *string)
{
    static NSDictionary *sourceTreeTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        ret[@"\"<group>\""] = @(PBXGroupSourceTreeTypeGroup);
        ret[@"SOURCE_ROOT"] = @(PBXGroupSourceTreeType_SOURCE_ROOT);
        ret[@"SDKROOT"] = @(PBXGroupSourceTreeType_SDKROOT);
        ret[@"BUILT_PRODUCTS_DIR"] = @(PBXGroupSourceTreeType_BUILT_PRODUCTS_DIR);
        
        sourceTreeTypes = [ret copy];
    });
    
    NSNumber *type = sourceTreeTypes[string];
    if (!type) {
        PBXLogging([NSString stringWithFormat:@"PBXGroupSourceTreeTypeValue: %@ 没找到", string]);
    }
    return type.integerValue;
}

void PBXLogging(NSString *string)
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        for (NSWindow *window in NSApplication.sharedApplication.windows) {
            NSViewController *controller = window.contentViewController;
            SEL selector = NSSelectorFromString(@"appendLog:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [controller performSelector:selector withObject:string];
#pragma clang diagnostic pop
        }
    }];
}

@implementation PBXHeader

@end
