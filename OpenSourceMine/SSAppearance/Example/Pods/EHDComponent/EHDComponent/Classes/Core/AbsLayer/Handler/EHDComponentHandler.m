//
//  EHDComponentHandler.m
//  Pods
//
//  Created by luohs on 2017/11/7.
//
//

#import "EHDComponentHandler.h"
#import "EHDComponentConfig.h"
#import "EHDComponentStruct.h"
#pragma mark EHDComponentHandler
@implementation EHDComponentHandler
#pragma mark - get componet
+ (id)componentWithName:(NSString*)name param:(NSDictionary*)param
{
    if ([name length]) {
        EHDComponentStruct *structure = [[ComponentConfig componentStructs] objectForKey:name];
        id component = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([structure.componentClass respondsToSelector:structure.componentSelector]){
            component = [structure.componentClass performSelector:structure.componentSelector
                                                       withObject:param];
        }
        else {
            component = [[structure.componentClass alloc] init];
        }
#pragma clang diagnostic pop
        return component;
    }
    return nil;
}

#pragma mark - protocol EHDComponentHandlerPlug
+ (BOOL)matchComponent:(id)component
{
    return component != nil;
}

+ (id<EHDComponentRoutable>)componentFromName:(NSString *)componentName param:(id)param
{
    id component = [self componentWithName:componentName param:param];
    if (!component) {
        Class cls = NSClassFromString(componentName);
        if (cls) {
            component = [[cls alloc] init];
        }
    }
    return component;
}

+ (UIViewController *)uInterfaceForComponent:(__kindof id<EHDComponentRoutable>)component
{
    if ([component respondsToSelector:@selector(componentUInterface)]) {
        return [component componentUInterface];
    }
    else if ([component isKindOfClass:[UIViewController class]]) {
        return component;
    }
    return nil;
}
@end
