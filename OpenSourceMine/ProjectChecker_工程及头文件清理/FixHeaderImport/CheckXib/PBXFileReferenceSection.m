//
//  PBXFileReferenceSection.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "PBXFileReferenceSection.h"
#import "SSCommon.h"

@interface PBXFileReference ()

@end

@implementation PBXFileReference

- (void)resetWithString:(NSString *)string
{
    NSRange range = [string rangeOfString:@"/"];
    if (range.location == NSNotFound) {
        return;
    }
    NSString *key = [string substringToIndex:range.location];
    _identifier = [SSCommon trimString:key];

    range = [string rangeOfString:@"{"];
    if (range.location == NSNotFound) {
        return;
    }
    
    static NSDictionary *fileTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        ret[@"sourcecode.c.h"] = @(PBXFileTypeHeader);
        ret[@"sourcecode.c.objc"] = @(PBXFileTypeObjc);
        ret[@"sourcecode.cpp.objcpp"] = @(PBXFileTypeObjcpp);
        ret[@"file.xib"] = @(PBXFileTypeFileXib);
        ret[@"wrapper.framework"] = @(PBXFileTypeFramework);
        ret[@"sourcecode.javascript"] = @(PBXFileTypeJS);
        ret[@"image.png"] = @(PBXFileTypeImagePNG);
        ret[@"image.gif"] = @(PBXFileTypeImageGIF);
        ret[@"image.jpeg"] = @(PBXFileTypeImageJPEG);
        ret[@"text.plist.xml"] = @(PBXFileTypeXML);
        ret[@"text.xml"] = @(PBXFileTypeXML);
        ret[@"\"sourcecode.text-based-dylib-definition\""] = @(PBXFileTypeDylib);
        ret[@"\"compiled.mach-o.dylib\""] = @(PBXFileTypeDylib);
        ret[@"text.html"] = @(PBXFileTypeHTML);
        ret[@"file.bplist"] = @(PBXFileTypePlist);
        ret[@"text"] = @(PBXFileTypeText);
        ret[@"text.xcconfig"] = @(PBXFileTypeXcconfig);
        ret[@"\"wrapper.plug-in\""] = @(PBXFileTypeBundle);
        ret[@"text.json"] = @(PBXFileTypeJSON);
        ret[@"file.storyboard"] = @(PBXFileTypeStoryboard);
        ret[@"text.plist.entitlements"] = @(PBXFileTypeEntitlements);
        ret[@"file"] = @(PBXFileTypeFile);
        ret[@"text.script.ruby"] = @(PBXFileTypeRuby);
        ret[@"folder.assetcatalog"] = @(PBXFileTypeAssetcatalog);
        fileTypes = [ret copy];
    });
    
    NSString *pairs = [string substringFromIndex:NSMaxRange(range)];
    for (NSString *pair in [pairs componentsSeparatedByString:@";"]) {
        NSArray *key_value = [pair componentsSeparatedByString:@"="];
        if (key_value.count == 2) {
            NSString *key = [SSCommon trimString:key_value.firstObject];
            NSString *value = [SSCommon trimString:key_value.lastObject];
            if ([key isEqualToString:@"name"]) {
                _name = value;
            } else if ([key isEqualToString:@"path"]) {
                _path = value;
            } else if ([key isEqualToString:@"includeInIndex"]) {
                _includeInIndex = value.boolValue;
            } else if ([key isEqualToString:@"sourceTree"]) {
                _sourceTree = value;
                _sourceTreeType = PBXGroupSourceTreeTypeValue(value);
            }
            
            else if ([key isEqualToString:@"lastKnownFileType"]) {
                _lastKnownFileType = value;
                NSNumber *type = fileTypes[value];
                _fileType = type.integerValue;
            }
        }
    }
}

@end

@implementation PBXFileReferenceSection

- (instancetype)initWithString:(NSString *)string
{
    self = [self init];
    [self resetWithString:string];
    return self;
}

- (void)resetWithString:(NSString *)string
{
    NSRange range = [string rangeOfString:@"section */"];
    if (range.location != NSNotFound) {
        string = [string substringFromIndex:NSMaxRange(range)];
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *components = [string componentsSeparatedByString:@"};"];
    [components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
        PBXFileReference *obj = [[PBXFileReference alloc] init];
        [obj resetWithString:component];
        if (obj.identifier.length) {
            dictionary[obj.identifier] = obj;
        }
    }];
    _references = dictionary;
}

@end
