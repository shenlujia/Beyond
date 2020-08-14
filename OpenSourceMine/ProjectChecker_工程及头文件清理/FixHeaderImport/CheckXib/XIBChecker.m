//
//  XIBChecker.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "XIBChecker.h"
#import "SSCommon.h"
#import "FileXibInfo.h"
#import "PBXHeader.h"

@interface XIBChecker ()

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, PBXFileObject *> *codeFiles;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, PBXFileObject *> *xibFiles;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, PBXFileObject *> *imageFiles;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, PBXFileObject *> *otherFiles;

@property (nonatomic, strong, readonly) NSMutableDictionary *staticStringMapping;
@property (nonatomic, strong, readonly) NSMutableDictionary *defineMapping;

@end

@implementation XIBChecker

- (instancetype)initWithObject:(PBXMain *)main group:(PBXGroup *)group
{
    self = [self init];
    if (self) {
        if (!group) {
            group = main.mainGroup;
        }
        _main = main;
        _group = group;
        [self resetFiles];
        [self resetStaticMapping];
    }
    return self;
}

- (NSDictionary<NSString *, NSString *> *)allXibReferences
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [self.xibFiles enumerateKeysAndObjectsUsingBlock:^(NSString *key, PBXFileObject *obj, BOOL *stop) {
        ret[obj.name] = obj.path;
    }];
    return ret;
}

- (void)resetFiles
{
    _codeFiles = [NSMutableDictionary dictionary];
    _xibFiles = [NSMutableDictionary dictionary];
    _imageFiles = [NSMutableDictionary dictionary];
    _otherFiles = [NSMutableDictionary dictionary];
    [self addFilesWithGroup:self.group];
}

- (void)addFilesWithGroup:(PBXGroup *)group
{
    for (PBXFileReference *reference in group.fileReferences.allValues) {
        PBXFileObject *file = [[PBXFileObject alloc] initWithFolder:self.main.path
                                                              group:group
                                                          reference:reference];
        switch (file.reference.fileType) {
            case PBXFileTypeHeader:
            case PBXFileTypeObjc:
            case PBXFileTypeObjcpp: {
                if (self.codeFiles[file.name]) {
                    PBXLogging([NSString stringWithFormat:@"%@ 文件重复", file.name]);
                }
                self.codeFiles[file.name] = file;
                break;
            }
            case PBXFileTypeFileXib:
            case PBXFileTypeStoryboard: {
                if (self.xibFiles[file.name]) {
                    PBXLogging([NSString stringWithFormat:@"%@ 文件重复", file.name]);
                }
                self.xibFiles[file.name] = file;
                break;
            }
            case PBXFileTypeImagePNG:
            case PBXFileTypeImageGIF:
            case PBXFileTypeImageJPEG: {
                if (self.imageFiles[file.name]) {
                    PBXLogging([NSString stringWithFormat:@"%@ 文件重复", file.name]);
                }
                self.imageFiles[file.name] = file;
                break;
            }
            case PBXFileTypeXML:
            case PBXFileTypeFile:
            case PBXFileTypePlist:
            case PBXFileTypeRuby:
            case PBXFileTypeText:
            case PBXFileTypeBundle:
            case PBXFileTypeHTML:
            case PBXFileTypeJSON:
            case PBXFileTypeJS: {
                if (self.otherFiles[file.name]) {
                    if (![file.name.lowercaseString isEqualToString:@"info.plist"]) {
                        PBXLogging([NSString stringWithFormat:@"%@ 文件重复", file.name]);
                    }
                }
                self.otherFiles[file.name] = file;
                break;
            }
            case PBXFileTypeUnknown:
            case PBXFileTypeFramework:
            case PBXFileTypeDylib:
            case PBXFileTypeXcconfig:
            case PBXFileTypeEntitlements:
            case PBXFileTypeAssetcatalog: {
                
                break;
            }
        }
    }
    
    for (PBXGroup *one in group.children.allValues) {
        [self addFilesWithGroup:one];
    }
}

