//
//  SimpleLeakDetectorInternal.m
//  Beyond
//
//  Created by ZZZ on 2021/3/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SimpleLeakDetectorInternal.h"
#import <objc/runtime.h>
#import <string>
#import <malloc/malloc.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import "SimpleLeakDetectorMRC.h"

@implementation SimpleLeakDetectorInternal

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

@end
