//
//  NSObject+MethodSwizzle.h
//  Demo
//
//  Created by SLJ on 2020/5/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

extern IMP SSSwizzleMethodWithBlock(Class c, SEL originalSEL, id block);

@interface NSObject (MethodSwizzle)

+ (BOOL)ss_swizzleMethod:(SEL)originalSEL withMethod:(SEL)otherSEL;

+ (BOOL)ss_swizzleClassMethod:(SEL)originalSEL withClassMethod:(SEL)otherSEL;

@end
