//
//  SSRequestResponse.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNetworkGlobalDefs.h"

@class SSBaseRequest;

@interface SSRequestResponseKind : NSObject

@property (nonatomic, assign, readonly) NSInteger productType;
@property (nonatomic, assign, readonly) NSInteger moduleType;
@property (nonatomic, assign, readonly) NSInteger subModuleType;
@property (nonatomic, assign, readonly) NSInteger errCode;

@property (nonatomic, assign, readonly) BOOL errorMessageEnabled;

@end

@interface SSRequestResponse : NSObject

@property (nonatomic, copy, readonly) NSNumber *result;
@property (nonatomic, copy, readonly) NSString *kind;
@property (nonatomic, copy, readonly) NSString *msg;
@property (nonatomic, copy, readonly) NSString *nowTime;
@property (nonatomic, copy, readonly) id data;

@property (nonatomic, strong, readonly) SSRequestResponseKind *kindObject;
@property (nonatomic, copy, readonly) NSError *error;

@property (nonatomic, copy, readonly) NSDictionary *rawDictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary dataClass:(Class)cls;

- (instancetype)initWithError:(NSError *)error;

- (instancetype)initWithErrorCode:(SSRequestErrorCode)code;

// 返回指定依赖项的response
- (SSRequestResponse *)responseForDependency:(SSBaseRequest *)request;
// 返回第一个符合条件的依赖项的response
- (SSRequestResponse *)responseForClass:(Class)requestClass;
- (SSRequestResponse *)responseForIdentifier:(NSString *)requestIdentifier;

@end
