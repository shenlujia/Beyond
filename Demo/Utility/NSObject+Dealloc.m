//
//  NSObject+Dealloc.m
//  Demo
//
//  Created by SLJ on 2020/6/20.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "NSObject+Dealloc.h"
#import <objc/runtime.h>

@interface NSObjectDeallocInternal : NSObject

@property (nonatomic, strong) void (^block)(void);

@end

@implementation NSObjectDeallocInternal

- (void)dealloc
{
    if (self.block) {
        self.block();
    }
}

@end

@implementation NSObject (Dealloc)

- (NSObjectDeallocInternal *)dealloc_helper
{
    void * key = @selector(dealloc_helper);
    NSObjectDeallocInternal *impl = objc_getAssociatedObject(self, key);
    if (!impl) {
        impl = [[NSObjectDeallocInternal alloc] init];
        objc_setAssociatedObject(self, key, impl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return impl;
}

- (void)setDealloc_callback:(void (^)(void))dealloc_callback
{
    [self dealloc_helper].block = dealloc_callback;
}

- (void (^)(void))dealloc_callback
{
    return [self dealloc_helper].block;
}

@end
