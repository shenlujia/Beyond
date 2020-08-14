//
//  SSRequestTask.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/13.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSBaseRequest;
@class AFHTTPSessionManager;

@interface SSRequestTask : NSObject

@property (nonatomic, strong, readonly) SSBaseRequest *request;
@property (nonatomic, strong, readonly) NSURLSessionTask *task;
@property (nonatomic, strong, readonly) AFHTTPSessionManager *manager;

- (instancetype)initWithRequest:(SSBaseRequest *)request
                           task:(NSURLSessionTask *)task
                        manager:(AFHTTPSessionManager *)manager;

@end
