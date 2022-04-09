//
//  SimpleLeakDetector.m
//  Beyond
//
//  Created by ZZZ on 2021/3/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "SimpleLeakDetector.h"
#import <objc/runtime.h>
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import "SimpleLeakDetectorMRC.h"
#import "SSHeapEnumerator.h"
#import "SSEasy.h"

@interface SimpleLeakDetector ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SimpleLeakDetector

+ (void)run
{
    [[SimpleLeakDetector detector] p_run];
}

+ (NSDictionary<Class, NSArray<NSNumber *> *> *)allDetectedLiveObjects
{
    NSMutableDictionary *total = [NSMutableDictionary dictionary];
    [SimpleLeakDetectorMRC enumPointersWithBlock:^(const char *class_name, uintptr_t pointer) {
        Class c = objc_getClass(class_name);
        if (c) {
            NSMutableArray *array = total[c];
            if (!array) {
                array = [NSMutableArray array];
//                total[c] = array; todo...
            }
            [array addObject:@(pointer)];
        }
    }];
    return total;
}

+ (NSDictionary<NSString *, NSNumber *> *)allHeapObjects_old
{
    NSMutableArray *array = [NSMutableArray array];

    [SSHeapEnumerator enumerateLiveObjectsUsingBlock:^(__unsafe_unretained id object, __unsafe_unretained Class actualClass) {
        const char *name = class_getName(actualClass);
        if (strcmp(name, "JSExport") == 0) {
            return;
        }
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

+ (NSDictionary<Class, NSArray<NSNumber *> *> *)allHeapObjects
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [SSHeapEnumerator enumerateLiveObjectsUsingBlock:^(__unsafe_unretained id object, __unsafe_unretained Class actualClass) {
        const char *name = class_getName(actualClass);
        if (strcmp(name, "JSExport") == 0) {
            return;
        }
        NSMutableArray *array = ret[actualClass];
        if (!array) {
            array = [NSMutableArray array];
//            ret[actualClass] = array; todo...
        }
        [array addObject:@((uintptr_t)object)];
    }];
    return ret;
}

+ (NSArray *)ownersOfObject:(id)object
{
    NSMutableArray *ret = [NSMutableArray array];
    NSDictionary *liveObjects = [SimpleLeakDetector allDetectedLiveObjects];
    [liveObjects enumerateKeysAndObjectsUsingBlock:^(Class c, NSArray *array, BOOL *stop) {
        for (NSNumber *value in array) {
            uintptr_t pointer = value.unsignedLongValue;
            [SimpleLeakDetectorMRC enableDelayDealloc];
            if ([SimpleLeakDetectorMRC isPointerValidWithClassName:class_getName(c) pointer:pointer]) {
                NSObject *temp = (__bridge NSObject *)((void *)pointer);
                NSArray *retained = ss_memory_retainedObjects(temp);
                for (id one in retained) {
                    if ([SimpleLeakDetector p_object:one conformTo:object]) {
                        [ret addObject:temp];
                    }
                }
            }
            [SimpleLeakDetectorMRC disableDelayDealloc];
        }
    }];
    return ret;
}

+ (id)anyOwnerOfObject:(id)object
{
    __block id ret = nil;
    NSDictionary *liveObjects = [SimpleLeakDetector allDetectedLiveObjects];
    [liveObjects enumerateKeysAndObjectsUsingBlock:^(Class c, NSArray *array, BOOL *stop) {
        for (NSNumber *value in array) {
            uintptr_t pointer = value.unsignedLongValue;
            [SimpleLeakDetectorMRC enableDelayDealloc];
            if ([SimpleLeakDetectorMRC isPointerValidWithClassName:class_getName(c) pointer:pointer]) {
                NSObject *temp = (__bridge NSObject *)((void *)pointer);
                NSArray *retained = ss_memory_retainedObjects(temp);
                for (id one in retained) {
                    if ([SimpleLeakDetector p_object:one conformTo:object]) {
                        ret = temp;
                    }
                }
            }
            [SimpleLeakDetectorMRC disableDelayDealloc];

            if (ret) {
                *stop = YES;
            }
        }
    }];
    return ret;
}

+ (NSSet *)findRetainCyclesWithClasses:(NSArray *)classes maxCycleLength:(NSInteger)maxCycleLength
{
    NSMutableSet *classSet = [NSMutableSet set];
    for (id item in classes) {
        Class c;
        if ([item isKindOfClass:[NSString class]]) {
            c = NSClassFromString(item);
        } else if ([item class] == item) {
            c = (Class)item;
        }
        NSCParameterAssert(c);
        [classSet addObject:c];
    }

    NSMutableArray *candidates = [NSMutableArray array];
    NSDictionary *liveObjects = [SimpleLeakDetector allDetectedLiveObjects];
    [liveObjects enumerateKeysAndObjectsUsingBlock:^(Class c, NSArray *array, BOOL *stop) {
        if ([classSet containsObject:c]) {
            for (NSNumber *value in array) {
                uintptr_t pointer = value.unsignedLongValue;
                [SimpleLeakDetectorMRC enableDelayDealloc];
                if ([SimpleLeakDetectorMRC isPointerValidWithClassName:class_getName(c) pointer:pointer]) {
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

#pragma mark - private

+ (SimpleLeakDetector *)detector
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)p_run
{
    if (self.timer) {
        return;
    }

    [FBAssociationManager hook];
    [SimpleLeakDetectorMRC run];
}

+ (BOOL)p_object:(NSObject *)object conformTo:(id)to
{
    if (object == to) {
        return YES;
    }

    Class c;
    if ([to class] == to) {
        c = to;
    } else if ([to isKindOfClass:[NSString class]]) {
        c = NSClassFromString(to);
    }
    if (c) {
        return [object isKindOfClass:c];
    }

    return NO;
}

@end
