//
//  HSKVOObserver.m
//  HSKVO
//
//  Created by shenlujia on 2015/12/22.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "HSKVOObserver.h"
#import "HSKVOPrivate.h"
#import "HSKVODeallocSwizzle.h"
#import "HSKVORecord.h"

@interface HSKVOObserver ()

@property (nonatomic, weak, readonly) NSObject *object;
@property (nonatomic, assign, readonly) id unretainedObject;

@end

@implementation HSKVOObserver
{
    NSLock *_lock;
    NSMutableDictionary<NSString *, NSMutableArray<HSKVORecord *> *> *_keyPathDictionary;
}

- (void)dealloc
{
    HSKVOLog(@"~%@", NSStringFromClass([self class]));
    [self unobserveAll];
}

- (instancetype)initWithObject:(id)object
{
    if (!object) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        _object = object;
        _unretainedObject = object;
        _keyPathDictionary = [NSMutableDictionary dictionary];
        _lock = [[NSLock alloc] init];
        
        __weak typeof (self) weakSelf = self;
        [HSKVODeallocSwizzle inject:object callback:^(id unretainedObject) {
            __strong typeof (weakSelf) strongSelf = weakSelf;
            [strongSelf p_unobserveObject:unretainedObject];
            [strongSelf.delegate observerObjectWillDealloc:strongSelf];
        }];
    }
    
    return self;
}

- (NSUInteger)hash
{
    return self.object.hash;
}

- (BOOL)isEqual:(id)object
{
    if (!self.object || !object) {
        return NO;
    }
    if ([object class] == [self.object class]) {
        return [self.object isEqual:object];
    }
    if (![object isKindOfClass:[HSKVOObserver class]]) {
        return NO;
    }
    HSKVOObserver *other = (HSKVOObserver *)object;
    return [self.object isEqual:other.object];
}

- (void)observe:(NSString *)keyPath
        options:(NSKeyValueObservingOptions)options
          block:(id)block
{
    if (!keyPath || !block) {
        return;
    }
    
    NSString *key = nil;
    NSString *path = ({
        NSArray *array = [keyPath componentsSeparatedByString:@"."];
        NSMutableArray *components = [array mutableCopy];
        key = components.lastObject;
        if (components.count) {
            [components removeObject:components.lastObject];
        }
        [components componentsJoinedByString:@"."];
    });
    if (path.length) {
        id pathObject = [self.object valueForKeyPath:path];
        if (pathObject) {
            __weak typeof (self) weakSelf = self;
            [HSKVODeallocSwizzle inject:pathObject callback:^(NSObject *obj) {
//                [obj removeObserver:weakSelf forKeyPath:key];
                __strong typeof (weakSelf) strongSelf = weakSelf;
                [strongSelf p_unobserveObject:strongSelf.unretainedObject
                                      keyPath:keyPath];
            }];
        }
    }
    
    HSKVORecord *record = [[HSKVORecord alloc] initWithKeyPath:keyPath
                                                     options:options
                                                       block:block];
    
    [_lock lock];
    NSMutableArray *records = _keyPathDictionary[keyPath];
    if (!records) {
        records = [[NSMutableArray alloc] init];
        _keyPathDictionary[keyPath] = records;
    }
    [records addObject:record];
    [_lock unlock];
    
    [self p_observeObject:self.object records:@[record]];
}

- (void)unobserve:(NSString *)keyPath
{
    [self p_unobserveObject:self.object keyPath:keyPath];
}

- (void)unobserveAll
{
    [self p_unobserveObject:self.object];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (!context) {
        return;
    }
    HSKVORecord *record = (__bridge id)(context);
    if (![record isKindOfClass:[HSKVORecord class]]) {
        return;
    }
    
    [self.delegate observer:self
                 didObserve:keyPath
                   ofObject:object
                     change:change
                      block:record.block];
}

#pragma mark - private

- (void)p_unobserveObject:(id)object
{
    // KVO 释放时，会调用此方法
    // 如果此时 object 也处于释放中，object = nil
    // 此处不进行判断的话 unobserve 就不正常了
    if (!object) {
        return;
    }
    
    [_lock lock];
    NSMutableArray *records = [NSMutableArray array];
    for (NSArray *array in _keyPathDictionary.allValues) {
        [records addObjectsFromArray:array];
    }
    [_keyPathDictionary removeAllObjects];
    [_lock unlock];
    
    [self p_unobserve:object records:records];
}

- (void)p_unobserveObject:(id)object keyPath:(NSString *)keyPath
{
    if (!keyPath) {
        return;
    }
    
    [_lock lock];
    NSArray *records = [_keyPathDictionary[keyPath] copy];
    [_keyPathDictionary removeObjectForKey:keyPath];
    [_lock unlock];
    
    [self p_unobserve:object records:records];
}

- (void)p_observeObject:(id)object records:(NSArray<HSKVORecord *> *)records
{
    for (HSKVORecord *record in records) {
        [object addObserver:self
                 forKeyPath:record.keyPath
                    options:record.options
                    context:(__bridge void *)(record)];
    }
}

- (void)p_unobserve:(id)object records:(NSArray<HSKVORecord *> *)records
{
    for (HSKVORecord *record in records) {
        [object removeObserver:self
                    forKeyPath:record.keyPath
                       context:(__bridge void *)(record)];
    }
}

@end
