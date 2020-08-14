//
//  SSRequestInternal.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNetworkGlobalDefs.h"

@interface SSRequestInternal : NSObject

@property (nonatomic, weak, readonly) SSBaseRequest *request;
@property (nonatomic, copy, readonly) NSString *UUIDString;

@property (nonatomic, copy, readonly) SSRequestProgress progressWrapper;
@property (nonatomic, copy, readonly) SSRequestDidFinish completionWrapper;

- (instancetype)initWithRequest:(SSBaseRequest *)request;

- (void)start;

- (void)cancel;
- (void)cleanup;

- (SSRequestState)state;

- (void)addRequestBeDepended:(SSBaseRequest *)request;
- (void)removeRequestBeDepended:(SSBaseRequest *)request;

@end
