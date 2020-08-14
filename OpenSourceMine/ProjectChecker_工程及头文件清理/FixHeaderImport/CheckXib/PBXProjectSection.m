//
//  PBXProjectSection.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "PBXProjectSection.h"
#import "SSCommon.h"
#import "PBXHeader.h"

@implementation PBXProjectSection

- (instancetype)initWithString:(NSString *)string
{
    self = [self init];
    [self resetWithString:string];
    return self;
}

- (void)resetWithString:(NSString *)string
{
    NSArray *components = [string componentsSeparatedByString:@"/ = {"];
    
    if (components.count != 2) {
        PBXLogging([NSString stringWithFormat:@"%@ 切分失败", NSStringFromSelector(_cmd)]);
        return;
    }
    
    NSString *key = components.firstObject;
    key = [components.firstObject componentsSeparatedByString:@"*/"].lastObject;
    key = [key componentsSeparatedByString:@"/*"].firstObject;
    _identifier = [key stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    
    NSArray *pairs = [components.lastObject componentsSeparatedByString:@";"];
    for (NSString *pair in pairs) {
        NSArray *key_value = [pair componentsSeparatedByString:@"="];
        if (key_value.count == 2) {
            NSString *key = [SSCommon trimString:key_value.firstObject];
            NSString *value = [SSCommon trimString:key_value.lastObject];
            if ([key isEqualToString:@"mainGroup"]) {
                _mainGroup = value;
            }
        }
    }
}

@end
