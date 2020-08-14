//
//  NSObject+HSKVO.m
//  HSKVO
//
//  Created by shenlujia on 2015/12/22.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "NSObject+HSKVO.h"
#import <objc/runtime.h>
#import "HSKVOManager.h"

NSString *const HSKVONotificationKeyPathKey = @"HSKVONotificationKeyPathKey";

const static void * kHSKVOKey = &kHSKVOKey;

@implementation NSObject (HSKVO)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oriMethod = class_getInstanceMethod(self, @selector(addObserver:forKeyPath:options:context:));
        Method altMethod = class_getInstanceMethod(self, @selector(pp_addObserver:forKeyPath:options:context:));
        method_exchangeImplementations(oriMethod, altMethod);
    });
}

- (void)pp_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    [self pp_addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (id <HSKVO>)HSKVO
{
    id ret = objc_getAssociatedObject(self, kHSKVOKey);
    if (![ret conformsToProtocol:@protocol(HSKVO)]) {
        ret = [[HSKVOManager alloc] initWithObserver:self];
        objc_setAssociatedObject(self, kHSKVOKey, ret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ret;
}

- (void)setHSKVO:(id<HSKVO>)HSKVO
{
    objc_setAssociatedObject(self, kHSKVOKey, HSKVO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
