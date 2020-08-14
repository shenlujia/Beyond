//
//  AuthAccessTokenRequest.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/14.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "AuthAccessTokenRequest.h"
#import "SSNetworking.h"

@interface AuthAccessTokenObject : NSObject

@property (nonatomic, copy, readonly) NSString *access_token; // 令牌
@property (nonatomic, copy, readonly) NSString *token_type; // 令牌类型
@property (nonatomic, copy, readonly) NSString *refresh_token; // 刷新令牌
@property (nonatomic, copy, readonly) NSNumber *expires_in; // 过期
@property (nonatomic, copy, readonly) NSString *scope; // 权限域

@end

@implementation AuthAccessTokenObject

@end

@interface AuthAccessTokenRequest ()

@property (nonatomic, copy) NSString *unicode;   //唯一标识，32位，由服务器统一颁发给客户端 必须
@property (nonatomic, copy) NSString *client_id;     // 客户端id
@property (nonatomic, copy) NSString *client_secret; // 客户端密码

@end

@implementation AuthAccessTokenRequest

- (instancetype)init
{
    self = [super init];
    
    self.dataObjectClass = AuthAccessTokenObject.class;
    
    SSNetworkConfiguration *configuration = [SSNetworkConfiguration sharedInstance];
    self.unicode = [configuration sessionUnicode];
    self.client_id = [configuration clientId];
    self.client_secret = [configuration clientSecret];
    
    self.grant_type = @"password";
    
    __weak typeof (self) weakSelf = self;
    self.willStart = ^(SSBaseRequest *request) {
        weakSelf.unicode = [configuration sessionUnicode];
    };
    
    return self;
}

- (NSString *)URLString
{
    if ([self.grant_type isEqualToString:@"password"]) {
        if (self.login_type.integerValue == 8) {
            return [NSString stringWithFormat:@"%@/oauth/token?client_id=%@&client_secret=%@&grant_type=%@&username=%@&autoLogin_token=%@&login_type=%@&unicode=%@",
                    NET_PATH_UDB_AUTH,
                    [self nonnullTextWithObject:self.client_id],
                    [self nonnullTextWithObject:self.client_secret],
                    [self nonnullTextWithObject:self.grant_type],
                    [self nonnullTextWithObject:self.username],
                    [self nonnullTextWithObject:self.autoLogin_token],
                    [self nonnullTextWithObject:self.login_type.stringValue],
                    [self nonnullTextWithObject:self.unicode]];
        }
        else if (self.verifyCode.length > 0) {
            return [NSString stringWithFormat:@"%@/oauth/token?client_id=%@&client_secret=%@&grant_type=%@&username=%@&verifyCode=%@&login_type=%@&unicode=%@",
                    NET_PATH_UDB_AUTH,
                    [self nonnullTextWithObject:self.client_id],
                    [self nonnullTextWithObject:self.client_secret],
                    [self nonnullTextWithObject:self.grant_type],
                    [self nonnullTextWithObject:self.username],
                    [self nonnullTextWithObject:self.verifyCode],
                    [self nonnullTextWithObject:self.login_type],
                    [self nonnullTextWithObject:self.unicode]];
        }
        return [NSString stringWithFormat:@"%@/oauth/token?client_id=%@&client_secret=%@&grant_type=%@&username=%@&password=%@&unicode=%@",
                NET_PATH_UDB_AUTH,
                [self nonnullTextWithObject:self.client_id],
                [self nonnullTextWithObject:self.client_secret],
                [self nonnullTextWithObject:self.grant_type],
                [self nonnullTextWithObject:self.username],
                [self nonnullTextWithObject:self.password],
                [self nonnullTextWithObject:self.unicode]];
    }
    else if ([self.grant_type isEqualToString:@"refresh_token"]){
        return [NSString stringWithFormat:@"%@/oauth/token?client_id=%@&client_secret=%@&grant_type=%@&refresh_token=%@&unicode=%@",
                NET_PATH_UDB_AUTH,
                [self nonnullTextWithObject:self.client_id],
                [self nonnullTextWithObject:self.client_secret],
                [self nonnullTextWithObject:self.grant_type],
                [self nonnullTextWithObject:self.refresh_token],
                [self nonnullTextWithObject:self.unicode]];
    }
    
    return [NSString stringWithFormat:@"%@/oauth/token", NET_PATH_UDB_AUTH];
}

- (SSRequestResponse *)canonicalResponseForResponse:(SSRequestResponse *)response
{
    if (!response.error) {
        AuthAccessTokenObject *obj = response.data;
        obj = [obj isKindOfClass:AuthAccessTokenObject.class] ? obj : nil;
        BOOL successful = (obj.access_token && obj.refresh_token);
        if (!successful) {
            response = [[SSRequestResponse alloc] initWithErrorCode:SSRequestErrorCodeDataInvalid];
        }
    }
    return response;
}

- (void)startWithBlock:(SSRequestDidFinish)block
{
    __weak typeof (self) weakSelf = self;
    NSString *account = self.username;
    SSRequestDidFinish impl = ^(SSBaseRequest *request, SSRequestResponse *response) {
        if (weakSelf && weakSelf == request) {
            SSNetworkConfiguration *configuration = [SSNetworkConfiguration sharedInstance];
            if (!response.error) {
                AuthAccessTokenObject *obj = response.data;
                [configuration updateSessionWithAccessToken:obj.access_token
                                               refreshToken:obj.refresh_token];
                [configuration setCurrentAccount:account];
            }
            
            if (block) {
                block(request, response);
            }
        }
    };
    
    [super startWithBlock:impl];
}

- (NSString *)nonnullTextWithObject:(id)object
{
    if ([object respondsToSelector:@selector(stringValue)]) {
        object = [object stringValue];
    }
    return [object isKindOfClass:NSString.class] ? object : @"";
}

@end
