//
//  AuthUnicodeRequest.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/13.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CocoaSecurity/Base64.h>
#import "SSNetworking.h"
#import "AuthUnicodeRequest.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#import <MJExtension.h>
#pragma clang diagnostic pop

@interface AuthUnicodeObject : NSObject

@property (nonatomic, copy, readonly) NSNumber *timelag;    //时间差（udb时间-终端时间），单位（毫秒）
@property (nonatomic, copy, readonly) NSString *unicode;    //终端唯一标识（32位）

@end

@implementation AuthUnicodeObject

@end

@interface AuthUnicodeRequest ()

@property (nonatomic, copy) NSNumber *terminalTime;  //客户端最新时间戳
@property (nonatomic, copy) NSString *devModel;      //设备型号（小米****）
@property (nonatomic, copy) NSNumber *terminalType;
@property (nonatomic, copy) NSString *pushToken;

@end

@implementation AuthUnicodeRequest

- (instancetype)init
{
    self = [super init];
    
    self.URLString = [NSString stringWithFormat:@"%@/r/10001/100", NET_PATH_UDB_AUTH];
    self.dataObjectClass = AuthUnicodeObject.class;
    
    SSNetworkConfiguration *configuration = [SSNetworkConfiguration sharedInstance];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    self.pushToken = configuration.deviceToken;
    long long terminalTime = interval * 1000;
    self.terminalTime = @(terminalTime);
    self.devModel = [[UIDevice currentDevice] model];
    self.terminalType = [configuration terminalType];
    
    return self;
}

- (NSDictionary *)HTTPHeaderFields
{
    NSArray *keys = @[@"pushToken",
                      @"terminalTime",
                      @"devModel",
                      @"imei",
                      @"terminalType",
                      @"mac",
                      @"ipAddress"];
    
    NSDictionary *keyValues = [self parameterKeyValues];
    NSString *JSONString = [keyValues mj_JSONString];
    JSONString = [JSONString substringWithRange:NSMakeRange(1, JSONString.length - 2)];
    NSArray *components = [JSONString componentsSeparatedByString:@","];
    
    NSMutableArray *bodyComponents = [NSMutableArray array];
    for (NSString *key in keys) {
        for (NSString *component in components) {
            NSRange range = [component rangeOfString:key];
            if (range.location == 1 && range.length == key.length) {
                [bodyComponents addObject:component];
                break;
            }
        }
    }
    
    NSString *body = @"";
    if (bodyComponents.count) {
        body = [bodyComponents componentsJoinedByString:@","];
    }
    body = [NSString stringWithFormat:@"{%@}", body];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"signature"] = SS_RSA_Private_Sign(body);
    
    return dictionary;
    
//    NSMutableArray *bodyObjects = [NSMutableArray array];
//    NSDictionary *keyValues = [self parameterKeyValues];
//    for (NSString *key in keys) {
//        id value = keyValues[key];
//        if (value) {
//            NSString *object = [NSString stringWithFormat:@"\"%@\":\"%@\"", key, value];
//            [bodyObjects addObject:object];
//        }
//    }
//    NSString *bodyString = @"";
//    if (bodyObjects.count) {
//        bodyString = [bodyObjects componentsJoinedByString:@","];
//    }
//    bodyString = [NSString stringWithFormat:@"{%@}", bodyString];
//    
//    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
//    RSAEncryptor *encryptor = [[RSAEncryptor alloc] init];
//    data = [encryptor signWithPrivateKeyUsing:NID_sha1 plainData:data];
//    
//    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
//    fields[@"signature"] = [data base64EncodedString];
//    
//    return [fields copy];
}

- (SSRequestResponse *)canonicalResponseForResponse:(SSRequestResponse *)response
{
    if (!response.error) {
        AuthUnicodeObject *obj = response.data;
        obj = [obj isKindOfClass:AuthUnicodeObject.class] ? obj : nil;
        BOOL successful = (obj.unicode && obj.timelag);
        if (!successful) {
            response = [[SSRequestResponse alloc] initWithErrorCode:SSRequestErrorCodeDataInvalid];
        }
    }
    return response;
}

- (void)startWithBlock:(SSRequestDidFinish)block
{
    __weak typeof (self) weakSelf = self;
    SSRequestDidFinish impl = ^(SSBaseRequest *request, SSRequestResponse *response) {
        if (weakSelf && weakSelf == request) {
            SSNetworkConfiguration *configuration = [SSNetworkConfiguration sharedInstance];
            if (!response.error) {
                AuthUnicodeObject *obj = response.data;
                [configuration updateSessionWithUnicode:obj.unicode timelag:obj.timelag];
                if (block) {
                    block(request, response);
                }
            }
        }
    };
    
    [super startWithBlock:impl];
}

@end
