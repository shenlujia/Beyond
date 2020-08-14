//
//  PBXFileObject.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "PBXFileObject.h"

@implementation PBXFileObject

- (instancetype)initWithFolder:(NSString *)folder
                         group:(PBXGroup *)group
                     reference:(PBXFileReference *)reference
{
    self = [self init];
    if (self) {
        _folderGroup = group;
        _reference = reference;
        
        if (reference.name) {
            _name = reference.name;
        } else if (reference.path) {
            _name = reference.path;
        }
        [self resetPathWithFolder:folder];
    }
    return self;
}

- (void)resetPathWithFolder:(NSString *)folder
{
    NSString *path = self.reference.path;
    if (self.reference.sourceTreeType == PBXGroupSourceTreeType_SOURCE_ROOT ||
        self.reference.sourceTreeType == PBXGroupSourceTreeType_SDKROOT) {
        _path = path;
        return;
    }
    
    NSString *relativePath = [folder stringByAppendingPathComponent:[self.folderGroup relativePath]];
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    path = [path stringByTrimmingCharactersInSet:characterSet];
    if (self.reference.includeInIndex) {
        _path = [folder stringByAppendingPathComponent:path];
    } else {
        _path = [relativePath stringByAppendingPathComponent:path];
    }
    _path = [relativePath stringByAppendingPathComponent:path];
    
    NSMutableArray *components = [[_path componentsSeparatedByString:@"/"] mutableCopy];
    NSInteger index = 1;
    while (index < components.count) {
        if (index > 0 && [components[index] isEqualToString:@".."]) {
            [components removeObjectsInRange:NSMakeRange(index - 1, 2)];
            --index;
        } else {
            ++index;
        }
    }
    _path = [components componentsJoinedByString:@"/"];
    
    if (self.reference.sourceTreeType != PBXGroupSourceTreeType_BUILT_PRODUCTS_DIR) {
        if (![NSFileManager.defaultManager fileExistsAtPath:self.path]) {
            PBXLogging([NSString stringWithFormat:@"%@ %@ 不存在", NSStringFromSelector(_cmd), self.path]);
        }
    }
}

@end
