//
//  EHDServiceBus.m
//  EHDComponent
//
//  Created by luohs on 2017/10/26.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDServiceBus.h"

static NSMutableDictionary<NSString *, id<EHDServiceRoutePlugin>> *g_router = nil;

@implementation EHDServiceBus
+(void)registerService:(nonnull id<EHDServiceRoutePlugin>)service
{
    if (![service conformsToProtocol:@protocol(EHDServiceRoutePlugin)]) {
        return;
    }
    
    @synchronized(g_router) {
        if (g_router == nil){
            g_router = [[NSMutableDictionary alloc] initWithCapacity:5];
        }
        
        NSString *className = NSStringFromClass([service class]);
        if ([g_router objectForKey:className] == nil) {
            [g_router setObject:service forKey:className];
        }
    }
}

#pragma mark - 服务调用接口
+(nullable id)serviceForProtocol:(nonnull Protocol *)protocol
{
    if(!g_router || g_router.count <= 0) return nil;
    
    __block id serviceImp = nil;
    [g_router enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull key, id<EHDServiceRoutePlugin>  _Nonnull route, BOOL * _Nonnull stop) {
        if([route respondsToSelector:@selector(serviceWithProtocol:)]){
            serviceImp = [route serviceWithProtocol:protocol];
            if(serviceImp){
                *stop = YES;
            }
        }
    }];
    
    return serviceImp;
}
@end
