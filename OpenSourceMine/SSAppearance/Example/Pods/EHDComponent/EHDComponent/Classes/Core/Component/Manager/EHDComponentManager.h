//
//  EHDComponentManager.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import <UIKit/UIKit.h>

// 给某个组件发事件数据
#define EHD_SendEventForComponent_(eventName, sendData, componentName) \
[EHDComponentManager sendEventName:eventName intentData:sendData forComponent:componentName];

@protocol EHDComponentRoutable;
//NS_ASSUME_NONNULL_BEGIN
@interface EHDComponentManager : NSObject
/**
 * 添加组件，并自定义组件名
 */
+ (void)addComponent:(id<EHDComponentRoutable>)component forName:(NSString *)componentName;
/**
 *  发送组件事件消息
 *
 *  @param eventName      事件名
 *  @param intentData     消息意图数据
 *  @param componentName  组件名
 */
+ (void)sendEventName:(NSString *)eventName intentData:(id)intentData forComponent:(NSString *)componentName;
/**
 *  发送多个组件事件消息
 *
 *  @param eventName      事件名
 *  @param intentData     消息意图数据
 *  @param componentNames 组件名数组
 */
+ (void)sendEventName:(NSString *)eventName intentData:(id)intentData forComponents:(NSArray<NSString *> *)componentNames;
@end
//NS_ASSUME_NONNULL_END
