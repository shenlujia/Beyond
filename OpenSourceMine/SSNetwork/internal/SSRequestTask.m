//
//  SSRequestTask.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/13.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSRequestTask.h"
#import "SSBaseRequest.h"
#import "AFHTTPSessionManager.h"

@interface SSRequestTask ()

@end

@implementation SSRequestTask

- (void)dealloc
{
    [self cleanup];
}

- (instancetype)initWithRequest:(SSBaseRequest *)request
                           task:(NSURLSessionTask *)task
                        manager:(AFHTTPSessionManager *)manager
{
    self = [self init];
    
    _request = request;
    _task = task;
    _manager = manager;
    
    return self;
}

- (void)cleanup
{
    [_task cancel];
    _task = nil;
    _request = nil;
    [_manager invalidateSessionCancelingTasks:YES];
}

@end
