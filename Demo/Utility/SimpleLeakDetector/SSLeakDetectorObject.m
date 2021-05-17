//
//  SSLeakDetectorObject.m
//  Beyond
//
//  Created by ZZZ on 2021/3/3.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SSLeakDetectorObject.h"

@implementation SSLeakDetectorObjectItem

- (instancetype)initWithClass:(Class)c pointers:(NSArray<NSNumber *> *)pointers;
{
    self = [self init];
    if (self) {
        _name = NSStringFromClass(c);
        _pointers = pointers;
    }
    return self;
}

- (NSComparisonResult)compare:(SSLeakDetectorObjectItem *)other
{
    if (self.pointers.count > other.pointers.count) {
        return NSOrderedAscending;
    } else if (self.pointers.count < other.pointers.count) {
        return NSOrderedDescending;
    }
    return [self.name compare:other.name];
}

- (BOOL)hasContent:(NSString *)content
{
    NSString *full = self.name.uppercaseString;
    content = content.uppercaseString;

    NSInteger i = 0;
    NSInteger j = 0;
    while (i < full.length && j < content.length) {
        if ([full characterAtIndex:i] == [content characterAtIndex:j]) {
            j++;
        }
        i++;
    }
    return j == content.length;
}

- (BOOL)hasPrefix:(NSString *)prefix
{
    return prefix.length && [self.name.uppercaseString hasPrefix:prefix.uppercaseString];
}

@end

@implementation SSLeakDetectorObject

- (instancetype)initWithDictionary:(NSDictionary<Class, NSArray<NSNumber *> *> *)dictionary
{
    self = [self init];

    NSMutableArray *items = [NSMutableArray array];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(Class c, NSArray<NSNumber *> *obj, BOOL *stop) {
        SSLeakDetectorObjectItem *item = [[SSLeakDetectorObjectItem alloc] initWithClass:c pointers:obj];
        [items addObject:item];
    }];
    [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    _items = items;

    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];
    for (SSLeakDetectorObjectItem *item in items) {
        mapping[item.name] = item;
    }

    return self;
}

@end
