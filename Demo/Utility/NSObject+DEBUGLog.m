//
//  NSObject+DEBUGLog.m
//  Beyond
//
//  Created by ZZZ on 2021/3/17.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "NSObject+DEBUGLog.h"
#import <objc/runtime.h>

@implementation NSObject (DEBUGLog)

//- (NSString *)debugDescription
//{
//    return [NSString stringWithFormat:@"%@: %@", [self class], [[self class] p_ivarsOfObject:self]];
//}
//
//+ (NSArray *)p_ivarsOfObject:(NSObject *)object
//{
//    NSMutableArray *pairs = [NSMutableArray array];
//    Class cls = [object class];
//
//    while (cls && cls != [NSObject class]) {
//        unsigned int count = 0;
//        Ivar *ivars = class_copyIvarList(cls, &count);
//        for (int i = 0; i < count; ++i) {
//            Ivar property = ivars[i];
//            const char *cName = ivar_getName(property);
//            NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
//            id value = [object valueForKey:name];
//            [pairs addObject:[NSString stringWithFormat:@"%@ = %@", name, value]];
//        }
//        free(ivars);
//        cls = [cls superclass];
//    }
//
//    [pairs sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [obj1 compare:obj2];
//    }];
//
//    return pairs;
//}

@end
