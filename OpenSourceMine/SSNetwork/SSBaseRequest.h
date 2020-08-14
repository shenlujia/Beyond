//
//  SSBaseRequest.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSNetworkGlobalDefs.h"

@protocol SSBaseRequestProtocol <NSObject>

@optional

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 字典中的key是属性名，value是从字典中取值用的key
 */
+ (NSDictionary *)replacedKeyFromParameterName;

/**
 *  返回自定义的response
 */
- (SSRequestResponse *)canonicalResponseForResponse:(SSRequestResponse *)response;

@end

@interface SSBaseRequest : NSObject <SSBaseRequestProtocol>
{
@private
    id _internal;
}

@property (nonatomic, copy) NSString *identifier; // 标识符 默认`nil`
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, assign) Class dataObjectClass; // 自动将data解析成对应的类

@property (nonatomic, copy) NSDictionary *HTTPHeaderFields; // 自定义HTTP头 默认`nil`
@property (nonatomic, copy) id HTTPBody; // 自定义HTTPBody(NSArray or NSDictionary) 默认`nil`

@property (nonatomic, assign) NSInteger retryCount; // 重试次数 默认`0` 每次重试后自动减一
@property (nonatomic, assign) NSTimeInterval retryInterval; // 重试间隔 默认`0`

@property (nonatomic, assign) BOOL logEnabled; // 打印log 默认`YES` RELEASE模式自动关闭

// 重试或者token过期后刷新token成功 会再次调用willStart
// willStart可能不会执行(依赖项cancel或者error等)
// willStart已执行 didFinish可能不会执行(手动cancel)
// unicode和token等会变动的参数应该在willStart时设置
@property (nonatomic, copy) SSRequestWillStart willStart;
@property (nonatomic, copy) SSRequestProgress progress;
@property (nonatomic, copy) SSRequestDidFinish didFinish;

@property (nonatomic, assign) SSRequestCacheOptions cacheOptions; // 缓存配置

- (NSDictionary *)parameterKeyValues;
- (SSRequestState)state;

// 开始request 开始后如果有依赖项 会一直等待直至依赖项执行结束
- (void)start;
- (void)startWithBlock:(SSRequestDidFinish)block;

// 不回调didFinish 取消后无法再恢复
- (void)cancel;

// dependency被cancel时，当前request也会被cancel
// dependency调用失败时，当前request直接失败
// dependency调用成功时，移除request对此dependency的依赖，检测是否还有依赖。无依赖就开始执行，否则继续等待
- (void)addDependency:(SSBaseRequest *)request;
- (void)removeDependency:(SSBaseRequest *)request;
@property (copy, readonly) NSArray<SSBaseRequest *> *dependencies;

// 缓存
- (SSRequestResponse *)cache;
- (void)clearCache;

@end
