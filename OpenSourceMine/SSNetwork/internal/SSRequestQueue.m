//
//  SSRequestQueue.m
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/11.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import "SSRequestQueue.h"
#import "AFHTTPSessionManager.h"
#import "SSBaseRequest+SSNetworking.h"
#import "SSRequestInternal.h"
#import "SSRequestResponse.h"
#import "SSRequestResponseCache.h"
#import "SSNetworkConfiguration.h"
#import "SSRequestTask.h"
#import "SSConverter.h"

#define USE_ONE_MANAGER 1

#define SS_P12_NAME                 @"client.p12"
#define SS_P12_EN_NAME              @"client.en"
#define SS_P12_KEY                  @"com.cn.hsyuntai.client.p12"

static NSString * const SSRequestHostKey = @"host";
static NSString * const HsNetworkHostSeperator = @":";

@interface SSHTTPSessionManager : AFHTTPSessionManager

@end

@implementation SSHTTPSessionManager

- (void)dealloc
{
    
}

@end

@interface SSRequestQueue ()

@property (nonatomic, copy, readonly) NSMutableDictionary *tasks;

@end

@implementation SSRequestQueue

#pragma mark - lifecycle

+ (void)load
{

}

- (instancetype)init
{
    self = [super init];
    _tasks = [NSMutableDictionary dictionary];
    return self;
}

#pragma mark - private

+ (instancetype)sharedQueue
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)addRequest:(SSBaseRequest *)request
{
    if (![request isKindOfClass:SSBaseRequest.class]) {
        return;
    }
    
    if (request.cacheOptions & SSRequestCacheMemory) {
        SSRequestResponse *response = [request cache];
        if (response) {
            // 存在缓存 考虑兼容性 异步通知上层
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (request.internal.completionWrapper) {
                    request.internal.completionWrapper(request, response);
                }
            }];
            return;
        }
    }
    
    SSHTTPSessionManager *manager = ({
#if USE_ONE_MANAGER
        static SSHTTPSessionManager *instance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURL *baseURL = [NSURL URLWithString:@"https://www.hsyuntai.com"];
            instance = [[SSHTTPSessionManager alloc] initWithBaseURL:baseURL];
        });
        instance;
#else
        [SSHTTPSessionManager manager];
#endif
    });
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    __weak SSRequestInternal *internal = request.internal;
    
    //设置双向认证
    [self setSecurityPolicyWithRequest:request manager:manager];
    
    SSNetworkConfiguration *configuration = [SSNetworkConfiguration sharedInstance];
    NSMutableDictionary *headerFields = [NSMutableDictionary dictionary];
    [headerFields addEntriesFromDictionary:[configuration universalHTTPHeaderFields]];
    [headerFields addEntriesFromDictionary:internal.request.HTTPHeaderFields];
    
    NSString *URLString = internal.request.URLString;
    NSParameterAssert(URLString.length > 0);
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSString *host = URL.host;
    NSNumber *port = URL.port;
    if (host && port) {
        host = [NSString stringWithFormat:@"%@%@%@", host, HsNetworkHostSeperator, port];
    }
    headerFields[SSRequestHostKey] = host;
    
    [headerFields enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *value = [NSString stringWithFormat:@"%@", obj];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }];
    
    void (^progress)(NSProgress *) = ^(NSProgress *progress) {
        void(^mainQueueImpl)(void) = ^() {
            if (internal && internal.progressWrapper) {
                internal.progressWrapper(internal.request, progress);
            }
        };
        if ([NSThread isMainThread]) {
            mainQueueImpl();
        }
        else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                mainQueueImpl();
            }];
        }
    };
    
    void (^success)(NSURLSessionDataTask *, id) = ^(NSURLSessionDataTask *task, id response) {
        void(^mainQueueImpl)(void) = ^() {
            if (internal && internal.completionWrapper) {
                if (internal.request.logEnabled) {
                    SSNetworkLog(@"%@, response: %@", NSStringFromClass(internal.request.class), response);
                }
                SSRequestResponse *obj = [internal.request ss_responseWithDictionary:response];
                if (obj && !obj.error) {
                    if (internal.request.cacheOptions & SSRequestCacheMemory) {
                        NSString *key = [internal.request ss_cacheKey];
                        [[SSRequestResponseCache sharedCache] setCache:response forKey:key];
                    }
                }
                internal.completionWrapper(internal.request, obj);
            }
        };
        if ([NSThread isMainThread]) {
            mainQueueImpl();
        }
        else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                mainQueueImpl();
            }];
        }
    };
    
    void (^failure)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error) {
        SSRequestResponse *obj = [[SSRequestResponse alloc] initWithError:error];
        void(^mainQueueImpl)(void) = ^() {
            if (internal && internal.completionWrapper) {
                if (internal.request.logEnabled) {
                    SSNetworkLog(@"%@, response: %@", NSStringFromClass(internal.request.class), error.userInfo);
                }
                internal.completionWrapper(internal.request, obj);
            }
        };
        if ([NSThread isMainThread]) {
            mainQueueImpl();
        }
        else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                mainQueueImpl();
            }];
        }
    };
    
    id parameters = internal.request.HTTPBody;
    if (!parameters) {
        parameters = [internal.request parameterKeyValues];
    }
    if ([parameters isKindOfClass:[NSSet class]]) {
        NSSet *set = parameters;
        parameters = set.allObjects;
    }
    parameters = [[self class] parameterRemoveClassValue:parameters];
    
    NSURLSessionTask *task = [manager POST:URLString
                                parameters:parameters
                                  progress:progress
                                   success:success
                                   failure:failure];
    
