//
//  NSObject+ComponentBridge.m
//  Pods
//
//  Created by luohs on 2017/11/7.
//
//

#import "NSObject+ComponentBridge.h"
#import <objc/runtime.h>

@implementation NSObject (ComponentBridge)
- (void)setUiBus:(__kindof EHDUIBus *)uiBus
{
    objc_setAssociatedObject(self, @selector(uiBus), uiBus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EHDUIBus *)uiBus
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setEventBus:(__kindof EHDEventBus *)eventBus
{
    objc_setAssociatedObject(self, @selector(eventBus), eventBus, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EHDEventBus *)eventBus
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setURLParams:(NSDictionary *)URLParams
{
    objc_setAssociatedObject(self, @selector(URLParams), URLParams, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)URLParams
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setExtraData:(id)extraData
{
    objc_setAssociatedObject(self, @selector(extraData), extraData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)extraData
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCompletionBlock:(void (^ _Nullable)(id _Nullable))completionBlock
{
        objc_setAssociatedObject(self, @selector(completionBlock), completionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^ _Nullable)(id _Nullable))completionBlock
{
    return objc_getAssociatedObject(self, _cmd);
}
@end
