//
//  NotMainThreadClassDetector.m
//  Beyond
//
//  Created by ZZZ on 2021/2/7.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "NotMainThreadClassDetector.h"
#import <objc/runtime.h>
#import <pthread.h>

static NSSet<Class> *m_set = nil;
static void (^m_callback)(NSDictionary *userInfo);

static NSArray * allProperties(Class cls)
{
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; ++i) {
        objc_property_t property = properties[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [array addObject:name];
    }
    free(properties);
    return array;
}

static IMP SSSwizzleMethodWithBlock(Class c, SEL originalSEL, id block)
{
    NSCParameterAssert(block);

    Method originalMethod = class_getInstanceMethod(c, originalSEL);
    NSCParameterAssert(originalMethod);

    IMP newIMP = imp_implementationWithBlock(block);

    if (!class_addMethod(c, originalSEL, newIMP, method_getTypeEncoding(originalMethod))) {
        return method_setImplementation(originalMethod, newIMP);
    } else {
        return method_getImplementation(originalMethod);
    }
}

@implementation NotMainThreadClassDetector

+ (void)checkClass:(Class)c
{
    if (!c) {
        return;
    }
    if ([m_set containsObject:c]) {
        return;
    }

    NSMutableSet *set = [NSMutableSet setWithSet:m_set];
    [set addObject:c];
    m_set = [set copy];

    NSArray *properties = allProperties(c);
    for (NSString *property in properties) {
        NSString *SELString = property;
        if (SELString.length > 0) {
            NSString *first = [[SELString substringToIndex:1] capitalizedString];
            SELString = [SELString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:first];
            SELString = [NSString stringWithFormat:@"set%@:", SELString];
            SEL aSEL = NSSelectorFromString(SELString);
            if ([c instancesRespondToSelector:aSEL]) {
                __block IMP impl;
                impl = SSSwizzleMethodWithBlock(c, aSEL, ^(id aself, id value) {
                    ((void (*)(id aself, SEL aSEL, id value))impl)(aself, aSEL, value);
                    if (!pthread_main_np()) {
                        NSMutableArray *callStack = [NSMutableArray arrayWithArray:[NSThread callStackSymbols]];
                        if (callStack.count > 0) {
                            [callStack removeObjectAtIndex:0];
                        }
                        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                        userInfo[@"class"] = c;
                        userInfo[@"property"] = property;
                        userInfo[@"SEL"] = SELString;
                        userInfo[@"callStack"] = callStack;
                        if (m_callback) {
                            m_callback(userInfo);
                        } else {
                            NSLog(@"%@", userInfo);
                        }
                    }
                });
            }
        }
    }
}

+ (void)setCallback:(void (^)(NSDictionary *userInfo))callback
{
    m_callback = callback;
}

@end
