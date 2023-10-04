//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyMemory.h"
#import <malloc/malloc.h>
#import <objc/runtime.h>
#import "_Foundation.h"

@interface FBRetainCycleDetector (SSEasyFixBeyond)

- (NSSet<NSArray<FBObjectiveCGraphElement *> *> *)findRetainCyclesWithMaxCycleLength:(NSUInteger)maxCycleLength maxTraversedNodeNumber:(NSUInteger)maxTraversedNodeNumber maxCycleNum:(NSUInteger)maxCycleNum;

@end

static void ss_memory_enumerateLiveObjects(void (^block)(id anyObject))
{
   
}

NSArray * ss_memory_retainedObjects(id object)
{
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *ret = [NSMutableArray array];
        for (id one in (NSArray *)object) {
            [ret addObjectsFromArray:ss_memory_retainedObjects(one)];
        }
        return ret;
    }

    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)object;
        NSMutableArray *array = [NSMutableArray arrayWithArray:dictionary.allKeys];
        [array addObjectsFromArray:dictionary.allValues];
        return ss_memory_retainedObjects(array);
    }

    if ([object isKindOfClass:[NSHashTable class]]) {
        NSHashTable *table = (NSHashTable *)object;
        NSPointerFunctions *func = table.pointerFunctions;
        BOOL strong = [[func valueForKey:@"usesStrongWriteBarrier"] boolValue];
        return strong ? table.allObjects : @[];
    }

    if ([object isKindOfClass:[NSMapTable class]]) {
        NSMapTable *table = (NSMapTable *)object;
        NSPointerFunctions *func = table.keyPointerFunctions;
        BOOL strong = [[func valueForKey:@"usesStrongWriteBarrier"] boolValue];
        NSDictionary *dictionary = strong ? table.dictionaryRepresentation : @{};
        return ss_memory_retainedObjects(dictionary);
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

NSArray * ss_memory_findRetainCycles(id object, NSInteger maxCycleLength)
{
    if (!object) {
        return nil;
    }
    
    FBObjectGraphConfiguration *configuration = [[FBObjectGraphConfiguration alloc] init];
    FBRetainCycleDetector *detector = [[FBRetainCycleDetector alloc] initWithConfiguration:configuration];
    [detector addCandidate:object];
    NSSet<NSArray<FBObjectiveCGraphElement *> *> *set = [detector findRetainCyclesWithMaxCycleLength:maxCycleLength maxTraversedNodeNumber:maxCycleLength maxCycleNum:maxCycleLength];
    
    return set.allObjects;
}

id ss_memory_anyOwnerOf(id object)
{
    if (!object) {
        return nil;
    }
    
    __block id ret = nil;
    ss_memory_enumerateLiveObjects(^(id anyObject) {
        if (ret) {
            return;
        }
        NSArray *retainedObjects = ss_memory_retainedObjects(anyObject);
        if ([retainedObjects containsObject:object]) {
            ret = anyObject;
        }
    });
    return ret;
}

// 返回引用了`object`的所有对象
NSArray * ss_memory_ownersOf(id object)
{
    if (!object) {
        return nil;
    }
    
    NSMutableArray *ret = [NSMutableArray array];
    ss_memory_enumerateLiveObjects(^(id anyObject) {
        NSArray *retainedObjects = ss_memory_retainedObjects(anyObject);
        if ([retainedObjects containsObject:object]) {
            [ret addObject:anyObject];
        }
    });
    return ret;
}