#if USE_ONE_MANAGER
    SSRequestTask *taskInfo = [[SSRequestTask alloc] initWithRequest:request
                                                                task:task
                                                             manager:nil];
#else
    SSRequestTask *taskInfo = [[SSRequestTask alloc] initWithRequest:request
                                                                task:task
                                                             manager:manager];
#endif
    
    self.tasks[internal.UUIDString] = taskInfo;
    
    if (internal.request.logEnabled) {
        NSURLRequest *URLRequest = task.originalRequest;
        NSMutableString *text = [NSMutableString string];
        [text appendFormat:@"\n\nHTTP Class:\n\t%@", NSStringFromClass(internal.request.class)];
        [text appendFormat:@"\n\nHTTP URL:\n\t%@", URLRequest.URL];
        [text appendFormat:@"\n\nHTTP Method:\n\t%@", URLRequest.HTTPMethod];
        [text appendFormat:@"\n\nHTTP Header:\n\t%@", URLRequest.allHTTPHeaderFields];
        [text appendFormat:@"\n\nHTTP Body:\n\t%@\n\t", NSData_to_NSString(URLRequest.HTTPBody)];
        SSNetworkLog(@"%@", text);
    }
}

- (void)removeRequest:(SSBaseRequest *)request
{
    if (![request isKindOfClass:SSBaseRequest.class]) {
        return;
    }
    NSString *UUIDString = request.internal.UUIDString;
    if (UUIDString.length == 0) {
        return;
    }
    [_tasks removeObjectForKey:UUIDString];
}

