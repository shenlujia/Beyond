//
//  SimpleLeakDetector.mm
//  Demo
//
//  Created by ZZZ on 2020/11/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "SimpleLeakDetector.h"
#import <FBRetainCycleDetector/FBRetainCycleDetector.h>
#import <objc/runtime.h>
#import <map>
#import <pthread.h>
#import <string>
#import <set>
#import <vector>
#import "SSFLEXHeapEnumerator.h"
#import <malloc/malloc.h>

using namespace std;

struct leak_detector_str_cmp : public binary_function<const char *, const char *, bool>
{
    bool operator()(const char *s1, const char *s2) const
    {
        return strcmp(s1, s2) < 0;
    }
};

#define SSCheckMap map<const char *, set<long long>, leak_detector_str_cmp>

static SSCheckMap m_check_map;
static set<string> m_find_owner_set;
static pthread_mutex_t m_data_mutex;
static SSLeakDetectorCallback *m_last_record;

#pragma mark - SSLeakDetectorCallback

@implementation SSLeakDetectorCallback

- (void)updateWithData:(const SSCheckMap &)data last_nonempty:(NSDictionary *)last_nonempty last_diffs:(NSArray *)last_diffs
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
    [self updateWithDictionary:total last_nonempty:last_nonempty last_diffs:last_diffs];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary last_nonempty:(NSDictionary *)last_nonempty last_diffs:(NSArray *)last_diffs
{
    NSMutableDictionary *nonempty = [NSMutableDictionary dictionary];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSArray *array, BOOL *stop) {
        if (array.count) {
            nonempty[name] = array;
        }
    }];

    NSMutableArray *business = [NSMutableArray array];
    NSString *separator = @"  |  ";
    [nonempty enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSArray *array, BOOL *stop) {
        if ([name hasPrefix:@"CA"] ||
            [name hasPrefix:@"NS"] ||
            [name hasPrefix:@"UI"]) {
            return;
        }
        [business addObject:[NSString stringWithFormat:@"%@%@%@", name, separator, @(array.count)]];
    }];
    [business sortUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
        return [a compare:b];
    }];

    NSMutableArray *more_than_once = [NSMutableArray array];
    [business enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSArray *components = [obj componentsSeparatedByString:separator];
        components = @[components.lastObject, components.firstObject];
        if ([components.firstObject integerValue] > 1) {
            [more_than_once addObject:components];
        }
    }];
    [more_than_once sortUsingComparator:^NSComparisonResult(NSArray *a, NSArray *b) {
        NSInteger x = [a.firstObject integerValue];
        NSInteger y = [b.firstObject integerValue];
        if (x == y) {
            return [a.lastObject compare:b.lastObject];
        }
        return x < y ? NSOrderedDescending : NSOrderedAscending;
    }];
    [[more_than_once copy] enumerateObjectsUsingBlock:^(NSArray *a, NSUInteger idx, BOOL *stop) {
        more_than_once[idx] = [NSString stringWithFormat:@"%@%@%@", a.firstObject, separator, a.lastObject];
    }];

    _total = dictionary;
    _nonempty = nonempty;
    _business = business;
    _more_than_once = more_than_once;

    if (last_nonempty) {
        NSMutableDictionary *diff = [NSMutableDictionary dictionary];
        [nonempty enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
            NSArray *old = last_nonempty[key];
            NSInteger count = obj.count - old.count;
            if (count > 0) {
                diff[key] = @(count);
            }
        }];

        NSMutableArray *diffs = [NSMutableArray arrayWithArray:last_diffs];
        if (diff.count) {
            [diffs addObject:diff];
        }
        _diffs = diffs;
    }
}

