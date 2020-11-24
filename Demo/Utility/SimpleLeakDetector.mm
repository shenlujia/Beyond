//
//  SimpleLeakDetector.mm
//  Demo
//
//  Created by ZZZ on 2020/11/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "SimpleLeakDetector.h"
#import <objc/runtime.h>
#include <functional>
#include <pthread.h>
#include <set>
#include <map>

using namespace std;

struct leak_detector_str_cmp : public binary_function<const char *, const char *, bool>
{
    bool operator()(const char *s1, const char *s2) const
    {
        return strcmp(s1, s2) < 0;
    }
};

static pthread_mutex_t m_class_mutex;
static set<const char *, leak_detector_str_cmp> m_class_set;

static NSRecursiveLock *m_check_lock;
static map<const char *, set<long long>, leak_detector_str_cmp> m_check_map;

@interface NSObject (LeakDetector)

+ (void)ss_registerDetectorSwizzleIfNeeded;

@end

static inline void _detect_object_alloc(id object)
{
    if (!object) {
        return;
    }

    const char *name = object_getClassName(object);

    pthread_mutex_lock(&m_class_mutex);
    bool enabled = m_class_set.find(name) != m_class_set.end();
    pthread_mutex_unlock(&m_class_mutex);

    if (enabled) {
        [m_check_lock lock];
        auto it = m_check_map.find(name);
        if (it != m_check_map.end()) {
            it->second.insert((long long)object);
        }
        [m_check_lock unlock];
    }
}

#pragma mark - Public

#ifdef __cplusplus
extern "C" {
#endif

void leak_detector_register_class(Class c)
{
    leak_detector_register_object(c, 0);
}

void leak_detector_register_object(id object, int depth)
{
    [NSObject ss_registerDetectorSwizzleIfNeeded];
    if (!object) {
        return;
    }

    const char *name = object_getClassName(object);
    if (name[0] == '_') {
        return;
    }

    pthread_mutex_lock(&m_class_mutex);
    m_class_set.insert(object_getClassName(object));
    pthread_mutex_unlock(&m_class_mutex);

    [m_check_lock lock];
    auto it = m_check_map.find(name);
    if (it == m_check_map.end()) {
        m_check_map[name] = set<long long>();
    }
    [m_check_lock unlock];

    if ([object class] != object) {
        _detect_object_alloc(object);

        if (depth > 0) {
            Class currentClass = [object class];
            while (currentClass) {
                unsigned int count = 0;
                Ivar *total = class_copyIvarList(currentClass, &count);
                for (int i = 0; i < count; ++i) {
                    Ivar one = total[i];
                    const char *encoding = ivar_getTypeEncoding(one);
                    if (encoding[0] == '@') {
                        NSString *key = [NSString stringWithCString:ivar_getName(one) encoding:NSUTF8StringEncoding];
                        leak_detector_register_object([object valueForKey:key], depth - 1);
                    }
                }
                free(total);
                currentClass = class_getSuperclass(currentClass);
            }
        }
    }
}

void leak_detector_register_callback(void (^callback)(NSDictionary *business, NSDictionary *total), NSTimeInterval interval)
{
    [NSObject ss_registerDetectorSwizzleIfNeeded];

    static NSTimer *timer = nil;
    [timer invalidate];

    if (!callback) {
        return;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:MAX(interval, 1) repeats:YES block:^(NSTimer *timer) {
        [m_check_lock lock];
        NSMutableDictionary *business = [NSMutableDictionary dictionary];
        NSMutableDictionary *total = [NSMutableDictionary dictionary];
        for (auto it = m_check_map.begin(); it != m_check_map.end(); ++it) {
            NSString *name = [NSString stringWithUTF8String:it->first];
            NSMutableArray *array = [NSMutableArray array];
            for (auto p : it->second) {
                [array addObject:[NSString stringWithFormat:@"%p", (void *)p]];
            }
            if (array.count) {
                if (![name hasPrefix:@"CA"] &&
                    ![name hasPrefix:@"NS"] &&
                    ![name hasPrefix:@"UI"]) {
                    business[name] = array;
                }
                total[name] = array;
            }
        }
        [m_check_lock unlock];
        callback(business, total);
    }];
}

#ifdef __cplusplus
}
#endif

#pragma mark - Swizzle

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

@implementation NSObject (LeakDetector)

+ (id)ss_leak_detector_alloc
{
    id object = [self ss_leak_detector_alloc];
    _detect_object_alloc(object);
    return object;
}

- (void)ss_leak_detector_dealloc
{
    const char *name = object_getClassName(self);

    pthread_mutex_lock(&m_class_mutex);
    bool enabled = m_class_set.find(name) != m_class_set.end();
    pthread_mutex_unlock(&m_class_mutex);

    if (enabled) {
        [m_check_lock lock];
        auto it = m_check_map.find(name);
        if (it != m_check_map.end()) {
            it->second.erase((long long)self);
        }
        [m_check_lock unlock];
    }

    [self ss_leak_detector_dealloc];
}

+ (void)ss_registerDetectorSwizzleIfNeeded
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&m_class_mutex, NULL);
        m_check_lock = [[NSRecursiveLock alloc] init];

        SwizzleClassMethod([self class], NSSelectorFromString(@"alloc"), @selector(ss_leak_detector_alloc));
        SwizzleInstanceMethod([self class], NSSelectorFromString(@"dealloc"), @selector(ss_leak_detector_dealloc));
    });
}

@end