- (void)setSecurityPolicyWithRequest:(SSBaseRequest *)request manager:(AFHTTPSessionManager *)manager
{
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    id block = nil;
    if ([[request URLString] hasPrefix:@"https"]) {
        securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
        [securityPolicy setAllowInvalidCertificates:NO];
        [securityPolicy setValidatesDomainName:YES];
        
        __weak typeof (self) weakSelf = self;
        __weak typeof (request) weakRequest = request;
        __weak typeof (manager) weakManager = manager;
        block = ^NSURLSessionAuthChallengeDisposition(NSURLSession*session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing*_credential) {
            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            __autoreleasing NSURLCredential *credential = nil;
            SSRequestTask *requestTask = nil;
            NSString *key = weakRequest.internal.UUIDString;
            if (key) {
                requestTask = weakSelf.tasks[key];
            }
            NSURLSessionTask *dataTask = requestTask.task;
            NSString *domain = dataTask.originalRequest.allHTTPHeaderFields[SSRequestHostKey];
            if (domain.length == 0) {
                domain = dataTask.currentRequest.allHTTPHeaderFields[SSRequestHostKey];
            }
            NSArray *components = [domain componentsSeparatedByString:HsNetworkHostSeperator];
            domain = components.firstObject;
            
            if (domain.length == 0) {
                domain = challenge.protectionSpace.host;
            }
            
            NSString *authenticationMethod = challenge.protectionSpace.authenticationMethod;
            if([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
                if([weakManager.securityPolicy evaluateServerTrust:serverTrust forDomain:domain]) {
                    credential = [NSURLCredential credentialForTrust:serverTrust];
                    if(credential) {
                        disposition = NSURLSessionAuthChallengeUseCredential;
                    }
                    else {
                        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                    }
                }
                else {
                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                }
            }
            else {
                credential = [self.class credential];
                if (credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
                }
            }
            *_credential = credential;
            return disposition;
        };
    }
    
    [manager setSecurityPolicy:securityPolicy];
    [manager setSessionDidReceiveAuthenticationChallengeBlock:block];
}

+ (NSURLCredential *)credential
{
    SecIdentityRef (^identityWithData)(NSData *) = ^SecIdentityRef(NSData *data) {
        if (!data) {
            return nil;
        }
        CFDataRef dataRef = (__bridge CFDataRef)data;
        if (!dataRef) {
            return nil;
        }
        
        CFStringRef password = CFSTR("hsyuntai@zhzx19F");
        const void *keys[] = {kSecImportExportPassphrase};
        const void *values[] = { password };

        CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        if (!options) {
            return nil;
        }
        CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
        if (!items) {
            CFRelease(options);
            return nil;
        }
        
        SecIdentityRef identity = nil;
        OSStatus status = SecPKCS12Import(dataRef, options, &items);
        if (status == errSecSuccess) {
            CFDictionaryRef item = (CFDictionaryRef)CFArrayGetValueAtIndex(items, 0);
            if (item) {
                identity = (SecIdentityRef)CFDictionaryGetValue(item, kSecImportItemIdentity);
            }
        }
        
        if (identity) {
            CFRetain(identity);
        }
        CFRelease(options);
        CFRelease(items);
        
        return identity;
    };
    
    static NSURLCredential *credential = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSData *raw = NSData_File(NS_Path(SS_P12_EN_NAME));
        NSData *data = NSData_Common_Decrypt(SS_P12_KEY, raw);
        SecIdentityRef identity = identityWithData(data);
        
#ifdef DEBUG
        // DEBUG支持不加密
        if (!identity) {
            identity = identityWithData(raw);
        }
#endif
        
        if (identity) {
            SecCertificateRef certificate = nil;
            SecIdentityCopyCertificate(identity, &certificate);
            const void *certs[] = { certificate };
            CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
            credential = [NSURLCredential credentialWithIdentity:identity
                                                    certificates:(__bridge NSArray *)certArray
                                                     persistence:NSURLCredentialPersistencePermanent];
            
            CFRelease(identity);
            CFRelease(certArray);
        }
    });
    
    return credential;
}

+ (void)enP12
{
    // 加密p12，从document取出来后替换bundle中的p12
    NSData *data = NSData_Common_Encrypt(SS_P12_KEY, NSData_File(NS_Path(SS_P12_NAME)));
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *file = [paths.firstObject stringByAppendingPathComponent:SS_P12_EN_NAME];
    [data writeToFile:file atomically:YES];
}

+ (id)parameterRemoveClassValue:(id)object
{
    if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id obj in object) {
            id ret = [self parameterRemoveClassValue:obj];
            if (ret) {
                [array addObject:ret];
            }
        }
        return array;
    }
    else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for (id key in [object allKeys]) {
            id okKey = [self parameterRemoveClassValue:key];
            id okValue = [self parameterRemoveClassValue:[object objectForKey:key]];
            if (okKey && okValue) {
                dictionary[okKey] = okValue;
            }
        }
        return dictionary;
    }
    return object != [object class] ? object : nil;
}

@end
