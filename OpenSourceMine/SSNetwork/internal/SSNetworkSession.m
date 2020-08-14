//
//  SSNetworkSession.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/13.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSNetworkSession.h"
#import "SAMKeychainQuery.h"

NSString * const SSUserDidLoginNotification = @"SSUserDidLoginNotification";
NSString * const SSUserDidLogoutNotification = @"SSUserDidLogoutNotification";

@interface SSNetworkSession ()

@property (nonatomic, strong, readonly) NSMutableArray *notifications;

@end

@implementation SSNetworkSession

- (instancetype)init
{
    self = [super init];
    
    _notifications = [NSMutableArray array];
    
    _unicode = [self.class objectForKey:NSStringFromSelector(@selector(unicode))];
    _timelag = [self.class objectForKey:NSStringFromSelector(@selector(timelag))];
    _accessToken = [self.class objectForKey:NSStringFromSelector(@selector(accessToken))];
    _refreshToken = [self.class objectForKey:NSStringFromSelector(@selector(refreshToken))];
    
    return self;
}

- (void)setUnicode:(NSString *)unicode
{
    unicode = [unicode isKindOfClass:NSString.class] ? unicode : nil;
    _unicode = [unicode copy];
    [self.class setObject:unicode forKey:NSStringFromSelector(@selector(unicode))];
}

- (void)setTimelag:(NSNumber *)timelag
{
    timelag = [timelag isKindOfClass:NSNumber.class] ? timelag : nil;
    _timelag = [timelag copy];
    [self.class setObject:timelag forKey:NSStringFromSelector(@selector(timelag))];
}

- (void)setAccessToken:(NSString *)accessToken
{
    NSString *oldValue = self.accessToken;
    accessToken = [accessToken isKindOfClass:NSString.class] ? accessToken : nil;
    
    _accessToken = [accessToken copy];
    [self.class setObject:accessToken forKey:NSStringFromSelector(@selector(accessToken))];
    
    if (accessToken || oldValue) {
        if (![accessToken isEqualToString:oldValue]) {
            NSString *name = nil;
            if (accessToken) {
                name = SSUserDidLoginNotification;
            } else {
                name = SSUserDidLogoutNotification;
            }
            // 先移除再添加 这样顺序就对了
            [self.notifications removeObject:name];
            [self.notifications addObject:name];
            
            // 当前runloop可能多次设置accessToken 或者可能还有其他设置 因此下一个runloop通知上层
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                for (NSString *name in self.notifications) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
                }
                [self.notifications removeAllObjects];
            }];
        }
    }
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    refreshToken = [refreshToken isKindOfClass:NSString.class] ? refreshToken : nil;
    _refreshToken = [refreshToken copy];
    [self.class setObject:refreshToken forKey:NSStringFromSelector(@selector(refreshToken))];
}

+ (void)setObject:(id)object forKey:(NSString *)key
{
    NSError *error = nil;
    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    query.service = [self service];
    query.account = key;
    if (object) {
        query.passwordObject = object;
        [query save:&error];
    } else {
        [query deleteItem:&error];
    }
}

+ (id)objectForKey:(NSString *)key
{
    NSError *error = nil;
    SAMKeychainQuery *query = [[SAMKeychainQuery alloc] init];
    query.service = [self service];
    query.account = key;
    [query fetch:&error];
    id object = query.passwordObject;
    return object;
}

+ (NSString *)service
{
    NSString *result = [[NSBundle mainBundle] bundleIdentifier];
    if (result.length == 0) {
        result = @"com.cn.ssnetwork";
    }
    return [result stringByAppendingString:@".session"];
}

@end
