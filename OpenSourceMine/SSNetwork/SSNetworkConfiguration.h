//
//  SSNetworkConfiguration.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////

#define NET_PATH_UDB_AUTH [[SSNetworkConfiguration sharedInstance] udbAuthServerURLString]
#define NET_PATH_UDB_RESOURCE [[SSNetworkConfiguration sharedInstance] udbResourceServerURLString]
#define NET_PATH_PAY [[SSNetworkConfiguration sharedInstance] payServerURLString]
#define NET_PATH_FEE [[SSNetworkConfiguration sharedInstance] feeServerURLString]
#define NET_PATH_MED [[SSNetworkConfiguration sharedInstance] medServerURLString]
#define NET_PATH_PROD [[SSNetworkConfiguration sharedInstance] prodServerURLString]
#define NET_PATH_PRP [[SSNetworkConfiguration sharedInstance] prpServerURLString]
#define NET_PATH_CONSULT [[SSNetworkConfiguration sharedInstance] consultServerURLString]
#define NET_PATH_TRACK [[SSNetworkConfiguration sharedInstance] trackServerURLString]

#define NET_RESOURCE [[SSNetworkConfiguration sharedInstance] resourceId]
#define NET_PATH_MED_R [NET_PATH_MED stringByAppendingFormat:@"/r/%@", NET_RESOURCE]
#define NET_PATH_CONSULT_R [NET_PATH_CONSULT stringByAppendingFormat:@"/r/%@", NET_RESOURCE]

////////////////////////////////////////////////////////////

#define sharedNetworkConfiguration [SSNetworkConfiguration sharedInstance]

@protocol SSNetworkConfiguration <NSObject>

@optional

- (NSString *)udbAuthServerURLString; // udb服务器地址
- (NSString *)udbResourceServerURLString; // udb服务器地址
- (NSString *)payServerURLString; // 支付中心
- (NSString *)feeServerURLString; // 费用
- (NSString *)medServerURLString; // 通用服务器地址
- (NSString *)prodServerURLString; // 华亘新接口地址
- (NSString *)consultServerURLString; // 咨询服务器地址
- (NSString *)prpServerURLString; // 转诊服务器地址
- (NSString *)trackServerURLString; // 埋点服务器地址

- (NSString *)prdCode; // 产品类型编码
- (NSString *)clientId; // UDB配置字段clientId
- (NSString *)clientSecret; // UDB配置字段clientSecret

- (void)shouldLoginWithCallback:(void (^)(BOOL success))callback;
- (void)showVCode:(NSNumber *)busiNo url:(NSString *)url callback:(void (^)(BOOL success))callback;

@end

@interface SSNetworkConfiguration : NSObject <SSNetworkConfiguration>

@property (nonatomic, copy) NSString *deviceToken;

@property (class, strong, readonly) SSNetworkConfiguration *sharedInstance;

- (void)setConfiguration:(id<SSNetworkConfiguration>)configuration;

- (NSNumber *)terminalType; // 终端类型
- (NSString *)resourceId;
- (NSDictionary *)universalHTTPHeaderFields; // 通用HTTP头

// 用户信息
- (BOOL)isLogined; // 是否登录
- (NSString *)currentAccount; // 最近的登录过的账号 可能是登出状态
- (void)setCurrentAccount:(NSString *)account;
- (NSNumber *)currentUserId;
- (void)setCurrentUserId:(NSNumber *)userId;

// Session
- (void)clearSession;
- (NSString *)sessionUnicode;
- (NSNumber *)sessionTimelag;
- (NSString *)sessionAccessToken;
- (NSString *)sessionRefreshToken;
- (void)updateSessionWithUnicode:(NSString *)unicode timelag:(NSNumber *)timelag;
- (void)updateSessionWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken;

@end
