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

+ (void)enumObjectsWithBlock:(void (^)(const char *class_name, uintptr_t pointer))block;

+ (void)enableDelayDealloc;
+ (void)disableDelayDealloc;

@end
