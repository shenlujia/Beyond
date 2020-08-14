//
//  SSKeyChain.h
//  AFNetworking
//
//  Created by shenlujia on 2018/1/16.
//

#import <Foundation/Foundation.h>

#define ss_k_c SSKeyChain

@interface SSKeyChain : NSObject

+ (id)objectForKey:(NSString *)key;
+ (void)setObject:(id)object forKey:(NSString *)key;

+ (id)objectForKey:(NSString *)key service:(NSString *)service;
+ (void)setObject:(id)object forKey:(NSString *)key service:(NSString *)service;

@end
