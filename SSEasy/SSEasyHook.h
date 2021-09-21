//
//  Created by ZZZ on 2020/10/30.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

FOUNDATION_EXTERN IMP ss_method_swizzle(Class c, SEL originalSEL, id block);

FOUNDATION_EXTERN BOOL ss_method_ignore(NSString *c, NSString *method);

