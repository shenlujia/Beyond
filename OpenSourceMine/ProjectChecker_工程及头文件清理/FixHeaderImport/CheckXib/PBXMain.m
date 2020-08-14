//
//  PBXMain.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "PBXMain.h"
#import "SSCommon.h"

@interface PBXMain ()

@property (nonatomic, strong, readonly) NSString *rootObject;

@end

@implementation PBXMain

- (instancetype)initWithPath:(NSString *)path
{
    self = [self init];
    _path = path;
    [self resetWithPath:path];
    return self;
}

- (void)resetWithPath:(NSString *)path
{
    NSString *projPath = nil;
    NSArray *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *one in contents) {
        if ([one hasSuffix:@".xcodeproj"]) {
            projPath = [path stringByAppendingPathComponent:one];
            projPath = [projPath stringByAppendingPathComponent:@"project.pbxproj"];
            break;
        }
    }
    
    NSData *data = [NSData dataWithContentsOfFile:projPath];
    if (data.length == 0) {
        NSString *s = [NSString stringWithFormat:@"%@/*.xcodeproj", path];
        PBXLogging([NSString stringWithFormat:@"%@ 找不到工程文件 %@", NSStringFromSelector(_cmd), s]);
        return;
    }
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (text.length == 0) {
        return;
    }
    
    NSArray *sections = [text componentsSeparatedByString:@"/* Begin "];
    
    NSMutableString *basicInfo = [NSMutableString string];
     NSMutableArray *realSections = [NSMutableArray array];
     [sections enumerateObjectsUsingBlock:^(NSString *section, NSUInteger idx, BOOL *stop) {
         NSArray *components = [section componentsSeparatedByString:@"/* End "];
         if (components.count == 1) {
             [basicInfo appendString:section];
         } else if (components.count == 2) {
             [realSections addObject:components.firstObject];
             if (idx + 1 == sections.count) {
                 NSString *temp = components.lastObject;
                 NSRange startRange = [temp rangeOfString:@"section */"];
                 temp = [temp substringFromIndex:NSMaxRange(startRange)];
                 [basicInfo appendString:temp];
             }
         }
    }];
      
    [self resetBasicInfoWithString:basicInfo];

    for (NSString *section in realSections) {
        NSRange nameRange = [section rangeOfString:@" section */"];
        if (nameRange.location == NSNotFound) {
            PBXLogging([NSString stringWithFormat:@"%@ section切分失败", NSStringFromSelector(_cmd)]);
        }
        NSString *name = [section substringToIndex:nameRange.location];
        if ([name isEqualToString:@"PBXGroup"]) {
            _groupSection = [[PBXGroupSection alloc] initWithString:section];
        } else if ([name isEqualToString:@"PBXProject"]) {
            _projectSection = [[PBXProjectSection alloc] initWithString:section];
        } else if ([name isEqualToString:@"PBXFileReference"]) {
            _fileReferenceSection = [[PBXFileReferenceSection alloc] initWithString:section];
        }
    }
    
    NSString *mainGroupKey = self.projectSection.mainGroup;
    if (!mainGroupKey) {
        PBXLogging([NSString stringWithFormat:@"%@ mainGroup不存在", NSStringFromSelector(_cmd)]);
    }
    if (mainGroupKey) {
        _mainGroup = self.groupSection.groups[mainGroupKey];
    }
    if (!self.mainGroup) {
        PBXLogging([NSString stringWithFormat:@"%@ mainGroup解析错误", NSStringFromSelector(_cmd)]);
    }
    
    for (PBXGroup *group in self.groupSection.groups.allValues) {
        for (NSString *key in group.childrenIdentifiers) {
            [group addFileReferenceIfNeeded:self.fileReferenceSection.references[key]];
        }
    }
}

- (void)resetBasicInfoWithString:(NSString *)string
{
    NSRange start = [string rangeOfString:@"{"];
    NSRange end = [string rangeOfString:@"}" options:NSBackwardsSearch];
    if (start.location == NSNotFound || end.location == NSNotFound) {
        PBXLogging([NSString stringWithFormat:@"%@ 切分失败", NSStringFromSelector(_cmd)]);
    }
    
    string = [string substringWithRange:NSMakeRange(NSMaxRange(start), end.location - NSMaxRange(start))];
    NSArray *pairs = [string componentsSeparatedByString:@";"];
    for (NSString *pair in pairs) {
        NSArray *key_value = [pair componentsSeparatedByString:@"="];
        if (key_value.count == 2) {
            NSString *key = [SSCommon trimString:key_value.firstObject];
            NSString *value = [SSCommon trimString:key_value.lastObject];
            if ([key isEqualToString:@"rootObject"]) {
                _rootObject = [SSCommon trimString:[value componentsSeparatedByString:@"/*"].firstObject];
            }
        }
    }
}

@end