- (void)resetOwnersWithClasses:(const set<string> &)find_owner_set
{
    return;
    
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *owners = [NSMutableArray array];

    CFMutableDictionaryRef mutableCountsForClasses = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    {
        unsigned int classCount = 0;
        Class *classes = objc_copyClassList(&classCount);

        for (unsigned int i = 0; i < classCount; i++) {
            CFDictionarySetValue(mutableCountsForClasses, (__bridge const void *)classes[i], (const void *)0);
        }

        [SSFLEXHeapEnumerator enumerateLiveObjectsUsingBlock:^(__unsafe_unretained id object, __unsafe_unretained Class actualClass) {
            if (malloc_size((__bridge const void *)(object)) > 0 &&
                strcmp(class_getName(actualClass), "NSAutoreleasePool") != 0 &&
                strncmp(class_getName(actualClass), "_", 1) != 0 &&
                strncmp(class_getName(actualClass), "NSTagged", 8) != 0 &&
                strncmp(class_getName(actualClass), "UI", 2) != 0 &&
                strncmp(class_getName(actualClass), "NS", 2) != 0 &&
                strncmp(class_getName(actualClass), "NWCon", 5) != 0 &&
                strncmp(class_getName(actualClass), "FLEX", 4) != 0 &&
                strncmp(class_getName(actualClass), "FB", 2) != 0) {
                [objects addObject:object];
            }
            NSUInteger instanceCount = (NSUInteger)CFDictionaryGetValue(mutableCountsForClasses, (__bridge const void *)actualClass);
            instanceCount++;
            CFDictionarySetValue(mutableCountsForClasses, (__bridge const void *)actualClass, (const void *)instanceCount);
        }];
        free(classes);
        NSLog(@"class count = %@", @(classCount));
    }

    unsigned int classCount = 0;
    Class *classes = objc_copyClassList(&classCount);

    NSMutableDictionary<NSString *, NSNumber *> *mutableCountsForClassNames = [NSMutableDictionary dictionary];
    for (unsigned int i = 0; i < classCount; i++) {
        Class c = classes[i];
        NSUInteger instanceCount = (NSUInteger)CFDictionaryGetValue(mutableCountsForClasses, (__bridge const void *)(c));
        NSString *className = @(class_getName(c));
        if (instanceCount > 0) {
            [mutableCountsForClassNames setObject:@(instanceCount) forKey:className];
        }
    }
    free(classes);

    for (NSObject *object in objects) {
        if ([object isKindOfClass:[NSSet class]] ||
            [object isKindOfClass:[NSArray class]] ||
            [object isKindOfClass:[NSDictionary class]] ||
            [object isKindOfClass:[NSAttributedString class]]) {
            continue;
        }
        FBObjectGraphConfiguration *configuration = [[FBObjectGraphConfiguration alloc] init];
        FBObjectiveCObject *c = [[FBObjectiveCObject alloc] initWithObject:object configuration:configuration];
        if (c.object) {
            NSSet *allRetainedObjects = [c allRetainedObjects];
            for (NSObject *obj in allRetainedObjects) {
                string name = string(class_getName([obj class]));
                if (find_owner_set.find(name) != find_owner_set.end()) {
                    [owners addObject:[object class]];
                }
            }
        }
    }


    NSLog(@"");
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

    bool ret = false;
    pthread_mutex_lock(&m_data_mutex);
    auto it = m_check_map.find(name);
    if (it != m_check_map.end()) {
        long long value = (long long)object;
        if (it->second.find(value) == it->second.end()) {
            it->second.insert(value);
            ret = true;
        }
    }
    pthread_mutex_unlock(&m_data_mutex);

    return ret;
}

static inline bool _leak_detector_should_filter(Ivar ivar)
{
    if (!ivar) {
        return true;
    }
    const char *encoding = ivar_getTypeEncoding(ivar);
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

    return false;
}

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

    static const vector<const char *> prefix_match = {"OS_", "_"};
    for (auto s : prefix_match) {
        if (strncmp(class_name, s, strlen(s)) == 0) {
            return true;
        }
    }

    return false;
}

#pragma mark - Public

#ifdef __cplusplus
extern "C" {
#endif

void leak_detector_find_owner_of_class(Class c)
{
    [NSObject ss_registerDetectorSwizzleIfNeeded];
    pthread_mutex_lock(&m_data_mutex);
    m_find_owner_set.insert(string(class_getName(c)));
    pthread_mutex_unlock(&m_data_mutex);
}

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

    const char *class_name = object_getClassName(object);
    if (_leak_detector_should_filter_class(class_name)) {
        return;
    }

    pthread_mutex_lock(&m_data_mutex);
    auto it = m_check_map.find(class_name);
    if (it == m_check_map.end()) {
        m_check_map[class_name] = set<long long>();
    }
    pthread_mutex_unlock(&m_data_mutex);

    if ([object class] != object) {
        bool success = _detect_object_alloc(object);
        if (success && depth > 0) {
            Class currentClass = [object class];
            while (currentClass) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if (![currentClass performSelector:@selector(accessInstanceVariablesDirectly)]) {
                    break;
                }
#pragma clang diagnostic pop
                unsigned int count = 0;
                Ivar *total = class_copyIvarList(currentClass, &count);
                for (int i = 0; i < count; ++i) {
                    Ivar one = total[i];
                    if (_leak_detector_should_filter(one)) {
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

void leak_detector_register_callback(NSTimeInterval interval, void (^callback)(id object))
{
    [NSObject ss_registerDetectorSwizzleIfNeeded];

    static NSTimer *timer = nil;
    [timer invalidate];

    if (!callback) {
        return;
    }
    if (@available(iOS 10, *)) {
        timer = [NSTimer scheduledTimerWithTimeInterval:MAX(interval, 1) repeats:YES block:^(NSTimer *timer) {
            pthread_mutex_lock(&m_data_mutex);
            SSCheckMap data = m_check_map;
            set<string> find_owner_set = m_find_owner_set;
            pthread_mutex_unlock(&m_data_mutex);

            SSLeakDetectorCallback *object = [[SSLeakDetectorCallback alloc] init];
            [object updateWithData:data last_nonempty:nil last_diffs:nil];
            [object resetOwnersWithClasses:find_owner_set];
            callback(object);
            m_last_record = object;
            [object release];
        }];
    }
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

    pthread_mutex_lock(&m_data_mutex);
    auto it = m_check_map.find(name);
    if (it != m_check_map.end()) {
        it->second.erase((long long)self);
    }
    pthread_mutex_unlock(&m_data_mutex);

    [self ss_leak_detector_dealloc];
}

+ (void)ss_registerDetectorSwizzleIfNeeded
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&m_data_mutex, NULL);
        SwizzleInstanceMethod(object_getClass([self class]), NSSelectorFromString(@"alloc"), @selector(ss_leak_detector_alloc));
        SwizzleInstanceMethod([self class], NSSelectorFromString(@"dealloc"), @selector(ss_leak_detector_dealloc));
    });
}

@end
