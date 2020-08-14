//
//  PBXGroupSection.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/23.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "PBXGroupSection.h"
#import "SSCommon.h"

@interface PBXGroup ()

@property (nonatomic, strong, readonly) NSMutableDictionary *p_children;
@property (nonatomic, strong, readonly) NSMutableDictionary *p_fileReferences;

@end

@implementation PBXGroup

- (NSDictionary *)children
{
    return _p_children;
}

- (NSDictionary *)fileReferences
{
    return _p_fileReferences;
}

- (void)resetWithString:(NSString *)string
{
    _p_children = [NSMutableDictionary dictionary];
    _p_fileReferences = [NSMutableDictionary dictionary];
    NSArray *components = [string componentsSeparatedByString:@"= {"];
    if (components.count != 2) {
        return;
    }
    
    NSString *key = components.firstObject;
    key = [key componentsSeparatedByString:@"/"].firstObject;
    _identifier = [SSCommon trimString:key];
    
    NSString *pairs = components.lastObject;
    for (NSString *pair in [pairs componentsSeparatedByString:@";"]) {
        NSArray *key_value = [pair componentsSeparatedByString:@"="];
        if (key_value.count == 2) {
            NSString *key = [SSCommon trimString:key_value.firstObject];
            NSString *value = [SSCommon trimString:key_value.lastObject];
            if ([key isEqualToString:@"name"]) {
                _name = value;
            } else if ([key isEqualToString:@"path"]) {
                NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\""];
                _path = [value stringByTrimmingCharactersInSet:set];
            } else if ([key isEqualToString:@"sourceTree"]) {
                _sourceTree = value;
                _sourceTreeType = PBXGroupSourceTreeTypeValue(value);
            }
            else if ([key isEqualToString:@"children"]) {
                _childrenIdentifiers = [self childrenIdentifiersWithString:value];
            }
        }
    }
}

- (NSString *)relativePath
{
    NSMutableArray *ret = [NSMutableArray array];
    PBXGroup *group = self;
    while (group) {
        if (group.path) {
            [ret insertObject:group.path atIndex:0];
        }
        if (group.sourceTreeType == PBXGroupSourceTreeType_SOURCE_ROOT ||
            group.sourceTreeType == PBXGroupSourceTreeType_SDKROOT) {
            break;
        }
        group = group.parent;
    }
    return [ret componentsJoinedByString:@"/"];
}

- (void)addFileReferenceIfNeeded:(PBXFileReference *)reference
{
    if (reference.identifier) {
        if ([self.childrenIdentifiers containsObject:reference.identifier]) {
            self.p_fileReferences[reference.identifier] = reference;
        }
    }
}

- (BOOL)addChildIfNeeded:(PBXGroup *)group
{
    if (!group) {
        return NO;
    }
    if ([self.childrenIdentifiers containsObject:group.identifier]) {
        self.p_children[group.identifier] = group;
        group->_parent = self;
        return YES;
    }
    for (PBXGroup *child in self.p_children.allValues) {
        if ([child addChildIfNeeded:group]) {
            return YES;
        }
    }
    return NO;
}

- (NSSet *)childrenIdentifiersWithString:(NSString *)text
{
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"()"];
    text = [text stringByTrimmingCharactersInSet:characterSet];
    
    NSMutableSet *ret = [NSMutableSet set];
    for (NSString *line in [text componentsSeparatedByString:@","]) {
        NSArray *array = [line componentsSeparatedByString:@"/*"];
        NSString *key = [SSCommon trimString:array.firstObject];
        if (key.length) {
            [ret addObject:key];
        }
    }
    return ret;
}

@end

@implementation PBXGroupSection

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
    NSMutableDictionary *groups = [NSMutableDictionary dictionary];
    NSArray *components = [string componentsSeparatedByString:@"};"];
    [components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
        PBXGroup *group = [[PBXGroup alloc] init];
        [group resetWithString:component];
        if (group.identifier.length) {
            groups[group.identifier] = group;
        }
    }];
    _groups = groups;
    
    NSArray *array = groups.allValues;
    for (NSInteger i = 0; i < array.count; ++i) {
        for (NSInteger j = i + 1; j < array.count; ++j) {
            PBXGroup *group0 = array[i];
            PBXGroup *group1 = array[j];
            [group0 addChildIfNeeded:group1];
            [group1 addChildIfNeeded:group0];
        }
    }
}

@end
