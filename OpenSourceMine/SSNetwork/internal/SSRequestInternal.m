//
//  SSRequestInternal.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSRequestInternal.h"
#import "SSBaseRequest+SSNetworking.h"
#import "SSRequestResponseHelper.h"
#import "SSRequestQueue.h"
#import "SSNetworkConfiguration.h"
#import "AuthUnicodeRequest.h"
#import "AuthAccessTokenRequest.h"

@interface SSRequestInternal ()
{
    NSMutableArray *_requestsBeDepended;
}

@property (nonatomic, assign) SSRequestState state;

@property (nonatomic, strong) NSMutableArray *dependencyResponses;

@end

@implementation SSRequestInternal

- (instancetype)init
{
    self = [super init];
    _requestsBeDepended = [NSMutableArray array];
    _UUIDString = [[NSUUID UUID] UUIDString];
    self.dependencyResponses = [NSMutableArray array];
    return self;
}

- (instancetype)initWithRequest:(SSBaseRequest *)request
{
    self = [self init];
    
    _state = SSRequestStateInit;
    _request = request;
    
    __weak typeof (self) weakSelf = self;
    _progressWrapper = ^(SSBaseRequest *request, NSProgress *progress) {
        if (request.progress) {
            request.progress(request, progress);
        }
    };
    _completionWrapper = ^(SSBaseRequest *request, SSRequestResponse *response) {
        // 添加依赖项的response
        [response addDependentResponsesFromArray:weakSelf.dependencyResponses];
        if ([weakSelf.request respondsToSelector:@selector(canonicalResponseForResponse:)]) {
            response = [weakSelf.request canonicalResponseForResponse:response];
        }
        BOOL shouldRemove = YES;
        if (response.error) {
            // 底层处理udb错误 udb数据更新后会再次发起请求
            if ([weakSelf handleErrorWithResponse:response]) {
                shouldRemove = NO;
            }
            else {
                if (request.retryCount > 0) {
                    shouldRemove = NO;
                }
                [weakSelf failureCallbackWithResponse:response];
            }
        }
        else {
            [weakSelf successCallbackWithResponse:response];
        }
        if (shouldRemove) {
            [[SSRequestQueue sharedQueue] removeRequest:request];
            [weakSelf cleanup];
        }
    };
    
    return self;
}

- (void)start
{
    self.state = SSRequestStatePrepared;
    [self executeIfNoDependency];
}

- (void)cancel
{
    // 强引用
    SSBaseRequest *currentRequest = self.request;
    if (!currentRequest) {
        return;
    }
    
    [[SSRequestQueue sharedQueue] removeRequest:self.request];
    
    self.state = SSRequestStateCancelled;
    
    // 伪造一个response
    const SSRequestErrorCode errorCode = SSRequestErrorCodeOperationCancelled;
    SSRequestResponse *response = [[SSRequestResponse alloc] initWithErrorCode:errorCode];
    [response addDependentResponsesFromArray:self.dependencyResponses];
    
    // 处理 依赖项
    for (SSBaseRequest *dependency in [currentRequest.dependencies copy]) {
        [currentRequest removeDependency:dependency];
    }
    
    // 移除 被依赖项
    NSArray *requestsBeDepended = [_requestsBeDepended copy];
    for (SSBaseRequest *requestBeDepended in requestsBeDepended) {
        [requestBeDepended removeDependency:currentRequest];
        [self removeRequestBeDepended:requestBeDepended];
    }
    
    // 被依赖的request失败回调
    for (SSBaseRequest *requestBeDepended in requestsBeDepended) {
        SSRequestErrorCode code = SSRequestErrorCodeDependencyCancelled;
        SSRequestResponse *obj = [[SSRequestResponse alloc] initWithErrorCode:code];
        SSRequestResponseWrapper *wrapper = nil;
        wrapper = [[SSRequestResponseWrapper alloc] initWithRequest:self.request
                                                           response:response];
        if (wrapper) {
            [obj addDependentResponsesFromArray:@[wrapper]];
        }
        requestBeDepended.internal.state = SSRequestStateCancelled;
        requestBeDepended.internal.completionWrapper(requestBeDepended, obj);
    }
    
    [self cleanup];
}

- (void)cleanup
{
    SSBaseRequest *request = self.request;
    
    request.willStart = nil;
    request.progress = nil;
    request.didFinish = nil;
    
    _progressWrapper = nil;
    _completionWrapper = nil;
}

- (void)executeIfNoDependency
{
    SSBaseRequest *request = self.request;
    if (request.dependencies.count == 0) {
        NSParameterAssert(self.state == SSRequestStatePrepared);
        if (request.willStart) {
            request.willStart(request);
        }
        self.state = SSRequestStateExecuting;
        [[SSRequestQueue sharedQueue] addRequest:self.request];
    }
}

- (void)successCallbackWithResponse:(SSRequestResponse *)response
{
    // 强引用
    SSBaseRequest *currentRequest = self.request;
    if (!currentRequest) {
        return;
    }
    
    self.state = SSRequestStateSuccessful;
    
    // 移除 依赖项
    for (SSBaseRequest *dependency in [currentRequest.dependencies copy]) {
        [currentRequest removeDependency:dependency];
    }
    
    // 移除 被依赖项
    NSArray *requestsBeDepended = [_requestsBeDepended copy];
    for (SSBaseRequest *requestBeDepended in requestsBeDepended) {
        [requestBeDepended removeDependency:currentRequest];
        SSRequestInternal *otherInternal = requestBeDepended.internal;
        SSRequestResponseWrapper *wrapper = nil;
        wrapper = [[SSRequestResponseWrapper alloc] initWithRequest:self.request
                                                           response:response];
        if (wrapper) {
            [otherInternal.dependencyResponses addObject:wrapper];
        }
        [self removeRequestBeDepended:requestBeDepended];
    }
    
    // 成功回调 当前request
    if (self.request.didFinish) {
        self.request.didFinish(currentRequest, response);
    }
    
    // 尝试开始 被依赖项
    for (SSBaseRequest *requestBeDepended in requestsBeDepended) {
        [requestBeDepended.internal executeIfNoDependency];
    }
}

