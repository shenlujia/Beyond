//
//  PBXOldGroup.m
//  FixHeaderImport
//
//  Created by SLJ on 2019/9/20.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import "PBXOldGroup.h"
#import "SSCommon.h"

@interface PBXOldGroup ()

@property (nonatomic, strong, readonly) NSSet *p_childrenKeys;
@property (nonatomic, strong, readonly) NSMutableDictionary *p_children;

@end

@implementation PBXOldGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        _p_children = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSSet *)childrenKeys
{
    return _p_childrenKeys;
}

- (NSDictionary *)children
{
    return _p_children;
}

- (void)resetItemWithString:(NSString *)string
{
    NSArray *components = [string componentsSeparatedByString:@"= {"];
    if (components.count != 2) {
        return;
    }
    
    NSCharacterSet *trimSet = NSCharacterSet.whitespaceAndNewlineCharacterSet;
    NSString *key = [SSCommon substring:components.firstObject head:@"/" tail:@"/"];
    _key = [SSCommon trimString:key];
    
    for (NSString *line in [components.lastObject componentsSeparatedByString:@";"]) {
        NSArray *a = [line componentsSeparatedByString:@"="];
        if (a.count == 2) {
            NSString *key = [a.firstObject stringByTrimmingCharactersInSet:trimSet];
            NSString *value = [a.lastObject stringByTrimmingCharactersInSet:trimSet];
            if ([key isEqualToString:@"name"]) {
                _name = value;
            } else if ([key isEqualToString:@"path"]) {
                NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\""];
                _path = [value stringByTrimmingCharactersInSet:set];
            } else if ([key isEqualToString:@"children"]) {
                _p_childrenKeys = [self childrenDictionaryWithString:value];
            }
        }
    }
}

- (PBXOldGroup *)childWithKey:(NSString *)key
{
    if (key.length == 0) {
        return nil;
    }
    PBXOldGroup *ret = self.children[key];
    if (ret) {
        return ret;
    }
    for (PBXOldGroup *child in self.children.allValues) {
        ret = [child childWithKey:key];
        if (ret) {
            return ret;
        }
    }
    return nil;
}

- (NSString *)relativePath
{
    NSMutableArray *ret = [NSMutableArray array];
    PBXOldGroup *group = self;
    while (group) {
        if (group.path) {
            [ret insertObject:group.path atIndex:0];
        }
        group = group.parent;
    }
    return [ret componentsJoinedByString:@"/"];
}

- (BOOL)containsKey:(NSString *)key
{
    if (key.length == 0) {
        return NO;
    }
    if ([self.p_childrenKeys containsObject:key]) {
        return YES;
    }
    if (self.children[key]) {
        return YES;
    }
    for (PBXOldGroup *group in self.children.allValues) {
        if ([group containsKey:key]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)insertChildIfNeeded:(PBXOldGroup *)group
{
    if (!group) {
        return NO;
    }
    if ([self.p_childrenKeys containsObject:group.key]) {
        self.p_children[group.key] = group;
        group->_parent = self;
        return YES;
    }
    for (PBXOldGroup *child in self.children.allValues) {
        if ([child insertChildIfNeeded:group]) {
            return YES;
        }
    }
    return NO;
}

- (NSSet *)childrenDictionaryWithString:(NSString *)text
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

@implementation PBXOldGroupParser

+ (PBXOldGroup *)rootGroupWithString:(NSString *)string
{
    string = [SSCommon substring:string
                            head:@"PBXOldGroup section"
                    containsHead:NO
                            tail:@"PBXOldGroup section"
                    containsTail:NO
                           range:NSMakeRange(0, string.length)
                        outRange:nil];
    
    NSMutableArray *items = [NSMutableArray array];
    NSArray *components = [string componentsSeparatedByString:@"};"];
    __block PBXOldGroup *root = nil;
    [components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger idx, BOOL *stop) {
        PBXOldGroup *item = [[PBXOldGroup alloc] init];
        [item resetItemWithString:component];
        if (item.key.length && item.name.length == 0) {
            root = item;
        }
        if (item.key.length) {
            [items addObject:item];
        }
    }];
    
    for (NSInteger i = 0; i < items.count; ++i) {
        for (NSInteger j = i + 1; j < items.count; ++j) {
            PBXOldGroup *a0 = items[i];
            PBXOldGroup *a1 = items[j];
            [a0 insertChildIfNeeded:a1];
            [a1 insertChildIfNeeded:a0];
        }
    }
    
    return root;
}

@end
