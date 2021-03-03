//
//  SimpleLeakDetectorMRC.mm
//  Demo
//
//  Created by ZZZ on 2020/11/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "SimpleLeakDetectorMRC.h"
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import <objc/runtime.h>
#import <map>
#import <pthread.h>
#import <string>
#import <set>
#import <vector>
#import <malloc/malloc.h>
#import "SimpleLeakDetectorInternal.h"

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
} while (NO);

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

    static const vector<const char *> full_match = {"NSString", "NSArray", "NSURL", "GPBAutocreatedArray"};
    for (auto s : full_match) {
        if (strcmp(class_name, s) == 0) {
            return true;
        }
    }

    static const vector<const char *> prefix_match = {"CA", "UI", "FB", "NS", "OS_", "_"};
    for (auto s : prefix_match) {
        if (strncmp(class_name, s, strlen(s)) == 0) {
            return true;
        }
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
    })

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

+ (void)enumObjectsWithBlock:(void (^)(const char *class_name, uintptr_t pointer))block
{
    if (!block) {
        return;
    }
    CHECK_MAP_LOCKING({
        for (auto &it : m_check_map) {
            for (auto value : it.second) {
                block(it.first, value);
            }
        }
    })
}

+ (void)enableDelayDealloc
{
    DELAY_DEALLOC_LOCKING({
        m_delay_dealloc_flag = true;
    });
}

+ (void)disableDelayDealloc
{
    set<uintptr_t> delay_set;

    DELAY_DEALLOC_LOCKING({
        delay_set = m_delay_dealloc_set;
        m_delay_dealloc_set.clear();
        m_delay_dealloc_flag = false;
    });

    for (uintptr_t p : delay_set) {
        NSObject *obj = (NSObject *)p;
        [obj ss_leak_detector_dealloc];
    }
}

@end
