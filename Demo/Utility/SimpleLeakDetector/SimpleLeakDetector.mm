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

- (void)dealloc
{

}

+ (void)start
{
    [FBAssociationManager hook];
    [SimpleLeakDetectorMRC run];
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
    return [SimpleLeakDetectorInternal retainedObjectsWithObject:object];
}

+ (NSArray *)ownersOfObject:(id)object
{
    NSMutableArray *ret = [NSMutableArray array];
//    NSArray *liveObjects = [self allLiveObjects];
//    for (NSObject *liveObject in liveObjects) {
//        NSArray *retained = [self retainedObjectsWithObject:liveObject];
//        if ([retained containsObject:object]) {
//            [ret addObject:liveObject];
//        }
//    }
    return ret;
}

+ (NSArray *)ownersOfClass:(Class)c
{
    NSMutableArray *ret = [NSMutableArray array];
//    NSArray *liveObjects = [self allLiveObjects];
//    for (NSObject *liveObject in liveObjects) {
//        NSArray *retained = [self retainedObjectsWithObject:liveObject];
//        for (NSObject *temp in retained) {
//            if ([temp class] == c) {
//                [ret addObject:liveObject];
//                break;
//            }
//        }
//    }
    return ret;
}

+ (id)anyOwnerOfClass:(Class)c
{
//    NSArray *liveObjects = [self allLiveObjects];
//    for (NSObject *liveObject in liveObjects) {
//        NSArray *retained = [self retainedObjectsWithObject:liveObject];
//        for (NSObject *temp in retained) {
//            if ([temp class] == c) {
//                return liveObject;
//            }
//        }
//    }
    return nil;
}

//void leak_detector_register_callback(NSTimeInterval interval, void (^callback)(id object))
//{
//    static NSTimer *timer = nil;
//    [timer invalidate];
//
//    if (!callback) {
//        return;
//    }
//    if (@available(iOS 10, *)) {
//        timer = [NSTimer scheduledTimerWithTimeInterval:MAX(interval, 1) repeats:YES block:^(NSTimer *timer) {
//            pthread_mutex_lock(&m_data_mutex);
//            SSCheckMap data = m_check_map;
//            pthread_mutex_unlock(&m_data_mutex);
//
////            NSMutableDictionary *total = [NSMutableDictionary dictionary];
////            for (auto it = data.begin(); it != data.end(); ++it) {
////                NSString *name = [NSString stringWithUTF8String:it->first];
////                NSMutableArray *array = [NSMutableArray array];
////                for (auto p : it->second) {
////                    [array addObject:[NSString stringWithFormat:@"%p", (void *)p]];
////                }
////                total[name] = array;
////            }
////
////            SSLeakDetectorCallback *object = [[SSLeakDetectorCallback alloc] init];
////            [object updateWithData:data last_nonempty:nil last_diffs:nil];
////            callback(object);
//        }];
//    }
//}

@end
