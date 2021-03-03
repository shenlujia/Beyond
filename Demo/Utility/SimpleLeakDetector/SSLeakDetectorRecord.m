//
//  SSLeakDetectorRecord.m
//  Beyond
//
//  Created by ZZZ on 2021/3/3.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SSLeakDetectorRecord.h"

@implementation SSLeakDetectorRecord

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *nonempty = [NSMutableDictionary dictionary];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSArray *array, BOOL *stop) {
        if (array.count) {
            nonempty[name] = array;
        }
    }];

    NSMutableArray *business = [NSMutableArray array];
    NSString *separator = @"  |  ";
    [nonempty enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSArray *array, BOOL *stop) {
        if ([name hasPrefix:@"CA"] ||
            [name hasPrefix:@"NS"] ||
            [name hasPrefix:@"UI"]) {
            return;
        }
        [business addObject:[NSString stringWithFormat:@"%@%@%@", name, separator, @(array.count)]];
    }];
    [business sortUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        return [a compare:b];
    }];

    NSMutableArray *more_than_once = [NSMutableArray array];
    [business enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSArray *components = [obj componentsSeparatedByString:separator];
        components = @[components.lastObject, components.firstObject];
        if ([components.firstObject integerValue] > 1) {
            [more_than_once addObject:components];
        }
    }];
    [more_than_once sortUsingComparator:^NSComparisonResult(NSArray *a, NSArray *b) {
        NSInteger x = [a.firstObject integerValue];
        NSInteger y = [b.firstObject integerValue];
        if (x == y) {
            return [a.lastObject compare:b.lastObject];
        }
        return x < y ? NSOrderedDescending : NSOrderedAscending;
    }];
    [[more_than_once copy] enumerateObjectsUsingBlock:^(NSArray *a, NSUInteger idx, BOOL *stop) {
        more_than_once[idx] = [NSString stringWithFormat:@"%@%@%@", a.firstObject, separator, a.lastObject];
    }];

    _total = dictionary;
    _nonempty = nonempty;
    _business = business;
    _more_than_once = more_than_once;

//    if (last_nonempty) {
//        NSMutableDictionary *diff = [NSMutableDictionary dictionary];
//        [nonempty enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
//            NSArray *old = last_nonempty[key];
//            NSInteger count = obj.count - old.count;
//            if (count > 0) {
//                diff[key] = @(count);
//            }
//        }];
//
//        NSMutableArray *diffs = [NSMutableArray arrayWithArray:last_diffs];
//        if (diff.count) {
//            [diffs addObject:diff];
//        }
//        _diffs = diffs;
//    }
}

@end
