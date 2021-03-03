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
#import "SSHeapEnumerator.h"

@implementation SimpleLeakDetector

+ (void)start
{
    [FBAssociationManager hook];
    [SimpleLeakDetectorMRC run];
}

+ (NSDictionary<NSString *, NSArray<NSNumber *> *> *)allDetectedLiveObjects
{
    NSMutableDictionary *total = [NSMutableDictionary dictionary];
    [SimpleLeakDetectorMRC enumPointersWithBlock:^(const char *class_name, uintptr_t pointer) {
        NSString *name = [NSString stringWithUTF8String:class_name];
        if (name) {
            NSMutableArray *array = total[name];
            if (!array) {
                array = [NSMutableArray array];
                total[name] = array;
            }
            [array addObject:@(pointer)];
        }
    }];
    return total;
}

+ (NSDictionary<NSString *, NSNumber *> *)allHeapObjects
{
    NSMutableArray *array = [NSMutableArray array];
    [SSHeapEnumerator enumerateLiveObjectsUsingBlock:^(__unsafe_unretained id object, __unsafe_unretained Class actualClass) {
        [array addObject:actualClass];
    }];
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    for (Class c in array) {
        NSString *name = NSStringFromClass(c);
        if (name) {
            NSNumber *obj = ret[name];
            ret[name] = @(obj.integerValue + 1);
        }
    }
    return ret;
}

+ (SSLeakDetectorRecord *)currentLiveObjectsRecord
{
    SSLeakDetectorRecord *record = [[SSLeakDetectorRecord alloc] init];

//    NSMutableArray *liveObjects = [NSMutableArray array];
//    leak_detector_enum_live_objects(^(const char *class_name, uintptr_t pointer) {
//        [liveObjects addObject:(__bridge NSObject *)((void *)pointer)];
//    });
    return record;
}

+ (NSArray *)retainedObjectsWithObject:(id)object
{
    if ([object isKindOfClass:[NSArray class]]) {
        return (NSArray *)object;
    }

    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)object;
        NSMutableArray *ret = [NSMutableArray arrayWithArray:dictionary.allKeys];
        [ret addObjectsFromArray:dictionary.allValues];
        return ret;
    }

    if ([object isKindOfClass:[NSHashTable class]]) {
        NSHashTable *table = (NSHashTable *)object;
        return table.pointerFunctions.usesStrongWriteBarrier ? table.allObjects : @[];
    }

    if ([object isKindOfClass:[NSMapTable class]]) {
        NSMapTable *table = (NSMapTable *)object;
        NSDictionary *dictionary = table.keyPointerFunctions.usesStrongWriteBarrier ? table.dictionaryRepresentation : @{};
        return [self retainedObjectsWithObject:dictionary];
    }

    if ([object isKindOfClass:[NSSet class]]) {
        return ((NSSet *)object).allObjects;
    }

    FBObjectGraphConfiguration *configuration = [[FBObjectGraphConfiguration alloc] init];
    FBObjectiveCObject *wrapper = [[FBObjectiveCObject alloc] initWithObject:object configuration:configuration];
    NSSet *allRetainedObjects = [wrapper allRetainedObjects];

    NSMutableArray *ret = [NSMutableArray array];
    for (FBObjectiveCObject *temp in allRetainedObjects.allObjects) {
        if (temp.object) {
            [ret addObject:temp.object];
        }
    }

    return ret;
}

+ (NSArray *)ownersOfObject:(id)object
{
    NSMutableArray *ret = [NSMutableArray array];
    NSDictionary *liveObjects = [SimpleLeakDetector allDetectedLiveObjects];
    [liveObjects enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *array, BOOL *stop) {
        for (NSNumber *value in array) {
            uintptr_t pointer = value.unsignedLongValue;
            [SimpleLeakDetectorMRC enableDelayDealloc];
            if ([SimpleLeakDetectorMRC isPointerValidWithClassName:key.UTF8String pointer:pointer]) {
                NSObject *temp = (__bridge NSObject *)((void *)pointer);
                NSArray *retained = [SimpleLeakDetector retainedObjectsWithObject:temp];
                if ([retained containsObject:object]) {
                    [ret addObject:temp];
                }
            }
            [SimpleLeakDetectorMRC disableDelayDealloc];
        }
    }];
    return ret;
}

+ (NSArray *)ownersOfClass:(Class)c
{
    NSMutableArray *ret = [NSMutableArray array];
    NSDictionary *liveObjects = [SimpleLeakDetector allDetectedLiveObjects];
    [liveObjects enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *array, BOOL *stop) {
        for (NSNumber *value in array) {
            uintptr_t pointer = value.unsignedLongValue;
            [SimpleLeakDetectorMRC enableDelayDealloc];
            if ([SimpleLeakDetectorMRC isPointerValidWithClassName:key.UTF8String pointer:pointer]) {
                NSObject *temp = (__bridge NSObject *)((void *)pointer);
                NSArray *retained = [SimpleLeakDetector retainedObjectsWithObject:temp];
                for (id one in retained) {
                    if ([one isKindOfClass:c]) {
                        [ret addObject:temp];
                    }
                }
            }
            [SimpleLeakDetectorMRC disableDelayDealloc];
        }
    }];
    return ret;
}

+ (NSSet *)findRetainCyclesWithClasses:(NSArray *)classes maxCycleLength:(NSInteger)maxCycleLength
{
    NSMutableSet *classSet = [NSMutableSet set];
    for (id item in classes) {
        NSString *name = nil;
        if ([item isKindOfClass:[NSString class]]) {
            name = item;
        } else if ([item class] == item) {
            name = NSStringFromClass(item);
        }
        NSCParameterAssert(name.length > 0);
        [classSet addObject:name];
    }

    NSMutableArray *candidates = [NSMutableArray array];
    NSDictionary *liveObjects = [SimpleLeakDetector allDetectedLiveObjects];
    [liveObjects enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *array, BOOL *stop) {
        if ([classSet containsObject:key]) {
            for (NSNumber *value in array) {
                uintptr_t pointer = value.unsignedLongValue;
                [SimpleLeakDetectorMRC enableDelayDealloc];
                if ([SimpleLeakDetectorMRC isPointerValidWithClassName:key.UTF8String pointer:pointer]) {
                    NSObject *temp = (__bridge NSObject *)((void *)pointer);
                    if (temp) {
                        [candidates addObject:temp];
                    }
                }
                [SimpleLeakDetectorMRC disableDelayDealloc];
            }
        }
    }];

    FBObjectGraphConfiguration *configuration = [[FBObjectGraphConfiguration alloc] init];
    FBRetainCycleDetector *detector = [[FBRetainCycleDetector alloc] initWithConfiguration:configuration];
    for (id candidate in candidates) {
        [detector addCandidate:candidate];
    }
    NSSet<NSArray<FBObjectiveCGraphElement *> *> *set = [detector findRetainCyclesWithMaxCycleLength:maxCycleLength];

    return set;
}

@end
