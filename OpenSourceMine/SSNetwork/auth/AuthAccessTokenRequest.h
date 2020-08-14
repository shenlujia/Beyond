//
//  AuthAccessTokenRequest.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/14.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSBaseRequest.h"

@interface AuthAccessTokenRequest : SSBaseRequest

// authorization_code授权码模式 password密码模式 client_credentials客户端模式 refresh_token刷新 token模式
@property (nonatomic, copy) NSString *grant_type;
@property (nonatomic, copy) NSString *scope; // 权限范围，默认为空

//授权码模式 grant_type ＝ authorization_code
@property (nonatomic, copy) NSString *code; // 授权码
//这里的的redirect_uri必须与获取授权码接口中的redirect_uri一样 （简明模式中必须和申请clientdetails 中一致）
@property (nonatomic, copy) NSString *redirect_uri;

//密码模式 grant_type ＝ password
@property (nonatomic, copy) NSString *username;      // 用户名，手机号 邮箱，芸泰id等身份唯一标识
@property (nonatomic, copy) NSString *password;      // 密码

//简明模式获取token
@property (nonatomic, copy) NSString *response_type; // 响应类型，固定值 code

//刷新token模式 获取access_token grant_type = refresh_token
@property (nonatomic, copy) NSString *refresh_token; // 必须 刷新token

//验证码模式
@property (nonatomic, copy) NSString *verifyCode;    // 验证码（4位数验证码）
@property (nonatomic, copy) NSNumber *login_type;    // 此处接口固定传值：7

// 自动登录获取
@property (nonatomic, copy) NSString *autoLogin_token;

@end
