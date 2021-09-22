//
//  Created by ZZZ on 2020/10/30.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

FOUNDATION_EXTERN IMP ss_method_swizzle(Class c, SEL originalSEL, id block);

// 返回值占空间小于一个指针的方法可能会有问题
FOUNDATION_EXTERN BOOL ss_method_ignore(NSString *c, NSString *method);

