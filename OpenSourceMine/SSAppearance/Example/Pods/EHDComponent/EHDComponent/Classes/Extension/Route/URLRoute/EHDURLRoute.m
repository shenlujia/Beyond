//
//  EHDURLRoute.m
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDURLRoute.h"
#import "EHDURLParse.h"

NSString *const EHDRouterCompletion = @"EHDRouterCompletion";
NSString *const EHDRouterExtraData = @"EHDRouterExtraData";
typedef _Nullable id (^EHDRouterHandler)(NSDictionary *parameters);

@implementation EHDURLRoute
#pragma mark - Register & Deregister
+ (void)registerURL:(NSString *)URL handler:(_Nullable id (^)(NSDictionary *parameters))handler
{
    [EHDURLParse addURLPattern:URL handler:handler];
}

+ (void)deregisterURL:(NSString *)URL
{
    [EHDURLParse removeURLPattern:URL];
}

#pragma mark - Open URL
+ (id)openURL:(NSString *)URL completion:(void (^)(id))completion
{
    return [self openURL:URL extraData:nil completion:completion];
}

+ (id)openURL:(NSString *)URL extraData:(id)extraData completion:(void (^)(id))completion
{
    NSMutableDictionary *parameters = [EHDURLParse extractParametersFromURL:URL];
    if (parameters) {
        EHDRouterHandler handler = parameters[@"block"];
        if (completion) {
            parameters[EHDRouterCompletion] = completion;
        }
        if (extraData) {
            parameters[EHDRouterExtraData] = extraData;
        }
        if (handler) {
            [parameters removeObjectForKey:@"block"];
            return handler(parameters);
        }
    }
    return nil;
}
@end
