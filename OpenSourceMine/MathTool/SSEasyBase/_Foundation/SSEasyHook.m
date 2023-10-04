//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyHook.h"
#import "SSEasyLog.h"
#import "SSEasyAssert.h"

static BOOL p_ss_method_ignore_internal(Class c, NSString *method, id block)
{
    SEL selector = NSSelectorFromString(method);
    if (!c || !selector) {
        return NO;
    }
    if (![c instancesRespondToSelector:selector]) {
        return NO;
    }
    ss_method_swizzle(c, selector, block);
    return YES;
}

int ss_rebind_symbols(struct rebinding array[], size_t n)
{
    return 0;
}

IMP ss_method_swizzle(Class c, SEL originalSEL, id block)
{
    Method originalMethod = class_getInstanceMethod(c, originalSEL);
    if (!block || !originalSEL || !originalMethod) {
        ss_easy_assert_once_for_key(NSStringFromSelector(originalSEL));
        return NULL;
    }
    
    IMP newIMP = imp_implementationWithBlock(block);
    
    if (!class_addMethod(c, originalSEL, newIMP, method_getTypeEncoding(originalMethod))) {
        return method_setImplementation(originalMethod, newIMP);
    } else {
        return method_getImplementation(originalMethod);
    }
}

BOOL ss_method_ignore(NSString *c, NSString *method)
{
    void (^mark)(NSString *type) = ^(NSString *type) {
        static NSLock *m_lock = nil;
        static NSMutableSet *m_set = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            m_lock = [[NSLock alloc] init];
            m_set = [NSMutableSet set];
        });
        NSString *text = [NSString stringWithFormat:@"class(%@) %@(%@)", c, type, method];
        [m_lock lock];
        if (![m_set containsObject:text]) {
            [m_set addObject:text];
            ss_easy_log(@"Swizzle success: %@", text);
        }
        [m_lock unlock];
    };
    id (^cls_imp)(id) = ^id(id a) {
        mark(@"class_method");
        return nil;
    };
    id (^obj_imp)(id) = ^id(id a) {
        mark(@"instance_method");
        return nil;
    };
    BOOL a = p_ss_method_ignore_internal(object_getClass(NSClassFromString(c)), method, cls_imp);
    BOOL b = p_ss_method_ignore_internal(NSClassFromString(c), method, obj_imp);
    BOOL ret = a || b;
    if (!ret) {
        ss_easy_log(@"Swizzle error: class(%@) method(%@)", c, method);
    }
    return a || b;
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
