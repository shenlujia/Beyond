//
//  EHDComponentReflect.m
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDComponentReflect.h"
#import "EHDComponentHandlerMatcher.h"
#import "EHDComponentHandlerPlug.h"

#define MatchedComponentHandler Class<EHDComponentHandlerPlug> matchedComponentHandler = [self componentHandlerForComponent:(id)component];

@implementation EHDComponentReflect
+ (Class<EHDComponentHandlerPlug>)componentHandlerForComponent:(id)component
{
    return [EHDComponentHandlerMatcher matchComponent:component];
}

+ (id<EHDComponentRoutable>)componentFromName:(NSString *)component param:(id)param;
{
    MatchedComponentHandler
    return [matchedComponentHandler componentFromName:component param:param];
}

+ (UIViewController *)uInterfaceForComponent:(__kindof id<EHDComponentRoutable>)component
{
    MatchedComponentHandler
    return [matchedComponentHandler uInterfaceForComponent:component];
}
@end
