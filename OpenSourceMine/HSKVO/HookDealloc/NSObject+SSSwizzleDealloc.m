//
//  NSObject+SSSwizzleDealloc.m
//  HSKVO
//
//  Created by shenlujia on 2018/3/14.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import "NSObject+SSSwizzleDealloc.h"
#import <objc/message.h>
#import <objc/runtime.h>

static const void * swizzleDeallocBlockContainerKey = &swizzleDeallocBlockContainerKey;

static NSMutableSet *swizzledClasses()
{
    static dispatch_once_t onceToken;
    static NSMutableSet *swizzledClasses = nil;
    dispatch_once(&onceToken, ^{
        swizzledClasses = [[NSMutableSet alloc] init];
    });
    return swizzledClasses;
}

#pragma mark - SSSwizzleDeallocBlockContainer

@interface SSSwizzleDeallocBlockContainer : NSObject

@end

@implementation SSSwizzleDeallocBlockContainer
{
    __unsafe_unretained id _object;
    NSMutableArray *_blocks;
}

- (instancetype)initWithObject:(id)object
{
    self = [super init];
    if (self) {
        _object = object;
        _blocks = [NSMutableArray array];
    }
    return self;
}

- (void)addBlock:(void (^)(__unsafe_unretained id object))block
{
    @synchronized (self) {
        if (block) {
            [_blocks addObject:block];
        }
    }
}

- (void)dispose
{
    NSArray *blocks = nil;
    @synchronized (self) {
        blocks = [_blocks copy];
        _object = nil;
        [_blocks removeAllObjects];
    }
    for (void (^block)(__unsafe_unretained id) in blocks) {
        block(_object);
    }
}

@end

#pragma mark - NSObject (SSSwizzleDealloc)

@implementation NSObject (SSSwizzleDealloc)

void swizzleDeallocIfNeeded(Class classToSwizzle)
{
    @synchronized (swizzledClasses()) {
        NSString *className = NSStringFromClass(classToSwizzle);
        if ([swizzledClasses() containsObject:className])
            return;
        
        SEL deallocSelector = sel_registerName("dealloc");
        
        __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
        
        id newDealloc = ^(__unsafe_unretained id self) {
            
            SSSwizzleDeallocBlockContainer *container = [self ss_swizzleDeallocBlockContainer];
            [container dispose];
            
            if (originalDealloc == NULL) {
                struct objc_super superInfo = {
                    .receiver = self,
                    .super_class = class_getSuperclass(classToSwizzle)
                };
                
                void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
                msgSend(&superInfo, deallocSelector);
            } else {
                originalDealloc(self, deallocSelector);
            }
        };
        
        IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
        
        if (!class_addMethod(classToSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
            // The class already contains a method implementation.
            Method deallocMethod = class_getInstanceMethod(classToSwizzle, deallocSelector);
            
            // We need to store original implementation before setting new implementation
            // in case method is called at the time of setting.
            originalDealloc = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
            
            // We need to store original implementation again, in case it just changed.
            originalDealloc = (__typeof__(originalDealloc))method_setImplementation(deallocMethod, newDeallocIMP);
        }
        
        [swizzledClasses() addObject:className];
    }
}

- (SSSwizzleDeallocBlockContainer *)ss_swizzleDeallocBlockContainer
{
    @synchronized (self) {
        const void * key = swizzleDeallocBlockContainerKey;
        SSSwizzleDeallocBlockContainer *container = objc_getAssociatedObject(self, key);
        if (!container) {
            swizzleDeallocIfNeeded([self class]);
            container = [[SSSwizzleDeallocBlockContainer alloc] initWithObject:self];
            objc_setAssociatedObject(self, key, container, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return container;
    }
}

- (void)ss_swizzleDeallocWithBlock:(void (^)(__unsafe_unretained id object))block
{
    SSSwizzleDeallocBlockContainer *container = [self ss_swizzleDeallocBlockContainer];
    [container addBlock:block];
}

@end
