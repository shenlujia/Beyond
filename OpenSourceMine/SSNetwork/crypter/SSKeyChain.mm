//
//  SSKeyChain.m
//  AFNetworking
//
//  Created by shenlujia on 2018/1/16.
//

#import "SSKeyChain.h"
#import "SAMKeychainQuery.h"

#define p_valid_service p_convert_0

@implementation SSKeyChain

+ (id)objectForKey:(NSString *)key
{
    return [self objectForKey:key service:nil];
}

+ (void)setObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key service:nil];
}

+ (id)objectForKey:(NSString *)key service:(NSString *)service
{
    if (!key) {
        return nil;
    }
    
    NSError *error = nil;
    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    query.service = [self p_valid_service:service];
    query.account = key;
    [query fetch:&error];
    id object = query.passwordObject;
    return object;
}

+ (void)setObject:(id)object forKey:(NSString *)key service:(NSString *)service
{
    if (!key) {
        return;
    }
    
    NSError *error = nil;
    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    query.service = [self p_valid_service:service];
    query.account = key;
    if (object) {
        query.passwordObject = object;
        [query save:&error];
    } else {
        [query deleteItem:&error];
    }
}

+ (NSString *)p_valid_service:(NSString *)service
{
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    if (identifier.length == 0) {
        identifier = @"com.cn.ssnetwork";
    }
    service = service ? : @"common";
    return [NSString stringWithFormat:@"%@.%@", identifier, service];
}

@end
