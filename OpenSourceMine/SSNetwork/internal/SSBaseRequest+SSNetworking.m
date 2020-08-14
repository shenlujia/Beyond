//
//  SSBaseRequest+SSNetworking.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSBaseRequest+SSNetworking.h"
#import "SSRequestResponse.h"
#import "SSNetworkConfiguration.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#import <MJExtension.h>
#pragma clang diagnostic pop

@implementation SSBaseRequest (SSNetworking)

- (SSRequestInternal *)internal
{
    return self->_internal;
}

- (SSRequestResponse *)ss_responseWithDictionary:(NSDictionary *)dictionary
{
    if (![dictionary isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    id cls = self.dataObjectClass;
    return [[SSRequestResponse alloc] initWithDictionary:dictionary dataClass:cls];
}

- (NSDictionary *)ss_parameterKeyValues
{
    NSMutableArray *keys = [NSMutableArray array];
    [self.class mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        if (property.name && property.srcClass != [SSBaseRequest class]) {
            [keys addObject:property.name];
        }
    }];
    
    NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
    for (NSString *key in keys) {
        id value = [self valueForKey:key];
        keyValues[key] = [self.class ss_keyValuesWithObject:value];
    }
    NSDictionary *replacedKeys = nil;
    if ([self.class respondsToSelector:@selector(replacedKeyFromParameterName)]) {
        replacedKeys = [self.class replacedKeyFromParameterName];
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [keyValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        if (obj != [obj class]) {
            NSString *realKey = replacedKeys[key] ? : key;
            result[realKey] = obj;
        }
    }];
    return result;
}

+ (id)ss_keyValuesWithObject:(id)object
{
    id value = nil;
    if ([object isKindOfClass:NSArray.class]) {
        value = [SSBaseRequest ss_keyValuesWithArray:(NSArray *)object];
    }
    else {
        value = [object mj_keyValues];
    }
    return value;
}

+ (NSArray *)ss_keyValuesWithArray:(NSArray *)array
{
    NSMutableArray *result = [NSMutableArray array];
    for (id object in array) {
        id value = [SSBaseRequest ss_keyValuesWithObject:object];
        if (value) {
            [result addObject:value];
        }
    }
    return [result copy];
}

- (NSString *)ss_cacheKey
{
    NSDictionary *keyValues = [self ss_parameterKeyValues];
    NSArray *keys = keyValues.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableString *result = [NSMutableString string];
    
    NSString *URLString = [self URLString];
    NSString *clientId = [[SSNetworkConfiguration sharedInstance] clientId];
    [result appendFormat:@"%@|%@", URLString, clientId];
    for (NSString *key in keys) {
        [result appendFormat:@"|%@=%@", key, keyValues[key]];
    }
    return result;
}

@end
