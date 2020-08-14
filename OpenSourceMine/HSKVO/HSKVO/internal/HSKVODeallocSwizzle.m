//
//  HSKVODeallocSwizzle.m
//  HSKVO
//
//  Created by shenlujia on 2015/12/12.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "HSKVODeallocSwizzle.h"
#import <objc/runtime.h>

const void * kHSDeallocFlagKey = &kHSDeallocFlagKey;

@interface HSDeallocFlag : NSObject
{
    NSLock *_lock;
    NSMutableArray *_callbacks;
}

@property (nonatomic, assign, readonly) id unretainedObject; // 这里必须是 assign

@end

@implementation HSDeallocFlag

- (void)dealloc
{
    [_lock lock];
    NSArray *array = [_callbacks copy];
    [_lock unlock];
    
    for (void (^block)(id object) in array) {
        block(self.unretainedObject);
    }
}

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        _unretainedObject = object;
        _lock = [[NSLock alloc] init];
        _callbacks = [NSMutableArray array];
    }
    return self;
}

- (void)addCallback:(void (^)(__unsafe_unretained id unretainedObject))callback
{
    if (!callback) {
        return;
    }
    [_lock lock];
    [_callbacks addObject:callback];
    [_lock unlock];
}

@end

@interface HSKVODeallocSwizzle ()

@end

@implementation HSKVODeallocSwizzle

+ (void)inject:(id)object callback:(void (^)(__unsafe_unretained id object))callback
{
    if (!object || !callback) {
        return;
    }
    
    HSDeallocFlag *flag = nil;
    
    @synchronized (object) {
        flag = objc_getAssociatedObject(object, kHSDeallocFlagKey);
        if (![flag isKindOfClass:[HSDeallocFlag class]]) {
            flag = [[HSDeallocFlag alloc] initWithObject:object];
            objc_AssociationPolicy policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
            objc_setAssociatedObject(object, kHSDeallocFlagKey, flag, policy);
        }
    }
    
    [flag addCallback:callback];
}

@end
