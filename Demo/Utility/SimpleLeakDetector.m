//
//  SimpleLeakDetector.m
//  Demo
//
//  Created by ZZZ on 2020/11/23.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "SimpleLeakDetector.h"
#import <objc/runtime.h>

static NSSet *m_classes;
static NSMutableDictionary *m_leaks;
static NSRecursiveLock *m_lock;

static inline void SwizzleInstanceMethod(Class c, SEL origSEL, SEL newSEL)
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = class_getInstanceMethod(c, newSEL);

    if (class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(origMethod))) {
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

static inline void SwizzleClassMethod(Class c, SEL origSEL, SEL newSEL)
{
    Method origMethod = class_getClassMethod(c, origSEL);
    Method newMethod = class_getClassMethod(c, newSEL);

    if (class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(origMethod))) {
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(newMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@interface NSObject (LeakDetector)

+ (void)ss_registerSwizzleIfNeeded;

@end

static inline void _detect_object_alloc(id object)
{
    Class c = [object class];
    if (c && [m_classes containsObject:c]) {
        [m_lock lock];
        NSMutableSet *leak_objects = m_leaks[NSStringFromClass(c)];
        [leak_objects addObject:[NSString stringWithFormat:@"%p", object]];
        [m_lock unlock];
    }
}

void simple_leak_detect_class(Class c)
{
    simple_leak_detect_object(c, 0);
}

void simple_leak_detect_object(id object, int depth)
{
    [NSObject ss_registerSwizzleIfNeeded];

    Class c = [object class];
    if (!c) {
        return;
    }

    NSString *name = NSStringFromClass(c);
    if ([name hasPrefix:@"_"]) {
        return;
    }

    @autoreleasepool {
        [m_lock lock];

        NSMutableSet *classes = [NSMutableSet setWithSet:m_classes];
        [classes addObject:c];
        m_classes = [classes copy];

        NSMutableSet *leak_objects = m_leaks[name];
        if (!leak_objects) {
            leak_objects = [NSMutableSet set];
            m_leaks[name] = leak_objects;
        }

        [m_lock unlock];
    }

    if (c != object) {
        _detect_object_alloc(object);
    }

    if (c != object && depth > 0) {
        Class currentClass = c;
        while (currentClass) {
            unsigned int count = 0;
            Ivar *total = class_copyIvarList(currentClass, &count);
            for (int i = 0; i < count; ++i) {
                Ivar one = total[i];
                const char *encoding = ivar_getTypeEncoding(one);
                if (encoding[0] == '@') {
                    NSString *key = [NSString stringWithCString:ivar_getName(one) encoding:NSUTF8StringEncoding];
                    simple_leak_detect_object([object valueForKey:key], depth - 1);
                }
            }
            free(total);
            currentClass = class_getSuperclass(currentClass);
        }
    }
}

void simple_leak_detect_callback(void (^callback)(NSDictionary *leaks), NSTimeInterval interval)
{
    [NSObject ss_registerSwizzleIfNeeded];

    static NSTimer *timer = nil;
    [timer invalidate];

    if (!callback) {
        return;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:MAX(interval, 1) repeats:YES block:^(NSTimer *timer) {
        [m_lock lock];
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        [m_leaks enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableSet *obj, BOOL *stop) {
            if (obj.count) {
                ret[key] = [obj.allObjects mutableCopy];
            }
        }];
        [m_lock unlock];
        callback(ret);
    }];
}

@implementation NSObject (LeakDetector)

+ (id)ss_detect_leak_alloc
{
    id object = [self ss_detect_leak_alloc];
    _detect_object_alloc(object);
    return object;
}

- (void)ss_detect_leak_dealloc
{
    Class c = [self class];
    if (c && [m_classes containsObject:c]) {
        [m_lock lock];
        NSMutableSet *leak_objects = m_leaks[NSStringFromClass(c)];
        [leak_objects removeObject:[NSString stringWithFormat:@"%p", self]];
        [m_lock unlock];
    }

    [self ss_detect_leak_dealloc];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

+ (void)ss_registerSwizzleIfNeeded
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m_leaks = [NSMutableDictionary dictionary];
        m_lock = [[NSRecursiveLock alloc] init];
        m_classes = [NSMutableSet set];

        SwizzleClassMethod([self class], NSSelectorFromString(@"alloc"), @selector(ss_detect_leak_alloc));
        SwizzleInstanceMethod([self class], NSSelectorFromString(@"dealloc"), @selector(ss_detect_leak_dealloc));
    });
}

@end
