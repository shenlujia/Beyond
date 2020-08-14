//
//  SSRequestResponse.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSRequestResponse.h"
#import "SSRequestResponseHelper.h"
#import "SSBaseRequest.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#import <MJExtension.h>
#pragma clang diagnostic pop

NSString * const SSRequestDataErrorDomain = @"SSRequestDataErrorDomain";
NSString * const SSRequestOperationErrorDomain = @"SSRequestOperationErrorDomain";
NSString * const SSRequestDependencyErrorDomain = @"SSRequestDependencyErrorDomain";

@implementation SSRequestResponseKind

- (instancetype)initWithKind:(NSString *)kind
{
    self = [self init];
    
    //61 00 10000 100 003  610010000100003
    kind = [kind isKindOfClass:NSString.class] ? kind : nil;
    
    if (kind.integerValue == 0) {
        return nil;
    }
    
    if (kind.length == 4) {
        
        _errCode = [kind integerValue];
        
        _errorMessageEnabled = [self.class errorMessageEnabled:self.errCode];
        
        return self;
    }
    else if (kind.length == 15) {
        
        _productType = [[kind substringWithRange:NSMakeRange(2, 2)] integerValue];
        _moduleType = [[kind substringWithRange:NSMakeRange(4, 5)] integerValue];
        _subModuleType = [[kind substringWithRange:NSMakeRange(9, 3)] integerValue];
        _errCode = [[kind substringWithRange:NSMakeRange(12, 3)] integerValue];
        
        NSString *text = [kind substringWithRange:NSMakeRange(0, 2)];
        _errorMessageEnabled = text.integerValue == 60;
       
        return self;
    }
    
    return nil;
}

+ (BOOL)errorMessageEnabled:(NSInteger)code
{
    switch (code) {
        case 1001:
        case 1002:
        case 1003:
        case 1004:
        case 1005:
        case 1006:
        case 1007:
            
        case 4444:
            
        case 5001:
        case 5002:
        case 5003:
        case 5004:
        case 5005:
        
        case 6001:
        case 6002:
        case 6003:
        case 6004:
        case 6005:
        case 6006:
        case 6007: {
            return YES;
        }
        default: {
            return NO;
        }
    }
}

@end

@implementation SSRequestResponse

- (instancetype)initWithDictionary:(NSDictionary *)dictionary dataClass:(Class)cls
{
    self = [self init];
    
    dictionary = [dictionary isKindOfClass:NSDictionary.class] ? dictionary : nil;
    _rawDictionary = [dictionary copy];
    [self mj_setKeyValues:dictionary];
    
    if (self.result.boolValue) {
        _data = [self.class ss_createObjectWithRawValue:self.data dataClass:cls];
        _error = nil;
    }
    else {
        _error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:dictionary];
    }
    
    _kindObject = [[SSRequestResponseKind alloc] initWithKind:self.kind];
    if (!self.kindObject || !self.kindObject.errorMessageEnabled) {
        _msg = nil;
    }
    
    return self;
}

- (instancetype)initWithError:(NSError *)error
{
    self = [self init];
    
    _result = @(NO);
    if (!error) {
        error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil];
    }
    _error = [error copy];
    
    return self;
}

- (instancetype)initWithErrorCode:(SSRequestErrorCode)code
{
    self = [self init];
    
    NSString *errorDomain = nil;
    switch (code) {
        case SSRequestErrorCodeDataInvalid: {
            errorDomain = SSRequestDataErrorDomain;
            break;
        }
        case SSRequestErrorCodeOperationCancelled: {
            errorDomain = SSRequestOperationErrorDomain;
            break;
        }
        case SSRequestErrorCodeDependencyCancelled:
        case SSRequestErrorCodeDependencyFailed: {
            errorDomain = SSRequestDependencyErrorDomain;
            break;
        }
        default: {
            NSParameterAssert(0);
            break;
        }
    }
    NSParameterAssert(errorDomain);
    
    _result = @(NO);
    _error = [NSError errorWithDomain:errorDomain code:code userInfo:nil];
    
    return self;
}

- (SSRequestResponse *)responseForDependency:(SSBaseRequest *)request
{
    for (SSRequestResponseWrapper *object in self.dependentResponses) {
        if (object.request == request) {
            return object.response;
        }
    }
    return nil;
}

- (SSRequestResponse *)responseForClass:(Class)requestClass
{
    if (requestClass) {
        for (SSRequestResponseWrapper *object in self.dependentResponses) {
            if (((NSObject *)object.request).class == requestClass) {
                return object.response;
            }
        }
    }
    return nil;
}

- (SSRequestResponse *)responseForIdentifier:(NSString *)requestIdentifier
{
    if (requestIdentifier) {
        for (SSRequestResponseWrapper *object in self.dependentResponses) {
            NSString *identifier = ((SSBaseRequest *)object.request).identifier;
            if ([identifier isEqualToString:identifier]) {
                return object.response;
            }
        }
    }
    return nil;
}

+ (id)ss_createObjectWithRawValue:(id)value dataClass:(Class)cls
{
    if (!cls) {
        return value;
    }
    
    if (cls == [NSString class]) {
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        } else if ([value respondsToSelector:@selector(stringValue)]) {
            return [value stringValue];
        }
        return nil;
    } else if (cls == [NSNumber class]) {
        if ([value isKindOfClass:[NSNumber class]]) {
            return value;
        } else if ([value respondsToSelector:@selector(longLongValue)]) {
            return @([value longLongValue]);
        }
        return nil;
    }
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        return [cls mj_objectWithKeyValues:value];
    }
    if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id one in value) {
            id object = [[self class] ss_createObjectWithRawValue:one dataClass:cls];
            if (object) {
                [array addObject:object];
            }
        }
        return [array copy];
    }
    return value;
}

@end
