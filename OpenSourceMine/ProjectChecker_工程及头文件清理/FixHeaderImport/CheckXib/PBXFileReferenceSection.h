//
//  PBXFileReferenceSection.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBXHeader.h"

typedef NS_ENUM(NSInteger, PBXFileType) {
    PBXFileTypeUnknown = 0,
    PBXFileTypeHeader,
    PBXFileTypeObjc,
    PBXFileTypeObjcpp,
    PBXFileTypeJS,
    PBXFileTypeFileXib,
    PBXFileTypeFramework,
    PBXFileTypeImagePNG,
    PBXFileTypeImageGIF,
    PBXFileTypeImageJPEG,
    PBXFileTypeXML,
    PBXFileTypeDylib,
    PBXFileTypePlist,
    PBXFileTypeText,
    PBXFileTypeXcconfig,
    PBXFileTypeBundle,
    PBXFileTypeJSON,
    PBXFileTypeStoryboard,
    PBXFileTypeEntitlements,
    PBXFileTypeFile,
    PBXFileTypeRuby,
    PBXFileTypeAssetcatalog,
    PBXFileTypeHTML,
};

@interface PBXFileReference : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, copy, readonly) NSString *lastKnownFileType;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL includeInIndex;
@property (nonatomic, copy, readonly) NSString *sourceTree;

@property (nonatomic, assign, readonly) PBXGroupSourceTreeType sourceTreeType;

@property (nonatomic, assign, readonly) PBXFileType fileType;

@end

@interface PBXFileReferenceSection : NSObject

@property (nonatomic, copy, readonly) NSDictionary<NSString *, PBXFileReference *> *references;

- (instancetype)initWithString:(NSString *)string;

@end
