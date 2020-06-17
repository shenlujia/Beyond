//
//  NSObject+MethodSwizzle.h
//  Demo
//
//  Created by SLJ on 2020/5/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline bool is_sel_same(const char *func, SEL _cmd)
{
    char buff[256] = {'\0'};
    if (strlen(func) > 2) {
        char* s = strstr(func, " ") + 1;
        char* e = strstr(func, "]");
        memcpy(buff, s, sizeof(char) * (e - s) );
        return strcmp(buff, sel_getName(_cmd)) == 0;
    }
    return false;
}

#define ALERT_IF_METHOD_REPLACED \
do { \
  if (!is_sel_same(__PRETTY_FUNCTION__, _cmd)) { \
    NSLog(@"is_swizzled !!!"); \
  } \
} while (0);

extern IMP SSSwizzleMethodWithBlock(Class c, SEL originalSEL, id block);

@interface NSObject (MethodSwizzle)

+ (BOOL)ss_swizzleMethod:(SEL)originalSEL withMethod:(SEL)otherSEL;

+ (BOOL)ss_swizzleClassMethod:(SEL)originalSEL withClassMethod:(SEL)otherSEL;

@end