- (void)resetStaticMapping
{
    NSMutableDictionary *staticStringMapping = [NSMutableDictionary dictionary];
    NSMutableDictionary *defineMapping = [NSMutableDictionary dictionary];
    
    for (PBXFileObject *obj in self.codeFiles.allValues) {
        NSData *data = [NSData dataWithContentsOfFile:obj.path];
        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *array = [text componentsSeparatedByString:@"\n"];
        NSSet *invalidPrefixSet = [NSSet setWithArray:@[@" ", @"/", @"\t", @"@", @"+", @"-"]];
        for (NSString *line in array) {
            if (line.length == 0) {
                continue;
            }
            NSString *firstItem = [line substringWithRange:NSMakeRange(0, 1)];
            if ([invalidPrefixSet containsObject:firstItem]) {
                continue;
            }
            if ([line hasPrefix:@"#define"]) {
                NSString *temp = [line substringFromIndex:7];
                temp = [temp stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                NSArray *key_value = [temp componentsSeparatedByString:@" "];
                if (key_value.count == 2) {
                    NSString *key = key_value.firstObject;
                    key = [key stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                    if (key.length <= 6) {
                        continue;
                    }
                    NSMutableArray *values = [NSMutableArray array];
                    NSString *value = key_value.lastObject;
                    value = [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                    if ([value containsString:@"?"] && [value containsString:@":"]) {
                        NSString *twoString = [value componentsSeparatedByString:@"?"].lastObject;
                        NSArray *two = [twoString componentsSeparatedByString:@":"];
                        if (two.count == 2) {
                            NSString *a = [SSCommon fixXibString:two[0]];
                            if (a) {
                                [values addObject:a];
                            }
                            NSString *b = [SSCommon fixXibString:two[1]];
                            if (b) {
                                [values addObject:b];
                            }
                        }
                    }
                    if (values.count == 0) {
                        NSString *a = [SSCommon fixXibString:value];
                        if (a) {
                            [values addObject:a];
                        }
                    }
                    defineMapping[key] = values;
                    continue;
                }
            }
            NSArray *key_value = [line componentsSeparatedByString:@"="];
            if (key_value.count == 2) {
                NSString *key = key_value.firstObject;
                key = [key stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                key = [key componentsSeparatedByString:@" "].lastObject;
                key = [key stringByReplacingOccurrencesOfString:@"*" withString:@""];
                NSString *value = key_value.lastObject;
                value = [value stringByReplacingOccurrencesOfString:@";" withString:@""];
                value = [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
                value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                value = [value stringByReplacingOccurrencesOfString:@"@" withString:@""];
                if (key.length > 6 && value.length) {
                    staticStringMapping[key] = value;
                }
            }
        }
    }
    
    _staticStringMapping = staticStringMapping;
    _defineMapping = defineMapping;
}

- (void)check
{
    NSSet *allRefXibNames = [NSSet setWithArray:self.xibFiles.allKeys];
    
    NSMutableDictionary *xibMapping = [NSMutableDictionary dictionary];
    NSMutableSet *xibInUse = [NSMutableSet set];
    [self.codeFiles enumerateKeysAndObjectsUsingBlock:^(NSString *key, PBXFileObject *file, BOOL *s) {
        NSString *path = file.path;
        FileXibInfo *info = [[FileXibInfo alloc] initWithPath:path];
        for (FileXibOneItem *one in info.xibs) {
            NSString *to_static = self.staticStringMapping[one.xib];
            NSArray *to_define = self.defineMapping[one.xib];
            if (to_static) {
                [xibInUse addObject:to_static];
            } else if (to_define.count) {
                [xibInUse addObjectsFromArray:to_define];
            } else {
                [xibInUse addObject:one.xib];
            }
            xibMapping[one.xib] = one;
        }
    }];
    _inuse = xibInUse;
    _xibMapping = xibMapping;
    
    NSMutableSet *xibNotInUse = [NSMutableSet set];
    for (NSString *xib in self.xibFiles.allKeys) {
        NSString *temp = [xib componentsSeparatedByString:@"."].firstObject;
        if (![xibInUse containsObject:temp]) {
            [xibNotInUse addObject:xib];
        }
    }
    _notInUse = xibNotInUse;
    
    NSMutableSet *xibFound = [NSMutableSet set];
    NSMutableSet *xibNotFound = [NSMutableSet set];
    for (NSString *name in xibInUse) {
        NSString *xib = [name stringByAppendingString:@".xib"];
        NSString *sb = [name stringByAppendingString:@".storyboard"];
        if ([allRefXibNames containsObject:xib] ||
            [allRefXibNames containsObject:sb]) {
            [xibFound addObject:name];
        } else {
            [xibNotFound addObject:name];
        }
    }
    _found = xibFound;
    _notFound = xibNotFound;
    
    [self print];
}

- (void)print
{
    if (_codeFiles.count == 0) {
        return;
    }
    if (_xibFiles.count == 0) {
        return;
    }
    
    XIBChecker *impl = self;
    NSMutableArray *logs = [NSMutableArray array];
    
    NSString *name = impl.group.name;
    [logs addObject:[NSString stringWithFormat:@"====== %@ ======", name ? : @"主工程"]];
    
    NSMutableString *desc = [NSMutableString string];
    [desc appendFormat:@"包含%@", @(impl.xibFiles.count)];
    [desc appendFormat:@", 其中已使用%@", @(impl.found.count)];
    [desc appendFormat:@", 未使用%@", @(impl.notInUse.count)];
    if (impl.notInUse.count) {
        NSArray *a = impl.notInUse.allObjects;
        a = [a sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        [desc appendFormat:@":\n{  %@  }", [a componentsJoinedByString:@"  "]];
    }
    [logs addObject:desc];
    
    NSMutableString *desc2 = [NSMutableString string];
    [desc2 appendFormat:@"代码中引用%@, 未找到%@", @(impl.inuse.count), @(impl.notFound.count)];
    if (impl.notFound.count) {
        [desc2 appendFormat:@":  <资源名>  <文件名>  <所在字符串>"];
    }
    [logs addObject:desc2];
    
    if (impl.notFound.count) {
        NSArray *a = impl.notFound.allObjects;
        a = [a sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        for (NSString *xib in a) {
            FileXibOneItem *oneItem = impl.xibMapping[xib];
            NSString *text = [NSString stringWithFormat:@"%@      < %@ >      %@", xib, oneItem.file, oneItem.text];
            [logs addObject:text];
        }
    }
    
    PBXLogging([logs componentsJoinedByString:@"\n"]);
}

@end
