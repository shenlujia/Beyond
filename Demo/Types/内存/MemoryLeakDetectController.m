//
//  MemoryLeakDetectController.m
//  Beyond
//
//  Created by ZZZ on 2021/3/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "MemoryLeakDetectController.h"
#import "SimpleLeakDetector.h"
#import <objc/runtime.h>

@interface TestMemoryLeakDetectObj : NSObject

@property (nonatomic, strong) NSHashTable *hashTable;
@property (nonatomic, strong) NSMapTable *mapTable;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableDictionary *dictionary;

@property (nonatomic, strong) TestMemoryLeakDetectObj *obj;

@end

@implementation TestMemoryLeakDetectObj

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

- (void)viewDidLoad
{
    [super viewDidLoad];

    [SimpleLeakDetector start];

    [self test:@"findOwnersOfObject" set:nil action:@selector(test_findOwnersOfObject)];

    [self test:@"retainedObjectsWithObject" set:nil action:@selector(test_retainedObjectsWithObject)];
}

- (void)test_findOwnersOfObject
{
    {
        self.obj = [TestMemoryLeakDetectObj create];
        NSArray *owners1 = [SimpleLeakDetector ownersOfObject:self.obj];
        NSArray *owners2 = [SimpleLeakDetector ownersOfClass:[TestMemoryLeakDetectObj class]];
        NSAssert(owners1.firstObject == self && owners2.firstObject == self, @"");
    }
    {
        TestMemoryLeakDetectObj *blocked = [TestMemoryLeakDetectObj create];
        void (^block)(void) = ^{
            blocked.obj = nil;
        };
        NSArray *owners1 = [SimpleLeakDetector ownersOfObject:blocked];
        NSLog(@"");
    }
}

- (void)test_retainedObjectsWithObject
{
    TestMemoryLeakDetectObj *obj = [TestMemoryLeakDetectObj create];
    NSArray *retainedObjects = [SimpleLeakDetector retainedObjectsWithObject:obj];
    NSLog(@"%@", retainedObjects);
}

@end
