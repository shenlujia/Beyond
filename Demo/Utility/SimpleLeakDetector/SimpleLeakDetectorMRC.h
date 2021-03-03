//
//  SimpleLeakDetectorMRC.h
//  Demo
//
//  Created by ZZZ on 2020/11/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleLeakDetectorMRC : NSObject

+ (void)run;

+ (void)enumPointersWithBlock:(void (^)(const char *class_name, uintptr_t pointer))block;

+ (BOOL)isPointerValidWithClassName:(const char *)name pointer:(uintptr_t)pointer;

+ (void)enableDelayDealloc;

+ (void)disableDelayDealloc;

@end
