//
//  SSNetworkGlobalDefs.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#ifndef SSNetworkGlobalDefs_h
#define SSNetworkGlobalDefs_h


@class SSBaseRequest;
@class SSRequestResponse;


#ifdef DEBUG
#define SSNetworkLog(...) NSLog(__VA_ARGS__)
#else
#define SSNetworkLog(...)
#endif


FOUNDATION_EXPORT NSString * const SSRequestDataErrorDomain;
FOUNDATION_EXPORT NSString * const SSRequestOperationErrorDomain;
FOUNDATION_EXPORT NSString * const SSRequestDependencyErrorDomain;

FOUNDATION_EXPORT NSString * const SSUserDidLoginNotification;
FOUNDATION_EXPORT NSString * const SSUserDidLogoutNotification;


typedef NS_OPTIONS(NSInteger, SSRequestCacheOptions) {
    SSRequestCacheNone = 0,
    SSRequestCacheMemory = 1 << 0,
    SSRequestCacheDisk = 1 << 1,
    SSRequestCacheContinueInBackground = 1 << 2
};


typedef NS_ENUM(NSInteger, SSRequestErrorCode) {
    SSRequestErrorCodeDataInvalid = 10000,
    SSRequestErrorCodeOperationCancelled,
    SSRequestErrorCodeDependencyCancelled,
    SSRequestErrorCodeDependencyFailed
};


typedef NS_ENUM(NSInteger, SSRequestState) {
    SSRequestStateInit = 0, // 创建
    SSRequestStatePrepared, // 准备执行 调用start后 有依赖项则保持准备状态
    SSRequestStateExecuting, // 执行中
    SSRequestStateCancelled, // 取消
    SSRequestStateFailed, // 失败
    SSRequestStateSuccessful // 成功
};


typedef void (^SSRequestWillStart)(SSBaseRequest *request);
typedef void (^SSRequestProgress)(SSBaseRequest *request, NSProgress *progress);
typedef void (^SSRequestDidFinish)(SSBaseRequest *request, SSRequestResponse *response);


#endif /* SSNetworkGlobalDefs_h */
