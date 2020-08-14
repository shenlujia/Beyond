//
//  SSRequestResponseHelper.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/30.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSRequestResponse.h"

////////////////////////////////////////////////////////////

@interface SSRequestResponseWrapper : NSObject

@property (nonatomic, strong, readonly) id request;
@property (nonatomic, strong, readonly) id response;

- (instancetype)initWithRequest:(id)request response:(id)response;

@end

////////////////////////////////////////////////////////////

@interface SSRequestResponse (SSNetworking)

@property (nonatomic, strong, readonly) NSMutableArray *dependentResponses;

- (void)addDependentResponsesFromArray:(NSArray *)array;

@end