- (void)failureCallbackWithResponse:(SSRequestResponse *)response
{
    // 强引用
    SSBaseRequest *currentRequest = self.request;
    if (!currentRequest) {
        return;
    }
    
    BOOL isDependencyError = [response.error.domain isEqualToString:SSRequestDependencyErrorDomain];
    
    // 重试
    if (self.request.retryCount > 0 && !isDependencyError) {
        --self.request.retryCount;
        self.state = SSRequestStatePrepared;
        void(^retryImpl)(void) = ^() {
            // 可能已经cancel
            // 可能依赖项cancel或者fail
            if (self.state == SSRequestStatePrepared) {
                [self executeIfNoDependency];
            }
        };
        
        const NSTimeInterval interval = self.request.retryInterval;
        if (interval <= 0) {
            retryImpl();
        }
        else {
            int64_t delta = (int64_t)(interval * NSEC_PER_SEC);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), ^{
                retryImpl();
            });
        }
        return;
    }
    
    self.state = SSRequestStateFailed;
    
    // 移除 依赖项
    for (SSBaseRequest *dependency in [currentRequest.dependencies copy]) {
        [currentRequest removeDependency:dependency];
    }
   
    // 移除 被依赖项
    NSArray *requestsBeDepended = [_requestsBeDepended copy];
    for (SSBaseRequest *requestBeDepended in requestsBeDepended) {
        [requestBeDepended removeDependency:currentRequest];
        [self removeRequestBeDepended:requestBeDepended];
    }
    
    // 失败回调 当前request
    if (self.request.didFinish) {
        self.request.didFinish(currentRequest, response);
    }
    
    // 失败回调 被依赖项
    for (SSBaseRequest *requestBeDepended in requestsBeDepended) {
        SSRequestErrorCode code = SSRequestErrorCodeDependencyFailed;
        if (isDependencyError) {
            code = response.error.code;
        }
        SSRequestResponse *obj = [[SSRequestResponse alloc] initWithErrorCode:code];
        SSRequestResponseWrapper *wrapper = nil;
        wrapper = [[SSRequestResponseWrapper alloc] initWithRequest:self.request
                                                           response:response];
        if (wrapper) {
            [requestBeDepended.internal.dependencyResponses addObject:wrapper];
        }
        requestBeDepended.internal.completionWrapper(requestBeDepended, obj);
    }
}

- (BOOL)handleErrorWithResponse:(SSRequestResponse *)response
{
    SSRequestResponseKind *kind = response.kindObject;
    SSNetworkConfiguration *configuration = [SSNetworkConfiguration sharedInstance];
    BOOL result = NO;
    if (kind.moduleType == 10000) {
        switch (kind.errCode) {
            case 3:
            case 4:
            case 7: {
                [configuration clearSession];
                
                AuthUnicodeRequest *unicodeRequest = [[AuthUnicodeRequest alloc] init];
                self.state = SSRequestStatePrepared;
                [self.request addDependency:unicodeRequest];
                [unicodeRequest start];
                result = YES;
                break;
            }
            case 8:
            case 9:
            case 10:
            case 21:
            case 24:
            case 25:
            case 28:
            case 33:
            case 34: {
                [configuration clearSession];
                
                if ([configuration respondsToSelector:@selector(shouldLoginWithCallback:)]) {
                    [configuration shouldLoginWithCallback:^(BOOL success) {
                        
                    }];
                }
                break;
            }
            case 17: {
                AuthAccessTokenRequest *tokenRequest = [[AuthAccessTokenRequest alloc] init];
                tokenRequest.grant_type = @"refresh_token";
                tokenRequest.username = [configuration currentAccount];
                tokenRequest.refresh_token = [configuration sessionRefreshToken];
                self.state = SSRequestStatePrepared;
                [self.request addDependency:tokenRequest];
                [tokenRequest start];
                result = YES;
                break;
            }
            case 35:
            case 36: {
                if ([configuration respondsToSelector:@selector(showVCode:url:callback:)]) {
                    NSNumber *busiNo = kind.errCode == 36 ? @(1) : @(2);
                    NSString *interceptUrl = nil;
                    if ([response.data isKindOfClass:NSDictionary.class]) {
                        interceptUrl = response.data[@"interceptUrl"];
                    }
                    [configuration showVCode:busiNo url:interceptUrl callback:^(BOOL success) {
                        
                    }];
                }
                break;
            }
            default: {
                break;
            }
        }
    }
    return result;
}

- (SSRequestState)state
{
    return _state;
}

- (void)addRequestBeDepended:(SSBaseRequest *)request
{
    if (![request isKindOfClass:SSBaseRequest.class]) {
        return;
    }
    
    if (![_requestsBeDepended containsObject:request]) {
        [_requestsBeDepended addObject:request];
    }
}

- (void)removeRequestBeDepended:(SSBaseRequest *)request
{
    if (![request isKindOfClass:SSBaseRequest.class]) {
        return;
    }
    
    [_requestsBeDepended removeObject:request];
}

@end
