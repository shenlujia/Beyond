//
//  EHDUIBus.m
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDUIBus.h"
#import "EHDComponentRoutable.h"
#import "EHDURLRoutePlug.h"
#import "EHDURLParse.h"
#import "EHDComponentReflect.h"
#import "EHDComponentConfig.h"
#import "NSObject+ComponentBridge.h"
#import <objc/runtime.h>
#import "EHDComponentManager.h"
//

@interface EHDUIBus ()
/**
 *  可运行组件
 */
@property (nonatomic, weak, readwrite) __kindof id<EHDComponentRoutable>componentRoutable;
@end

@implementation EHDUIBus

- (instancetype)init
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    return [self initWithComponentRoutable:nil];
#pragma clang diagnostic pop
}

- (instancetype)initWithComponentRoutable:(__kindof id<EHDComponentRoutable>)componentRoutable
{
    self = [super init];
    if (self) {
        if (componentRoutable) self.componentRoutable = componentRoutable;
    }
    return self;
}

- (void)setComponentRoutable:(__kindof id<EHDComponentRoutable>)componentRoutable
{
    _componentRoutable = componentRoutable;
}

#pragma mark - URL组件方式
// 自定义打开一个URL组件
- (id<EHDComponentRoutable>)openURL:(NSString *)URL
                    transitionBlock:(TransitionBlock)transitionBlock
                          extraData:(nullable id)extraData
                         completion:(void (^)(id result))completion
{
    __block id<EHDComponentRoutable> component = nil;
    component = [[ComponentConfig routePlug] openURL:URL extraData:extraData completion:completion];
    Activity *thisInterface = [EHDComponentReflect uInterfaceForComponent:self.componentRoutable];
    Activity *nextInterface = [EHDComponentReflect uInterfaceForComponent:component];
    [EHDUIBus _transmitURLParams:nil
                       extraData:extraData
                      completion:completion
                   nextInterface:nextInterface
                   nextComponent:component];
    [EHDComponentManager addComponent:component forName:[EHDURLParse pathFromURL:URL]];
    // 调用转换代码
    if (transitionBlock) {
        transitionBlock(thisInterface, nextInterface.navigationController?:nextInterface, ^{});
    }
    return component;
}

- (id<EHDComponentRoutable>)open:(NSString *)componentName
                 transitionBlock:(TransitionBlock)transitionBlock
                       extraData:(nullable id)extraData
                      completion:(void (^)(id result))completion
{
    id<EHDComponentRoutable> component = [self nextComponent:componentName
                                                      params:nil
                                                   extraData:extraData
                                                  completion:completion];
    [EHDComponentManager addComponent:component forName:componentName];
    // 调用转换代码
    if (transitionBlock) {
        Activity *thisInterface = [EHDComponentReflect uInterfaceForComponent:self.componentRoutable];
        Activity *nextInterface = [EHDComponentReflect uInterfaceForComponent:component];
        transitionBlock(thisInterface, nextInterface.navigationController?:nextInterface, ^{});
    }
    return component;
}

#pragma mark - 自定义组件切换
- (__kindof id<EHDComponentRoutable>)nextComponent:(NSString *)componentName
                                            params:(nullable NSDictionary *)params
                                         extraData:(nullable id)extraData
                                        completion:(void (^)(id result))completion
{
    // 下一组件
    __kindof id<EHDComponentRoutable>nextComponent = [EHDComponentReflect componentFromName:componentName param:params];
    // 视图
    Activity *nextInterface = [EHDComponentReflect uInterfaceForComponent:nextComponent];
    // 传递URL参数
    [EHDUIBus _transmitURLParams:params
                       extraData:extraData
                      completion:completion
                   nextInterface:nextInterface
                   nextComponent:nextComponent];
    
    return nextComponent;
}

// 处理URL参数
+ (void)_transmitURLParams:(NSDictionary *)params
                 extraData:(id)extraData
                completion:(void(^)(id result))completion
             nextInterface:(UIViewController *)nextInterface
             nextComponent:(__kindof id<EHDComponentRoutable>)nextComponent
{
    NSArray<NSString *> *behaviorParams = @[@"navTitle", @"ignoreEvent"];
    // 检测是否有行为参数
    BOOL hasBehaviorParam = NO;
    for (NSString *key in behaviorParams) {
        if(params[key]){
            hasBehaviorParam = YES;
            break;
        }
    }
    if (hasBehaviorParam) {
        // 导航标题
        NSString *navTitle = params[behaviorParams[0]];
        if (navTitle) {
            nextInterface.navigationItem.title = navTitle;
        }
        
        // 移除行为参数
        NSMutableDictionary *mParams = [params mutableCopy];
        for (NSString *behaviorParam in behaviorParams) {
            if (mParams[behaviorParam]) {
                [mParams removeObjectForKey:behaviorParam];
            }
        }
        params = mParams;
    }
    
    // 判断是否要传递URL参数
    [nextComponent setValue:params forKey:@"URLParams"];
    [nextComponent setValue:extraData forKey:@"extraData"];
    [nextComponent setValue:completion forKey:@"completionBlock"];
}
@end
