//
//  MemoryLeakDetectController.m
//  Beyond
//
//  Created by ZZZ on 2021/3/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "MemoryLeakDetectController.h"
#import <objc/runtime.h>
#import <FLEX/FLEX.h>
#import "SimpleLeakDetector.h"
#import "SimpleLeakDetectorMRC.h"
#import "MacroHeader.h"

@interface TestMemoryLeakDetectObjInternal : NSObject

@end

@implementation TestMemoryLeakDetectObjInternal

- (void)dealloc
{
    NSString *s = NSStringFromClass([self class]);
    printf("~%s\n", s.UTF8String);
}

@end

@interface TestMemoryLeakDetectObj : NSObject

@property (nonatomic, strong) NSHashTable *hashTable;
@property (nonatomic, strong) NSMapTable *mapTable;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableDictionary *dictionary;

@property (nonatomic, strong) TestMemoryLeakDetectObj *obj;
@property (nonatomic, strong) TestMemoryLeakDetectObjInternal *internal;

@end

@implementation TestMemoryLeakDetectObj

- (void)dealloc
{
    NSString *s = NSStringFromClass([self class]);
    printf("~%s\n", s.UTF8String);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hashTable = [NSHashTable weakObjectsHashTable];
        [_hashTable addObject:@(6)];
        _mapTable = [NSMapTable weakToStrongObjectsMapTable];
        [_mapTable setObject:@(33) forKey:@(55)];
        _array = [NSMutableArray array];
        [_array addObject:@(1)];
        _dictionary = [NSMutableDictionary dictionary];
        [_dictionary setObject:@(2) forKey:@(3)];
    }
    return self;
}

+ (instancetype)create
{
    TestMemoryLeakDetectObj *obj1 = [[TestMemoryLeakDetectObj alloc] init];
    TestMemoryLeakDetectObj *obj2 = [[TestMemoryLeakDetectObj alloc] init];
    TestMemoryLeakDetectObj *obj3 = [[TestMemoryLeakDetectObj alloc] init];
    TestMemoryLeakDetectObj *obj4 = [[TestMemoryLeakDetectObj alloc] init];
    objc_setAssociatedObject(obj1, @selector(mapTable), obj2, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(obj1, @selector(hashTable), obj3, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(obj1, @selector(array), obj4, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    obj1.obj = [[TestMemoryLeakDetectObj alloc] init];
    return obj1;
}

@end

@interface MemoryLeakDetectController ()

@property (nonatomic, strong) TestMemoryLeakDetectObj *obj;

@end

@implementation MemoryLeakDetectController

+ (void)initialize
{
    [SimpleLeakDetector start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self test:@"disableDelayDealloc" tap:^(UIButton *button, NSDictionary *userInfo) {
        TestMemoryLeakDetectObj *obj = [[TestMemoryLeakDetectObj alloc] init];
        obj.internal = [[TestMemoryLeakDetectObjInternal alloc] init];
        [SimpleLeakDetectorMRC disableDelayDealloc];
    }];

    [self test:@"enableDelayDealloc" tap:^(UIButton *button, NSDictionary *userInfo) {
        TestMemoryLeakDetectObj *obj = [[TestMemoryLeakDetectObj alloc] init];
        obj.internal = [[TestMemoryLeakDetectObjInternal alloc] init];
        [SimpleLeakDetectorMRC enableDelayDealloc];
    }];

    [self test:@"allObjects" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSDictionary *allLiveObjects = [SimpleLeakDetector allDetectedLiveObjects];
        NSLog(@"%@", allLiveObjects);
        NSDictionary *allHeapObjects = [SimpleLeakDetector allHeapObjects];
        NSLog(@"%@", allHeapObjects);
    }];

    [self test:@"findOwnersOfObject" set:nil action:@selector(test_findOwnersOfObject)];

    [self test:@"retainedObjectsWithObject" set:nil action:@selector(test_retainedObjectsWithObject)];

    [self test:@"findRetainCyclesWithClasses" set:nil action:@selector(test_findRetainCyclesWithClasses)];
}

- (void)test_findOwnersOfObject
{
    {
        SS_CHECK_TIME_REGISTER
        SS_CHECK_TIME_AUTO_START
        self.obj = [TestMemoryLeakDetectObj create];
        SS_CHECK_TIME_STEP
        NSArray *owners1 = [SimpleLeakDetector ownersOfObject:self.obj];
        SS_CHECK_TIME_STEP
        NSArray *owners2 = [SimpleLeakDetector ownersOfClass:[TestMemoryLeakDetectObj class]];
        SS_CHECK_TIME_STEP
        NSAssert([owners1 containsObject:self] && [owners2 containsObject:self], @"");
    }

    {
        TestMemoryLeakDetectObj *blocked = [TestMemoryLeakDetectObj create];
        __unused void (^block)(void) = ^{
            blocked.obj = nil;
        };
        NSArray *owners1 = [SimpleLeakDetector ownersOfObject:blocked];
        NSLog(@"%@", owners1);
    }
}

- (void)test_retainedObjectsWithObject
{
    TestMemoryLeakDetectObj *obj = [TestMemoryLeakDetectObj create];
    NSArray *retainedObjects = [SimpleLeakDetector retainedObjectsWithObject:obj];
    NSLog(@"%@", retainedObjects);
}

- (void)test_findRetainCyclesWithClasses
{
    TestMemoryLeakDetectObj *obj = [[TestMemoryLeakDetectObj alloc] init];
    obj.obj = [[TestMemoryLeakDetectObj alloc] init];
    obj.obj.obj = obj;

    NSArray *classes = @[@"MemoryLeakDetectController", [TestMemoryLeakDetectObj class]];
    NSSet *set = [SimpleLeakDetector findRetainCyclesWithClasses:classes maxCycleLength:3];
    NSLog(@"%@", set);

    obj.obj.obj = nil;
}

@end
