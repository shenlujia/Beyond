//
//  SSNetworkConfiguration.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSNetworkConfiguration.h"
#import "SSConverter.h"
#import "SSNetworkSession.h"
#import "SSNetworkAccount.h"

@interface SSNetworkConfiguration ()

@property (nonatomic, strong) SSNetworkSession *session;
@property (nonatomic, strong) SSNetworkAccount *account;

@end

@implementation SSNetworkConfiguration
{
    id<SSNetworkConfiguration> _configuration;
}

#pragma mark - lifecycle

- (void)dealloc
{
    
}

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _configuration;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL result = [super respondsToSelector:aSelector];
    if (!result) {
        result = [_configuration respondsToSelector:aSelector];
    }
    return result;
}

- (void)setConfiguration:(id<SSNetworkConfiguration>)configuration
{
    _configuration = configuration;
}

- (NSNumber *)terminalType
{
    return @(2);
}

- (NSString *)resourceId
{
    NSArray *components = [[self clientId] componentsSeparatedByString:@"@"];
    return components.firstObject;
}

- (NSDictionary *)universalHTTPHeaderFields
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[@"Accept"] = @"application/json";
    dictionary[@"terminalType"] = self.terminalType;
    dictionary[@"prdCode"] = self.prdCode;
    dictionary[@"client_id"] = self.clientId;
    dictionary[@"access_Token"] = [self sessionAccessToken];
    dictionary[@"unicode"] = [self sessionUnicode];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    dictionary[@"version"] = infoDictionary[@"CFBundleShortVersionString"];
    
    NSNumber *timelag = [self sessionTimelag];
    if (timelag) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        interval += timelag.doubleValue / 1000;
        long long timestamp = interval * 1000;
        dictionary[@"signature"] = SS_RSA_Public_Encrypt([@(timestamp) stringValue]);
    }
    
    return dictionary;
}

#pragma mark - 用户信息

- (SSNetworkAccount *)account
{
    if (!_account) {
        _account = [SSNetworkAccount unarchivedObject];
    }
    return _account;
}

- (BOOL)isLogined
{
    NSString *token = [self sessionAccessToken];
    return token.length > 0;
}

- (NSString *)currentAccount
{
    return self.account.account;
}

- (void)setCurrentAccount:(NSString *)account
{
    self.account.account = account;
    [self.account archive];
}

- (NSNumber *)currentUserId
{
    return self.account.usId;
}

- (void)setCurrentUserId:(NSNumber *)userId
{
    self.account.usId = userId;
    [self.account archive];
}

#pragma mark - Session

- (SSNetworkSession *)session
{
    if (!_session) {
        _session = [[SSNetworkSession alloc] init];
    }
    return _session;
}

- (void)clearSession
{
    [self setCurrentUserId:nil];
    [self updateSessionWithUnicode:nil timelag:nil];
    [self updateSessionWithAccessToken:nil refreshToken:nil];
}

- (NSString *)sessionUnicode
{
    return self.session.unicode;
}

- (NSNumber *)sessionTimelag
{
    return self.session.timelag;
}

- (NSString *)sessionAccessToken
{
    return self.session.accessToken;
}

- (NSString *)sessionRefreshToken
{
    return self.session.refreshToken;
}

- (void)updateSessionWithUnicode:(NSString *)unicode timelag:(NSNumber *)timelag
{
    self.session.unicode = unicode;
    self.session.timelag = timelag;
}

- (void)updateSessionWithAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken
{
    self.session.accessToken = accessToken;
    self.session.refreshToken = refreshToken;
}

@end
