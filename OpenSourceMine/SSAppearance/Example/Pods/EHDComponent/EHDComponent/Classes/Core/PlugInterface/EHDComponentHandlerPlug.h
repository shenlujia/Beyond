//
//  EHDComponentHandlerPlug.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#ifndef EHDComponentHandlerPlug_h
#define EHDComponentHandlerPlug_h

#import <UIKit/UIKit.h>
#import "EHDComponentRoutable.h"
#import "EHDUIBus.h"

/**
 *  组件处理器插件接口
 */
@protocol EHDComponentHandlerPlug <NSObject>
/**
 *  插件是否能处理这个组件对象
 *
 *  @param component 组件名或组件对象
 *
 */
+ (BOOL)matchComponent:(id)component;
/**
 *  根据组件名创建一个组件
 *
 *  @param componentName 组件名
 *
 *  @return 组件
 */
+ (id<EHDComponentRoutable>)componentFromName:(NSString *)componentName param:(id)param;
/**
 *  根据组件可运行对象返回界面层
 *
 *  @param component 组件可运行对象
 *
 */
+ (UIViewController *)uInterfaceForComponent:(__kindof id<EHDComponentRoutable>)component;
@end
#endif /* EHDComponentHandlerPlug_h */
