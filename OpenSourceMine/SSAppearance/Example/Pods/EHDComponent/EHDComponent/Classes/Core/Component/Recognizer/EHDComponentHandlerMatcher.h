//
//  EHDComponentHandlerMatcher.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EHDComponentHandlerPlug;
@interface EHDComponentHandlerMatcher : NSObject

/**
*  根据组件名或组件对象找到组件处理器
*
*  @param component 组件名或组件对象
* 
*/
+ (Class<EHDComponentHandlerPlug>)matchComponent:(id)component;
@end
