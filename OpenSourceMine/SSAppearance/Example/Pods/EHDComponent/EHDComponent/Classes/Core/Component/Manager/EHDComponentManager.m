//
//  EHDComponentManager.m
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDComponentManager.h"
#import "EHDComponentRoutable.h"
#import "EHDComponentReflect.h"
#import "EHDComponentMarco.h"
#import "EHDComponentConfig.h"

static NSMutableDictionary *componentArrTable_;
@implementation EHDComponentManager
+ (NSMutableDictionary *)components
{
    if (componentArrTable_ == nil) {
        componentArrTable_ = [NSMutableDictionary dictionary];
    }
    return componentArrTable_;
}

+ (void)addComponent:(id<EHDComponentRoutable>)component forName:(NSString *)componentName
{
    if (component == nil || componentName == nil){
        return;
    }
    NSPointerArray *array = [[self class] componentArrForName:componentName];
    if (array == nil) {
        array = [NSPointerArray weakObjectsPointerArray];
    }
    [array compact];
    [array addPointer:(__bridge void *)component];
    [[self components] setObject:array forKey:componentName];
}

+ (NSPointerArray *)componentArrForName:(NSString *)componentName
{
    NSEnumerator *keys = [self components].keyEnumerator;
    for (NSString *key in keys) {
        if ([key isEqualToString:componentName]) {
            return [[self components] objectForKey:key];
        }
    }
    return nil;
}

+ (void)sendEventName:(NSString *)eventName intentData:(nullable id)intentData forComponent:(nonnull NSString *)componentName
{
    NSPointerArray *array = [self componentArrForName:componentName];
    [[array allObjects] enumerateObjectsUsingBlock:^(id<EHDComponentRoutable> obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(receiveComponentEventName:intentData:)]) {
            [obj receiveComponentEventName:eventName intentData:intentData];
        }
    }];
}

+ (void)sendEventName:(NSString *)eventName intentData:(nullable id)intentData forComponents:(nonnull NSArray<NSString *> *)componentNames
{
    for (NSString *compName in componentNames) {
        [self sendEventName:eventName intentData:intentData forComponent:compName];
    }
}
@end
