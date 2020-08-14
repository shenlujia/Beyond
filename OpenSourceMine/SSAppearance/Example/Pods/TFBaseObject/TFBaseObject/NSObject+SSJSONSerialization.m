//
//  NSObject+SSJSONSerialization.m
//  MJExtension
//
//  Created by admin on 2018/5/31.
//

#import "NSObject+SSJSONSerialization.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#import <MJExtension/MJExtension.h>
#pragma clang diagnostic pop

@implementation SSProperty

- (instancetype)initWithProperty:(MJProperty *)property
{
    self = [self init];
    
    if (self) {
        _name = [property.name copy];
        _srcClass = property.srcClass;
        _idType = property.type.idType;
        _typeClass = property.type.typeClass;
        _fromFoundation = property.type.fromFoundation;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[SSProperty class]]) {
        SSProperty *other = (SSProperty *)object;
        return [other.name isEqualToString:self.name] && other.srcClass == self.srcClass;
    }
    if ([object isKindOfClass:[NSString class]]) {
        NSString *other = (NSString *)object;
        return [other isEqualToString:self.description];
    }
    return NO;
}

- (NSString *)description
{
#ifdef DEBUG
    return [NSString stringWithFormat:@"%@.%@", NSStringFromClass(self.srcClass), self.name];
#else
    return [super description];
#endif
}

@end

@implementation NSObject (SSJSONSerialization)

+ (NSArray *)ss_ignoredSystemPropertyNames
{
    static NSArray *ret = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *array = @[@"debugDescription",
                           @"description",
                           @"hash",
                           @"superclass"];
        ret = [array copy];
    });
    return ret;
}

+ (NSDictionary<NSString *, NSArray<SSProperty *> *> *)ss_classProperties
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [[self class] mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        NSString *className = NSStringFromClass(property.srcClass);
        if (className && property.name) {
            NSMutableArray *properties = ret[className];
            if (!properties) {
                properties = [NSMutableArray array];
                ret[className] = properties;
            }
            SSProperty *temp = [[SSProperty alloc] initWithProperty:property];
            [properties addObject:temp];
        }
    }];
    
    for (NSMutableArray *array in ret.allValues) {
        [array sortUsingComparator:^NSComparisonResult(SSProperty *a1, SSProperty *a2) {
            return [a1.name compare:a2.name];
        }];
    }
    
    return [ret copy];
}

+ (NSArray<SSProperty *> *)ss_properties
{
    NSDictionary *classProperties = [self ss_classProperties];
    
    NSMutableArray *ret = [NSMutableArray array];
    Class srcClass = [self class];
    while (YES) {
        NSString *className = NSStringFromClass(srcClass);
        if (className.length == 0) {
            break;
        }
        
        NSArray *array = classProperties[className];
        NSMutableArray *temp = [NSMutableArray array];
        [temp addObjectsFromArray:array];
        [temp addObjectsFromArray:ret];
        ret = temp;
        
        srcClass = [srcClass superclass];
    }
    
    return [ret copy];
}

- (id)ss_keyValues
{
    if ([self isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id obj in (NSArray *)self) {
            id keyValues = [obj ss_keyValues];
            if (keyValues) {
                [array addObject:keyValues];
            }
        }
        return array;
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [((id)self) enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (obj != [obj class]) {
                id key_keyValues = [key ss_keyValues];
                id obj_keyValues = [obj ss_keyValues];
                if (key_keyValues && obj_keyValues) {
                    dictionary[key_keyValues] = obj_keyValues;
                }
            }
        }];
        return dictionary;
    }
    
    if ([self isKindOfClass:[NSDate class]]) {
        NSTimeInterval interval = [((NSDate *)self) timeIntervalSince1970];
        return @(interval);
    }
    
    id keyValues = [self mj_keyValues];
    if ([keyValues isKindOfClass:[NSDictionary class]]) {
        return [keyValues ss_keyValues];
    }
    
    return keyValues;
}

- (void)ss_setKeyValues:(id)keyValues
{
    NSDictionary *temp = [keyValues ss_keyValues];
    temp = [temp isKindOfClass:[NSDictionary class]] ? temp : nil;
    if (temp.count == 0) {
        return;
    }
    
    NSMutableDictionary *dictionary = [temp mutableCopy];
    NSArray *ignoredSystemPropertyNames = [NSObject ss_ignoredSystemPropertyNames];
    if (ignoredSystemPropertyNames.count) {
        [dictionary removeObjectsForKeys:ignoredSystemPropertyNames];
    }
    
    [self mj_setKeyValues:dictionary];
}

- (id)ss_copyIfAllowed
{
    if ([self isKindOfClass:[NSString class]]) {
        if ([self isKindOfClass:[NSMutableString class]]) {
            return [self mutableCopy];
        }
        return [self copy];
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        NSMutableArray *ret = [NSMutableArray array];
        for (id temp in (NSArray *)self) {
            id object = [temp ss_copyIfAllowed];
            if (object) {
                [ret addObject:object];
            }
        }
        if ([self isKindOfClass:[NSMutableArray class]]) {
            return ret;
        }
        return [ret copy];
    }
    
    if ([self isKindOfClass:[NSSet class]]) {
        NSMutableSet *ret = [NSMutableSet set];
        for (id temp in (NSSet *)self) {
            id object = [temp ss_copyIfAllowed];
            if (object) {
                [ret addObject:object];
            }
        }
        if ([self isKindOfClass:[NSMutableSet class]]) {
            return ret;
        }
        return [ret copy];
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        for (id key in ((NSDictionary *)self).allKeys) {
            id value = [((NSDictionary *)self) objectForKey:key];
            id newKey = [key ss_copyIfAllowed];
            id newValue = [value ss_copyIfAllowed];
            if (newKey && newValue) {
                ret[newKey] = newValue;
            }
        }
        if ([self isKindOfClass:[NSMutableDictionary class]]) {
            return ret;
        }
        return [ret copy];
    }
    
    if ([self conformsToProtocol:@protocol(NSCopying)]) {
        return [self copy];
    }
    return self;
}

@end
