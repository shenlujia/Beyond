//
//  TFSSUtil.m
//  AFNetworking
//
//  Created by admin on 2018/5/10.
//

#import "TFSSUtil.h"
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#import <objc/runtime.h>

@interface TFSSUtil ()

@end

@implementation TFSSUtil

+ (NSArray *)appClassNames
{
    Dl_info info;
    dladdr(&_mh_execute_header, &info);
    
    unsigned int count = 0;
    const char **classNames = objc_copyClassNamesForImage(info.dli_fname, &count);
    
    NSMutableArray *ret = [NSMutableArray array];
    for (unsigned int i = 0; i < count; ++i) {
        NSString *name = [NSString stringWithCString:classNames[i]
                                            encoding:NSUTF8StringEncoding];
        if (name) {
            [ret addObject:name];
        }
    }
    [ret sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    free(classNames);
    
    return [ret copy];
}

+ (NSArray *)allClassNames
{
    const int total = objc_getClassList(NULL, 0);
    if (total <= 0) {
        return nil;
    }
    
    Class *classes = (Class *)malloc(sizeof(Class) * total);
    const int count = objc_getClassList(classes, total);
    
    NSMutableArray *ret = [NSMutableArray array];
    for (int i = 0; i < count; ++i) {
        Class class = classes[i];
        NSString *name = NSStringFromClass(class);
        if (name.length) {
            [ret addObject:name];
        }
    }
    
    [ret sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    free(classes);
    
    return [ret copy];
}

+ (NSArray *)appClassNamesRespondsToSelector:(SEL)aSelector
{
    NSArray *array = [self appClassNames];
    NSSet *whiteList = [self classNameWhiteList];
    
    NSMutableArray *ret = [NSMutableArray array];
    for (NSString *name in array) {
        if (![whiteList containsObject:name]) {
            Class cls = NSClassFromString(name);
            if ([cls respondsToSelector:aSelector] ||
                [cls instancesRespondToSelector:aSelector]) {
                [ret addObject:name];
            }
        }
    }
    return [ret copy];
}

+ (NSArray *)allClassNamesRespondsToSelector:(SEL)aSelector
{
    NSArray *array = [self allClassNames];
    NSSet *whiteList = [self classNameWhiteList];
    
    NSMutableArray *ret = [NSMutableArray array];
    for (NSString *name in array) {
        if (![whiteList containsObject:name]) {
            Class cls = NSClassFromString(name);
            if ([cls respondsToSelector:aSelector] ||
                [cls instancesRespondToSelector:aSelector]) {
                [ret addObject:name];
            }
        }
    }
    return [ret copy];
}

+ (NSSet *)classNameWhiteList
{
    static NSSet *ret = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableSet *set = [NSMutableSet set];
        // 8.x
        [set addObject:@"JSExport"];
        [set addObject:@"NSLeafProxy"];
        [set addObject:@"Object"];
        [set addObject:@"_NSZombie_"];
        [set addObject:@"__NSAtom"];
        [set addObject:@"__NSGenericDeallocHandler"];
        [set addObject:@"__NSMessageBuilder"];
        // 9.x
        [set addObject:@"FigIrisAutoTrimmerMotionSampleExport"];
        [set addObject:@"_CNZombie_"];
        //
        ret = [set copy];
    });
    return ret;
}

@end
