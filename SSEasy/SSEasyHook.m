//
//  Created by ZZZ on 2020/10/30.
//

#import "SSEasyHook.h"
#import "SSEasyLog.h"

static BOOL p_ss_method_swizzle_impl(Class c, NSString *method, id block)
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
    extern void open_bdfishhook(void);
    open_bdfishhook();
    
    extern int bd_rebind_symbols(struct rebinding array[], size_t n);
    return bd_rebind_symbols(array, n);
}

IMP ss_method_swizzle(Class c, SEL originalSEL, id block)
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
            SSEasyLog(@"Swizzle success: %@", text);
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
    BOOL a = p_ss_method_swizzle_impl(object_getClass(NSClassFromString(c)), method, cls_imp);
    BOOL b = p_ss_method_swizzle_impl(NSClassFromString(c), method, obj_imp);
    BOOL ret = a || b;
    if (!ret) {
        SSEasyLog(@"Swizzle error: class(%@) method(%@)", c, method);
    }
    return a || b;
}
