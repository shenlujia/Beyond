//
//  Created by ZZZ on 2021/11/16.
//

#import "SSEasy.h"
#import <objc/runtime.h>

void ss_easy_install(void)
{
    ss_activate_easy_log();
    ss_activate_easy_assert();
    ss_activate_easy_exception();
}

void ss_easy_objc_call(id object, NSString *method, NSArray *args)
{
    NSInteger count = 0;
    for (NSInteger idx = 0; idx < method.length; ++idx) {
        if ([method characterAtIndex:idx] == ':') {
            ++count;
        }
    }
    
    Class c = [object class];
    if (object == [object class]) {
        c = objc_getMetaClass(object_getClassName(c));
    }
    SEL s = NSSelectorFromString(method);
    Method m = class_getInstanceMethod(c, s);
    IMP imp = method_getImplementation(m);
    
    id (^arg)(NSInteger) = ^id (NSInteger idx) {
        id value = nil;
        if (0 <= idx && idx < args.count) {
            NSObject *temp = args[idx];
            if (![temp isKindOfClass:[NSNull class]]) {
                value = temp;
            }
        }
        return value;
    };
    
#define SS_TYPE_0 id, SEL
#define SS_TYPE_1 SS_TYPE_0, id
#define SS_TYPE_2 SS_TYPE_1, id
#define SS_TYPE_3 SS_TYPE_2, id
#define SS_TYPE_4 SS_TYPE_3, id
#define SS_TYPE_5 SS_TYPE_4, id
#define SS_TYPE_6 SS_TYPE_5, id
#define SS_TYPE_7 SS_TYPE_6, id
#define SS_TYPE_8 SS_TYPE_7, id
#define SS_TYPE_9 SS_TYPE_8, id
#define SS_TYPE_10 SS_TYPE_9, id
    
#define SS_ARGS_0 object, s
#define SS_ARGS_1 SS_ARGS_0, arg(0)
#define SS_ARGS_2 SS_ARGS_1, arg(1)
#define SS_ARGS_3 SS_ARGS_2, arg(2)
#define SS_ARGS_4 SS_ARGS_3, arg(3)
#define SS_ARGS_5 SS_ARGS_4, arg(4)
#define SS_ARGS_6 SS_ARGS_5, arg(5)
#define SS_ARGS_7 SS_ARGS_6, arg(6)
#define SS_ARGS_8 SS_ARGS_7, arg(7)
#define SS_ARGS_9 SS_ARGS_8, arg(8)
#define SS_ARGS_10 SS_ARGS_9, arg(9)
    
    if (count == 0) {
        void (*p)(SS_TYPE_0) = (void (*)(SS_TYPE_0))imp;
        p(SS_ARGS_0);
    } else if (count == 1) {
        void (*p)(SS_TYPE_1) = (void (*)(SS_TYPE_1))imp;
        p(SS_ARGS_1);
    } else if (count == 2) {
        void (*p)(SS_TYPE_2) = (void (*)(SS_TYPE_2))imp;
        p(SS_ARGS_2);
    } else if (count == 3) {
        void (*p)(SS_TYPE_3) = (void (*)(SS_TYPE_3))imp;
        p(SS_ARGS_3);
    } else if (count == 4) {
        void (*p)(SS_TYPE_4) = (void (*)(SS_TYPE_4))imp;
        p(SS_ARGS_4);
    } else if (count == 5) {
        void (*p)(SS_TYPE_5) = (void (*)(SS_TYPE_5))imp;
        p(SS_ARGS_5);
    } else if (count == 6) {
        void (*p)(SS_TYPE_6) = (void (*)(SS_TYPE_6))imp;
        p(SS_ARGS_6);
    } else if (count == 7) {
        void (*p)(SS_TYPE_7) = (void (*)(SS_TYPE_7))imp;
        p(SS_ARGS_7);
    } else if (count == 8) {
        void (*p)(SS_TYPE_8) = (void (*)(SS_TYPE_8))imp;
        p(SS_ARGS_8);
    } else if (count == 9) {
        void (*p)(SS_TYPE_9) = (void (*)(SS_TYPE_9))imp;
        p(SS_ARGS_9);
    } else if (count == 10) {
        void (*p)(SS_TYPE_10) = (void (*)(SS_TYPE_10))imp;
        p(SS_ARGS_10);
    }
}
