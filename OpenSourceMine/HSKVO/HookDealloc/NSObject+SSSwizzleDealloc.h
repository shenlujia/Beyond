//
//  NSObject+SSSwizzleDealloc.h
//  HSKVO
//
//  Created by shenlujia on 2018/3/14.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SSSwizzleDealloc)

- (void)ss_swizzleDeallocWithBlock:(void (^)(__unsafe_unretained id object))block;

@end
