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

@implementation NSObject (MethodSwizzle)

+ (BOOL)ss_swizzleMethod:(SEL)originalSEL withMethod:(SEL)otherSEL
{
    Method originalMethod = class_getInstanceMethod(self, originalSEL);
    Method otherMethod = class_getInstanceMethod(self, otherSEL);
    
    IMP originalIMP = class_getMethodImplementation(self, originalSEL);
    class_addMethod(self, originalSEL, originalIMP, method_getTypeEncoding(originalMethod));
    
    IMP otherIMP = class_getMethodImplementation(self, otherSEL);
    class_addMethod(self, otherSEL, otherIMP, method_getTypeEncoding(otherMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, originalSEL), class_getInstanceMethod(self, otherSEL));
    
    return YES;
}

+ (BOOL)ss_swizzleClassMethod:(SEL)originalSEL withClassMethod:(SEL)otherSEL
{
    Class metaClass = object_getClass(self);
    return [metaClass ss_swizzleMethod:originalSEL withMethod:otherSEL];
}

@end
