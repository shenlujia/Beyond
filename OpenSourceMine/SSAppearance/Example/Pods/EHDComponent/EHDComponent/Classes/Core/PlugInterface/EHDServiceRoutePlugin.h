//
//  EHDServiceBusRoutePlugin.h
//  EHDComponent
//
//  Created by luohs on 2017/10/26.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EHDServiceRoutePlugin <NSObject>
/**
 * 业务模块挂接中间件，注册自己提供的service，实现服务接口的调用；
 *
 * 通过protocol协议找到组件中对应的服务实现，生成一个服务单例；
 * 传递给调用者进行protocol接口中属性和方法的调用；
 */
- (nullable id)serviceWithProtocol:(nonnull Protocol *)protocol;
@end
