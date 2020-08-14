//
//  EHDEventBus.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EHDComponentRoutable;
//NS_ASSUME_NONNULL_BEGIN
@interface EHDEventBus : NSObject
/**
 *  初始化方法
 *
 *  @param componentRoutable 可运行组件
 *
 *  @return EHDEventBus
 */
- (instancetype)initWithComponentRoutable:(__kindof id<EHDComponentRoutable>)componentRoutable NS_DESIGNATED_INITIALIZER;

/**
 *  对多个组件组件发送事件消息(OC专用，Swift编译器转换不了）
 *
 *  @param eventName        事件名
 *  @param intentData       消息数据
 *  @param ...              多个组件名
 */
- (void)sendEventName:(NSString *)eventName intentData:(id)intentData,...;


/**
 *  对多个组件组件发送事件消息
 *
 *  @param eventName      事件名
 *  @param intentData     消息数据
 *  @param componentNames 组件名数组
 */
- (void)sendEventName:(NSString *)eventName intentData:(id)intentData forComponents:(NSArray<NSString *> *)componentNames;

/**
 *  发送全局通知
 *
 *  @param notiName   通知名
 *  @param intentData 消息数据
 */
- (void)sendNotificationWithName:(NSString *)notiName intentData:(id)intentData;

/**
 *  注册通知(OC专用，Swift编译器转换不了）
 *
 *  @param target 通知侦听目标
 *  @param ...    多个通知名
 */
- (void)registerNotificationsForTarget:(id)target,...;

/**
 *  注册通知
 *
 *  @param notiNames 通知名数组
 */
- (void)registerNotifications:(NSArray<NSString *> *)notiNames;

@end
//NS_ASSUME_NONNULL_END
