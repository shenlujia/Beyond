//
//  NSObject+SSDescription.m
//  AFNetworking
//
//  Created by shenlujia on 2017/11/16.
//

#import "NSObject+SSDescription.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#import <MJExtension.h>
#pragma clang diagnostic pop

@implementation NSObject (SSDescription)

+ (void)load
{
//    Class string = NSClassFromString(@"NSString");
//    NSArray *string_s = [string ss_selectors];
//    NSArray *string_p = [string ss_properties];
//    NSArray *string_i = [string ss_ivars];
//
//    NSMutableArray *a = [NSMutableArray array];
//    [string mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
//        [a addObject:property.name];
//    }];
//
//    Class view = NSClassFromString(@"UIView");
//    Class layer = NSClassFromString(@"CALayer");
//    NSArray *s0 = [view ss_selectors];
//    NSArray *p0 = [view ss_properties];
//    NSArray *i0 = [view ss_ivars];
//    NSArray *s1 = [layer ss_selectors];
//    NSArray *p1 = [layer ss_properties];
//    NSArray *i1 = [layer ss_ivars];
//    BOOL b0 = [p0 containsObject:@"frame"];
//    BOOL b1 = [p0 containsObject:@"_frame"];
//    BOOL b2 = [p1 containsObject:@"frame"];
//    BOOL b3 = [p1 containsObject:@"_frame"];
//    NSLog(@"");
}

+ (NSArray<NSString *> *)ss_selectors
{
    NSMutableArray *array = [NSMutableArray array];
    u_int count = 0;
    Method *methods = class_copyMethodList([self class], &count);
    for (u_int i = 0; i < count; ++i) {
        SEL sel = method_getName(methods[i]);
        NSString *name = [NSString stringWithCString:sel_getName(sel) encoding:NSUTF8StringEncoding];
        if (name) {
            [array addObject:name];
        }
    }
    return [array copy];
}

+ (NSArray<NSString *> *)ss_properties
{
    NSMutableSet *set = [NSMutableSet set];
    u_int count = 0;
    objc_property_t *list = class_copyPropertyList([self class], &count);
    for (u_int i = 0; i < count; ++i) {
        objc_property_t property = list[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        if (name) {
            [set addObject:name];
        }
    }
    return [set.allObjects sortedArrayUsingComparator:^NSComparisonResult(NSString *s1, NSString *s2) {
        return [s1 compare:s2];
    }];
}

+ (NSArray<NSString *> *)ss_ivars
{
    NSMutableArray *array = [NSMutableArray array];
    u_int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (const Ivar *p = ivars; p < ivars + count; ++p) {
        Ivar const ivar = *p;
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if (name) {
            [array addObject:name];
        }
    }
    return  [array copy];
}

@end
