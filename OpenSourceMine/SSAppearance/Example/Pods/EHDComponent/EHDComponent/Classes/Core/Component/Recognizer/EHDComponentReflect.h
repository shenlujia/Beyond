//
//  EHDComponentReflect.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EHDComponentRoutable, EHDComponentHandlerPlug;
//NS_ASSUME_NONNULL_BEGIN
@interface EHDComponentReflect : NSObject
/**
 *  根据组件返回组件处理器
 *
 *  @param component 组件名或组件对象
 *
 *  @return 组件处理器类
 */
+ (Class<EHDComponentHandlerPlug>)componentHandlerForComponent:(id)component;
/**
 *  根据组件名创建一个组件
 *
 *  @param component 组件名
 *
 *  @return 组件
 */
+ (id<EHDComponentRoutable>)componentFromName:(NSString *)component param:(id)param;
/**
 *  当前组件界面
 *
 *  @param component 组件
 *
 *  @return 视图
 */
+ (UIViewController *)uInterfaceForComponent:(__kindof id<EHDComponentRoutable>)component;
@end
//NS_ASSUME_NONNULL_END
