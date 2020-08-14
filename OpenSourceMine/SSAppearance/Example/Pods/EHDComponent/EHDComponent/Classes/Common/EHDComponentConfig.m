//
//  EHDComponentConfig.m
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDComponentConfig.h"
#import "EHDURLRoute.h"
#import "EHDComponentHandler.h"
#import "EHDComponentStruct.h"
#import "EHDURLRoutePlug.h"
#import "EHDComponentHandlerPlug.h"
@implementation EHDComponentConfig
{
    // URL路由插件
    Class<EHDURLRoutePlug> _routePlug;
    // 组件处理器插件集合
    NSMutableArray<Class<EHDComponentHandlerPlug>> *_componentHanderPlugs;
    
    NSMutableDictionary<NSString *, EHDComponentStruct *> *_componentStructTable;
    
    NSString *_bundleResourcePath;
}

IMP_SINGLETON(EHDComponentConfig)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _componentHanderPlugs = @[].mutableCopy;
        _componentStructTable = @{}.mutableCopy;
        [self setRoutePlug:[EHDURLRoute class]];
        [self->_componentHanderPlugs addObject:[EHDComponentHandler class]];
    }
    return self;
}

+ (instancetype)defaultConfig
{
    EHDComponentConfig *config = [EHDComponentConfig shareInstance];
    // 设置默认解析URL路由插件
    [config setRoutePlug:[EHDURLRoute class]];
    // 添加组件处理器
    [config->_componentHanderPlugs addObject:[EHDComponentHandler class]];
    
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"EHDComponent" ofType:@"bundle"];
    NSString *filePath = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"component" ofType:@"json"];
    config->_bundleResourcePath = [filePath copy];
    return config;
}

#pragma mark - 插件
- (instancetype)setRoutePlug:(Class<EHDURLRoutePlug>)routePlugClass {
    self->_routePlug = routePlugClass;
    return self;
}

- (Class<EHDURLRoutePlug>)routePlug
{
    return self->_routePlug;
}

- (instancetype)addComponentHanderPlug:(Class<EHDComponentHandlerPlug>)componentHanderPlug
{
    // 放在倒数第二个
    [self->_componentHanderPlugs insertObject:componentHanderPlug atIndex:_componentHanderPlugs.count - 1];
    return self;
}

- (NSArray<Class<EHDComponentHandlerPlug>> *)allComponentHanderPlugs
{
    return self->_componentHanderPlugs;
}

- (void)registerURL:(NSString *)URL handler:(_Nullable id (^)(NSDictionary *parameters))handler
{
    [self->_routePlug registerURL:URL handler:handler];
}

- (void)deregisterURL:(NSString *)URL
{
    [self->_routePlug deregisterURL:URL];
}

- (void)registerComponentStructs:(NSArray *)componentStructs
{
    if (![componentStructs isKindOfClass:[NSArray class]]){
        return;
    }
    
    for (id component in componentStructs) {
        if ([component isKindOfClass:[NSDictionary class]]) {
            NSString *name = component[@"name"];
            NSString *className = component[@"class"];
            NSString *selector = component[@"selector"];
            Class cls = NSClassFromString(className);
            if ([name length] && cls) {
                EHDComponentStruct *structure = [[EHDComponentStruct alloc] init];
                structure.componentName = name;
                structure.componentClass = cls;
                structure.componentSelector = NSSelectorFromString(selector);
                [self->_componentStructTable setValue:structure forKey:name];
            }
        }
    }
}

- (NSDictionary<NSString *, EHDComponentStruct*> *)componentStructs
{
    return [NSDictionary dictionaryWithDictionary:self->_componentStructTable];
}

- (NSString *)bundleResourcePath
{
    return self->_bundleResourcePath;
}
@end
