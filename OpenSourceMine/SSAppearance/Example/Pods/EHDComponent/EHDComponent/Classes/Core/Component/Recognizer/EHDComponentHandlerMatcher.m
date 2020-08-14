//
//  EHDComponentHandlerMatcher.m
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDComponentHandlerMatcher.h"
#import "EHDComponentHandlerPlug.h"
#import "EHDComponentConfig.h"

@implementation EHDComponentHandlerMatcher
// 匹配组件处理器
+ (Class<EHDComponentHandlerPlug>)matchComponent:(id)component
{
    for (Class<EHDComponentHandlerPlug>handler in [ComponentConfig allComponentHanderPlugs]) {
        if([handler matchComponent:component]) {
            return handler;
        }
    }
    return NULL;
}
@end
