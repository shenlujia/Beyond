//
//  NSObject+MethodSwizzle.m — stub
//

#import "SSEasyHook.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzle)

+ (BOOL)ss_swizzleMethod:(SEL)originalSEL withMethod:(SEL)otherSEL
{
    Method originalMethod = class_getInstanceMethod(self, originalSEL);
    Method otherMethod = class_getInstanceMethod(self, otherSEL);
    if (!originalMethod || !otherMethod) return NO;
    method_exchangeImplementations(originalMethod, otherMethod);
    return YES;
}

+ (BOOL)ss_swizzleClassMethod:(SEL)originalSEL withClassMethod:(SEL)otherSEL
{
    Class metaClass = object_getClass(self);
    return [metaClass ss_swizzleMethod:originalSEL withMethod:otherSEL];
}

@end
