//
//  EHDServiceBus.h
//  EHDComponent
//
//  Created by luohs on 2017/10/26.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHDServiceRoutePlugin.h"

@interface EHDServiceBus : NSObject
//connector自load过程中，注册自己
+(void)registerService:(nonnull id<EHDServiceRoutePlugin>)service;

#pragma mark - 服务调用接口
//根据protocol获取服务实例
+(nullable id)serviceForProtocol:(nonnull Protocol *)protocol;
@end
