//
//  NSObject+SSJSON.m — stub
//

#import "NSObject+SSJSON.h"
#import <objc/runtime.h>

@implementation NSObject (SSJSON)

- (id)ss_JSON
{
    if ([self isKindOfClass:[NSString class]] ||
        [self isKindOfClass:[NSNumber class]] ||
        [self isKindOfClass:[NSNull class]]) {
        return self;
    }
    if ([self isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [NSMutableArray array];
        for (id item in (NSArray *)self) {
            [result addObject:[item ss_JSON]];
        }
        return result;
    }
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *result = [NSMutableDictionary dictionary];
        [(NSDictionary *)self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isKindOfClass:[NSString class]]) {
                result[key] = [obj ss_JSON];
            } else {
                result[[NSString stringWithFormat:@"%@", key]] = [obj ss_JSON];
            }
        }];
        return result;
    }
    // Fallback: return description
    return [NSString stringWithFormat:@"%@", self];
}

- (id)ss
{
    return [self ss_JSON];
}

- (id)ss_keyValues
{
    if ([self isKindOfClass:[NSDictionary class]]) {
        return self;
    }
    if ([self isKindOfClass:[NSMapTable class]]) {
        NSMapTable *mt = (NSMapTable *)self;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSEnumerator *keyEnum = [mt keyEnumerator];
        id key;
        while ((key = [keyEnum nextObject])) {
            dict[key] = [mt objectForKey:key] ?: [NSNull null];
        }
        return dict;
    }
    if ([self isKindOfClass:[NSArray class]]) {
        return self;
    }
    // Generic ivar dump
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *name = ivar_getName(ivars[i]);
        if (name) {
            NSString *key = [NSString stringWithUTF8String:name];
            @try {
                id value = [self valueForKey:key];
                result[key] = value ?: [NSNull null];
            } @catch (__unused NSException *e) { }
        }
    }
    free(ivars);
    return result;
}

@end
