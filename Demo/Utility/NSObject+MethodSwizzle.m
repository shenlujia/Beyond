//
//  NSObject+MethodSwizzle.m
//  Demo
//
//  Created by SLJ on 2020/5/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "NSObject+MethodSwizzle.h"
#import <objc/runtime.h>

IMP SSSwizzleMethodWithBlock(Class c, SEL originalSEL, id block)
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
