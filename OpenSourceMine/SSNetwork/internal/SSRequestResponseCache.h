//
//  SSRequestResponseCache.h
//  Pods
//
//  Created by shenlujia on 2017/8/16.
//
//

#import <UIKit/UIKit.h>

@interface SSRequestResponseCache : NSObject

+ (instancetype)sharedCache;

- (id)cacheForKey:(NSString *)key;

- (void)setCache:(id)cache forKey:(NSString *)key;

- (void)cleanup;

@end
