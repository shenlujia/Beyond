//
//  SimpleLeakDetector.mm
//  Demo
//
//  Created by ZZZ on 2020/11/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "SimpleLeakDetector.h"
#import <objc/runtime.h>
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

#define SSClassSet set<const char *, leak_detector_str_cmp>
#define SSCheckMap map<const char *, set<long long>, leak_detector_str_cmp>

static pthread_mutex_t m_class_mutex;
static SSClassSet m_class_set;

static NSRecursiveLock *m_check_lock;
static SSCheckMap m_check_map;

#pragma mark - SSLeakDetectorCallback

@implementation SSLeakDetectorCallback

- (void)updateWithData:(const SSCheckMap &)data
{
    NSMutableDictionary *total = [NSMutableDictionary dictionary];
    for (auto it = data.begin(); it != data.end(); ++it) {
        NSString *name = [NSString stringWithUTF8String:it->first];
        NSMutableArray *array = [NSMutableArray array];
        for (auto p : it->second) {
            [array addObject:[NSString stringWithFormat:@"%p", (void *)p]];
        }
        total[name] = array;
    }

    NSMutableDictionary *nonempty = [NSMutableDictionary dictionary];
    [total enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSArray *array, BOOL *stop) {
        if (array.count) {
            nonempty[name] = array;
        }
    }];

    NSMutableArray *business = [NSMutableArray array];
    NSMutableArray *more_than_once = [NSMutableArray array];
    [nonempty enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSArray *array, BOOL *stop) {
        if ([name hasPrefix:@"CA"] ||
            [name hasPrefix:@"NS"] ||
            [name hasPrefix:@"UI"]) {
            return;
        }
        [business addObject:[NSString stringWithFormat:@"%@ | %@", name, @(array.count)]];
        if (array.count > 1) {
            [more_than_once addObject:[NSString stringWithFormat:@"%@ | %@", @(array.count), name]];
        }
    }];
    [business sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    [more_than_once sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj2 compare:obj1];
    }];

    _total = total;
    _nonempty = nonempty;
    _business = business;
    _more_than_once = more_than_once;
}

@end

#pragma mark - Private

@interface NSObject (LeakDetector)

+ (void)ss_registerDetectorSwizzleIfNeeded;

@end

static inline bool _detect_object_alloc(id object)
{
    if (!object) {
        return false;
    }

    const char *name = object_getClassName(object);

    pthread_mutex_lock(&m_class_mutex);
    bool enabled = m_class_set.find(name) != m_class_set.end();
    pthread_mutex_unlock(&m_class_mutex);

    bool ret = false;
    if (enabled) {
        [m_check_lock lock];
        auto it = m_check_map.find(name);
        if (it != m_check_map.end()) {
            long long value = (long long)object;
            if (it->second.find(value) == it->second.end()) {
                it->second.insert(value);
                ret = true;
            }
        }
        [m_check_lock unlock];
    }
    return ret;
}

static inline bool _leak_detector_should_filter(const char *encoding)
{
    if (!encoding) {
        return true;
    }
    int len = (int)strlen(encoding);
    if (len <= 3) {
        return true;
    }
    if (encoding[0] != '@') {
        return true;
    }

    const int name_len = len - 3;
    char string[name_len + 1];
    memset(string, 0, name_len);
    memcpy(string, encoding + 2, name_len);
    if (strcmp(string, "NSMutableAttributedString") == 0 ||
        strcmp(string, "NSMutableString") == 0 ||
        strcmp(string, "NSString") == 0 ||
        strcmp(string, "NSURL") == 0) {
        return true;
    }

    return false;
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
        bool success = _detect_object_alloc(object);
        if (success && depth > 0) {
            Class currentClass = [object class];
            while (currentClass) {
                unsigned int count = 0;
                Ivar *total = class_copyIvarList(currentClass, &count);
                for (int i = 0; i < count; ++i) {
                    Ivar one = total[i];
                    const char *encoding = ivar_getTypeEncoding(one);
                    if (_leak_detector_should_filter(encoding)) {
                        continue;
                    }
                    id value = nil;
                    NSString *key = [NSString stringWithUTF8String:ivar_getName(one)];
                    @try {
                        value = [object valueForKey:key];
                    } @catch (NSException *exception) {
                        NSLog(@"%@", exception);
                    } @finally {

                    }
                    leak_detector_register_object(value, depth - 1);
                }
                free(total);
                currentClass = class_getSuperclass(currentClass);
            }
        }
    }
}

void leak_detector_register_callback(NSTimeInterval interval, void (^callback)(SSLeakDetectorCallback *object))
{
    [NSObject ss_registerDetectorSwizzleIfNeeded];

    static NSTimer *timer = nil;
    [timer invalidate];

    if (!callback) {
        return;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:MAX(interval, 1) repeats:YES block:^(NSTimer *timer) {
        [m_check_lock lock];
        SSCheckMap data = m_check_map;
        [m_check_lock unlock];
        SSLeakDetectorCallback *object = [[SSLeakDetectorCallback alloc] init];
        [object updateWithData:data];
        callback(object);
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
