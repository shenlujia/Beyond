//
//  SSBaseRequest.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSBaseRequest.h"
#import "SSRequestQueue.h"
#import "SSRequestInternal.h"
#import "SSBaseRequest+SSNetworking.h"
#import "SSRequestResponse.h"
#import "SSRequestResponseCache.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#import <MJExtension.h>
#pragma clang diagnostic pop

@interface SSBaseRequest ()

@end

@implementation SSBaseRequest

- (void)dealloc
{
    [self cancel];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _internal = [[SSRequestInternal alloc] initWithRequest:self];
        _retryCount = 0;
        _retryInterval = 0;
        _logEnabled = YES;
    }
    return self;
}

#pragma mark - public

- (NSDictionary *)parameterKeyValues
{
    return [self ss_parameterKeyValues];
}

- (SSRequestState)state
{
    return [self.internal state];
}

- (void)start
{
    [self startWithBlock:self.didFinish];
}

- (void)startWithBlock:(SSRequestDidFinish)block
{
    // 方便设置依赖项 下一个runloop才调用start
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        const SSRequestState state = [self.internal state];
        if (state == SSRequestStateInit) {
            // 这里必须强引用self
            self.didFinish = [block copy];
            [self.internal start];
        } else {
            SSNetworkLog(@"WARNING!!! state != SSRequestStateInit");
        }
    }];
}

- (void)cancel
{
    NSParameterAssert([NSThread isMainThread]);
    
    [self.internal cancel];
}

- (void)addDependency:(SSBaseRequest *)request
{
    NSParameterAssert([NSThread isMainThread]);
    NSParameterAssert([self state] == SSRequestStateInit ||
                      [self state] == SSRequestStatePrepared);
    
    if (![request isKindOfClass:SSBaseRequest.class]) {
        return;
    }
    
    NSMutableArray *dependencies = [NSMutableArray arrayWithArray:self.dependencies];
    if (![dependencies containsObject:request]) {
        [dependencies addObject:request];
    }
    _dependencies = [dependencies copy];
    [request.internal addRequestBeDepended:self];
}

- (void)removeDependency:(SSBaseRequest *)request
{
    NSParameterAssert([NSThread isMainThread]);
    
    if (![request isKindOfClass:SSBaseRequest.class]) {
        return;
    }
    
    NSMutableArray *dependencies = [NSMutableArray arrayWithArray:self.dependencies];
    [dependencies removeObject:request];
    _dependencies = [dependencies copy];
    [request.internal removeRequestBeDepended:self];
}

- (SSRequestResponse *)cache
{
    NSString *key = [self ss_cacheKey];
    id cache = [[SSRequestResponseCache sharedCache] cacheForKey:key];
    return [self ss_responseWithDictionary:cache];
}

- (void)clearCache
{
    [[SSRequestResponseCache sharedCache] setCache:nil forKey:[self ss_cacheKey]];
}

@end
