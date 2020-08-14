//
//  SSRequestQueue.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSBaseRequest;

@interface SSRequestQueue : NSObject

+ (instancetype)sharedQueue;

- (void)addRequest:(SSBaseRequest *)request;
- (void)removeRequest:(SSBaseRequest *)request;

@end
