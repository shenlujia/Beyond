//
//  SimpleLeakDetectorMRC.mm
//  Demo
//
//  Created by ZZZ on 2020/11/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "SimpleLeakDetectorMRC.h"
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import <map>
#import <set>
#import <vector>
#import <pthread.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

using namespace std;

struct leak_detector_str_cmp : public binary_function<const char *, const char *, bool>
{
    bool operator()(const char *s1, const char *s2) const
    {
        return strcmp(s1, s2) < 0;
    }
};

#define SSCheckMap map<const char *, set<uintptr_t>, leak_detector_str_cmp>
static SSCheckMap m_check_map;

static pthread_mutex_t m_data_mutex;
#define CHECK_MAP_LOCKING(action) \
do { \
pthread_mutex_lock(&m_data_mutex); action; pthread_mutex_unlock(&m_data_mutex); \
} while (NO)

static bool m_delay_dealloc_flag;
static set<uintptr_t> m_delay_dealloc_set;
static pthread_mutex_t m_delay_dealloc_mutex;
#define DELAY_DEALLOC_LOCKING(action) \
do { \
pthread_mutex_lock(&m_delay_dealloc_mutex); action; pthread_mutex_unlock(&m_delay_dealloc_mutex); \
} while (NO)

static inline bool _leak_detector_should_filter_class(const char *class_name)
{
    if (!class_name) {
        return true;
    }
    if (strncmp(class_name, "_", 1) == 0) { // 内部类一个一个处理太麻烦，一次性屏蔽
        return true;
    }
    if (strncmp(class_name, "NSTagged", 8) == 0) {
        return true;
    }
    if (strcmp(class_name, "NSAutoreleasePool") == 0) {
        return true;
    }
    return false;
}

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

@implementation NSObject (LeakDetector)

+ (id)ss_leak_detector_alloc
{
    id object = [self ss_leak_detector_alloc];
    const char *name = object_getClassName(object);

    if (!_leak_detector_should_filter_class(name)) {
        CHECK_MAP_LOCKING({
            auto it = m_check_map.find(name);
            if (it == m_check_map.end()) {
                m_check_map[name] = set<uintptr_t>();
                it = m_check_map.find(name);
            }
            it->second.insert((uintptr_t)object);
        });
    }
    return object;
}

- (void)ss_leak_detector_dealloc
{
    const char *name = object_getClassName(self);

    CHECK_MAP_LOCKING({
        auto it = m_check_map.find(name);
        if (it != m_check_map.end()) {
            it->second.erase((uintptr_t)self);
        }
    });

    bool should_delay = false;
    DELAY_DEALLOC_LOCKING({
        should_delay = m_delay_dealloc_flag;
        if (should_delay) {
            m_delay_dealloc_set.insert((uintptr_t)self);
        }
    });

    if (!should_delay) {
        [self ss_leak_detector_dealloc];
    }
}

@end

@implementation SimpleLeakDetectorMRC

+ (void)run
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&m_data_mutex, NULL);
        m_delay_dealloc_flag = false;
        pthread_mutex_init(&m_delay_dealloc_mutex, NULL);
        Class c = [NSObject class];
        SwizzleInstanceMethod(object_getClass(c), NSSelectorFromString(@"alloc"), @selector(ss_leak_detector_alloc));
        SwizzleInstanceMethod(c, NSSelectorFromString(@"dealloc"), @selector(ss_leak_detector_dealloc));
    });
}

+ (void)enumPointersWithBlock:(void (^)(const char *, uintptr_t))block
{
    if (!block) {
        return;
    }
    SSCheckMap check_map;
    CHECK_MAP_LOCKING({
        check_map = m_check_map;
    });
    for (auto it : check_map) {
        for (auto value : it.second) {
            block(it.first, value);
        }
    }
}

+ (BOOL)isPointerValidWithClassName:(const char *)name pointer:(uintptr_t)pointer
{
    BOOL ret = NO;
    CHECK_MAP_LOCKING({
        if (name) {
            auto it = m_check_map.find(name);
            if (it != m_check_map.end()) {
                ret = it->second.find(pointer) != it->second.end();
            }
        }
    });
    return ret;
}

+ (void)addPointerWithClassName:(const char *)name pointer:(uintptr_t)pointer
{
    if (!name) {
        return;
    }
    CHECK_MAP_LOCKING({
        auto it = m_check_map.find(name);
        if (it == m_check_map.end()) {
            m_check_map[name] = set<uintptr_t>();
            it = m_check_map.find(name);
        }
        it->second.insert(pointer);
    });
}

+ (void)enableDelayDealloc
{
    DELAY_DEALLOC_LOCKING({
        m_delay_dealloc_flag = true;
    });
}

+ (void)disableDelayDealloc
{
    set<uintptr_t> dealloc_set;

    DELAY_DEALLOC_LOCKING({
        dealloc_set = m_delay_dealloc_set;
        m_delay_dealloc_set.clear();
        m_delay_dealloc_flag = false;
    });

    for (uintptr_t p : dealloc_set) {
        NSObject *obj = (NSObject *)p;
        [obj ss_leak_detector_dealloc];
    }
}

@end
