//
//  SSBaseRequest+SSNetworking.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSBaseRequest.h"

@class SSRequestInternal;

@interface SSBaseRequest (SSNetworking)

@property (nonatomic, strong, readonly) SSRequestInternal *internal;

- (SSRequestResponse *)ss_responseWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)ss_parameterKeyValues;

- (NSString *)ss_cacheKey;

@end
