//
//  SimpleLeakDetector.m
//  Beyond
//
//  Created by ZZZ on 2021/3/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SimpleLeakDetector.h"
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import "SimpleLeakDetectorMRC.h"
#import "SimpleLeakDetectorInternal.h"
#import <objc/runtime.h>

@implementation SimpleLeakDetector

+ (void)start
{
    [FBAssociationManager hook];
    leak_detector_register_init();
}

+ (NSArray *)allLiveObjects
{
    NSMutableArray *liveObjects = [NSMutableArray array];
    leak_detector_enum_live_objects(^(const char *class_name, long long pointer) {
        [liveObjects addObject:(__bridge NSObject *)((void *)pointer)];
    });
    return liveObjects;
}

+ (NSArray *)retainedObjectsWithObject:(id)object
{
    return [SimpleLeakDetectorInternal retainedObjectsWithObject:object];
}

+ (NSArray *)ownersOfObject:(id)object
{
    NSMutableArray *ret = [NSMutableArray array];
    NSArray *liveObjects = [self allLiveObjects];
    for (NSObject *liveObject in liveObjects) {
        NSArray *retained = [self retainedObjectsWithObject:liveObject];
        if ([retained containsObject:object]) {
            [ret addObject:liveObject];
        }
    }
    return ret;
}

+ (NSArray *)ownersOfClass:(Class)c
{
    NSMutableArray *ret = [NSMutableArray array];
    NSArray *liveObjects = [self allLiveObjects];
    for (NSObject *liveObject in liveObjects) {
        NSArray *retained = [self retainedObjectsWithObject:liveObject];
        for (NSObject *temp in retained) {
            if ([temp class] == c) {
                [ret addObject:liveObject];
                break;
            }
        }
    }
    return ret;
}

+ (id)anyOwnerOfClass:(Class)c
{
    NSArray *liveObjects = [self allLiveObjects];
    for (NSObject *liveObject in liveObjects) {
        NSArray *retained = [self retainedObjectsWithObject:liveObject];
        for (NSObject *temp in retained) {
            if ([temp class] == c) {
                return liveObject;
            }
        }
    }
    return nil;
}

+ (NSArray *)arrayWithSet:(const set<long long> &)s
{
    NSMutableArray *array = [NSMutableArray array];
    for (long long value : s) {
        NSObject *temp = (__bridge NSObject *)((void *)value);
        [array addObject:temp];
    }
    return array;
}

@end
