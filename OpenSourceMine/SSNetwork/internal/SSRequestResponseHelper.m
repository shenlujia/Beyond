//
//  SSRequestResponseHelper.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/30.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSRequestResponseHelper.h"
#import <objc/runtime.h>

#pragma mark - SSRequestResponseWrapper

@implementation SSRequestResponseWrapper

- (void)dealloc
{
    
}

- (instancetype)initWithRequest:(id)request response:(id)response
{
    self = [self init];
    _request = request;
    _response = response;
    return self;
}

@end

#pragma - mark - SSRequestResponse (SSNetworking)

@implementation SSRequestResponse (SSNetworking)

- (NSMutableArray *)dependentResponses
{
    NSMutableArray *object = objc_getAssociatedObject(self, _cmd);
    object = [object isKindOfClass:NSMutableArray.class] ? object : nil;
    if (!object) {
        object = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return object;
}

- (void)addDependentResponsesFromArray:(NSArray *)array
{
    for (SSRequestResponseWrapper *obj in array) {
        for (SSRequestResponseWrapper *local in [self.dependentResponses copy]) {
            if (local.request == obj.request) {
                [self.dependentResponses removeObject:local];
            }
        }
    }
    [self.dependentResponses addObjectsFromArray:array];
}

@end
