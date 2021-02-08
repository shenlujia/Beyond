//
//  MainThreadSetterChecker.m
//  Beyond
//
//  Created by ZZZ on 2021/2/8.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "MainThreadSetterChecker.h"
#import <objc/runtime.h>
#import <pthread.h>

static NSSet<Class> *m_set = nil;
static void (^m_callback)(NSDictionary *userInfo);

static pthread_mutex_t m_data_mutex;
static NSMutableDictionary<Class, NSMutableArray<NSDictionary *> *> *m_all;

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

void _not_main_thread_call_add(NSDictionary *m_userInfo)
{
    NSDictionary *userInfo = [m_userInfo copy];
    if (!userInfo) {
        return;
    }

    pthread_mutex_lock(&m_data_mutex);

    NSMutableArray *list = m_all[userInfo[@"class"]];
    if (!list) {
        list = [NSMutableArray array];
        m_all[userInfo[@"class"]] = list;
    }

    if (![list containsObject:userInfo]) {
        [list addObject:userInfo];
    }

    pthread_mutex_unlock(&m_data_mutex);
}

void main_thread_setter_checker_on_class(Class c)
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&m_data_mutex, NULL);
        m_all = [NSMutableDictionary dictionary];
    });

    if (!c) {
        return;
    }
    if ([m_set containsObject:c]) {
        return;
    }

    pthread_mutex_lock(&m_data_mutex);
    NSMutableSet *set = [NSMutableSet setWithSet:m_set];
    [set addObject:c];
    m_set = [set copy];
    pthread_mutex_unlock(&m_data_mutex);

    NSArray *properties = allProperties(c);
    for (NSString *property in properties) {
        NSString *SELString = property;
        if (SELString.length == 0) {
            continue;
        }

        NSString *first = [[SELString substringToIndex:1] capitalizedString];
        SELString = [SELString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:first];
        SELString = [NSString stringWithFormat:@"set%@:", SELString];
        SEL aSEL = NSSelectorFromString(SELString);
        if (![c instancesRespondToSelector:aSEL]) {
            continue;
        }

        Method method = class_getInstanceMethod(c, aSEL);
        const NSInteger argumentsCount = method_getNumberOfArguments(method);
        if (argumentsCount != 3) {
            continue;
        }

        char argumentName[512] = {};
        method_getArgumentType(method, 2, argumentName, 512);
        if (argumentName[0] != '@') {
            continue;
        }

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
                }
                _not_main_thread_call_add(userInfo);
            }
        });
    }
}

void main_thread_setter_checker_set_callback(void (^callback)(NSDictionary *userInfo))
{
    m_callback = callback;
}

NSDictionary * main_thread_setter_checker_all_records(void)
{
    pthread_mutex_lock(&m_data_mutex);
    NSDictionary *ret = [m_all copy];
    pthread_mutex_unlock(&m_data_mutex);
    return ret;
}
