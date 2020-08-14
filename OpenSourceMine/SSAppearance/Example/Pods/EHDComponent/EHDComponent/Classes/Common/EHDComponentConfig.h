//
//  EHDComponentConfig.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHDComponentMarco.h"
//NS_ASSUME_NONNULL_BEGIN
#define ComponentConfig [EHDComponentConfig shareInstance]
/**
 *  配置类
 */
@protocol EHDURLRoutePlug, EHDComponentHandlerPlug;
@class EHDComponentStruct;
@interface EHDComponentConfig : NSObject
HEAD_SINGLETON(EHDComponentConfig)
/**
 *  设置框架默认配置，并返回共享实例
 *
 *  @return 配置类
 */
+ (instancetype)defaultConfig;
/**
 *  设置URL路由插件
 *
 *  @param routePlugClass URL路由解析类
 *
 *  @return 配置类
 */
- (instancetype)setRoutePlug:(Class<EHDURLRoutePlug>)routePlugClass;
/**
 *  URL路由插件
 *
 */
- (Class<EHDURLRoutePlug>)routePlug;
/**
 *  添加组件处理器插件
 *
 *  @param componentHanderPlug 组件处理器插件类
 *
 *  @return 配置类
 */
- (instancetype)addComponentHanderPlug:(Class<EHDComponentHandlerPlug>)componentHanderPlug;
/**
 *  所有组件处理器插件
 *
 */
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray<Class<EHDComponentHandlerPlug>> *allComponentHanderPlugs;
/**
 *  注册URL组件
 *
 */
- (void)registerURL:(NSString *)URL handler:(id (^)(NSDictionary *parameters))handler;
/**
 *  移除URL组件
 *
 */
- (void)deregisterURL:(NSString *)URL;
/**
 *  添加组件结构体，该组件结构体来自于配置文件
 *
 *  @param componentStructs 组件结构体
 *
 */
- (void)registerComponentStructs:(NSArray<NSDictionary<NSString *,NSString*> *>*)componentStructs;
/**
 *
 *  @return 组件结构体字典
 */
- (NSDictionary<NSString *, EHDComponentStruct*> *)componentStructs;
/**
 *
 *  @return 组件结构体字典
 */
- (NSString *)bundleResourcePath;
@end
//NS_ASSUME_NONNULL_END
