//
//  IvarController.m
//  Demo
//
//  Created by SLJ on 2020/6/3.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "IvarController.h"
#import <objc/runtime.h>

template <typename IVAR>
__attribute__((always_inline))
IVAR& getIvar(NSObject * object, const char * name) {
    Ivar ivar = class_getInstanceVariable(object_getClass(object), name);
    if (ivar != NULL) {
        return *((IVAR *)(((long)object) + ivar_getOffset(ivar)));
    }

    NSException * exc = [NSException exceptionWithName:@"Cannot get ivar" reason:[NSString stringWithFormat:@"Cannot get ivar named '%s' from %@", name, [object description]] userInfo:nil];
    [exc raise];

    // just fool compiler
    // it's unsafe if we really dereference nullptr
    return *((IVAR *)0);
}

@interface TestIvarRoot : NSObject

@property (nonatomic, assign) NSInteger index;

@end

@implementation TestIvarRoot

@end

@interface TestIvarOne : TestIvarRoot

@property (nonatomic, assign) NSInteger index;

@end

@implementation TestIvarOne

@end

@interface TestIvarObj : NSObject

@end

@implementation TestIvarObj

@end

@interface Data : NSObject {
@private
    int32_t b_int32;
    CGSize _size;
    CGSize _another_size;
    TestIvarObj *obj;
}

@end

@implementation Data

- (void):(id)obj
{
    NSLog(@"%s",_cmd);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self->b_int32 = 233;
        self->_size = CGSizeMake(0.233, 0.2333);
        self->_another_size = CGSizeMake(233, 2333);
        self->obj = [[TestIvarObj alloc] init];
    }
    return self;
}

@end

@interface IvarController ()

@end

@implementation IvarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 直接用object_getIvar是获取不到基本数据类型的Ivar的，应该通过class_getInstanceVariable拿到Ivar之后，再用ivar_getOffset获取Ivar相对于实例本身的偏移。
    
//    Data * data = [[Data alloc] init];
//    // todo... 需要进一步研究
//    @try {
//        // get
//        NSLog(@"data->b_int32: %d", getIvar<int>(data, "b_int32"));
//
//        // modify
//        getIvar<int>(data, "b_int32") = 234;
//        NSLog(@"data->b_int32: %d", getIvar<int>(data, "b_int32"));
//
//        // get struct
//        NSLog(@"data->_size.height: %lf", getIvar<CGSize>(data, "_size").height);
//        NSLog(@"data->_size.width: %lf", getIvar<CGSize>(data, "_size").width);
//        NSLog(@"data->_another_size.height: %lf", getIvar<CGSize>(data, "_another_size").height);
//        NSLog(@"data->_another_size.width: %lf", getIvar<CGSize>(data, "_another_size").width);
////        TestIvarObj *t = getIvar<TestIvarObj *>(data, "obj");
//
//        Ivar ivar_obj = class_getInstanceVariable(object_getClass(data), "obj");
//        ptrdiff_t kkk = ivar_getOffset(ivar_obj);
//        id ooo = object_getIvar(data, ivar_obj);
//
//        Ivar ivar_obj2 = class_getInstanceVariable(object_getClass(data), "b_int32");
//        ptrdiff_t kkk2 = ivar_getOffset(ivar_obj2);
//        id ooo2 = object_getIvar(data, ivar_obj2);
//
//
//        // get some non-exist ivar
//        // throws
//        getIvar<int>(data, "_int32");
//    } @catch (NSException *exception) {
//        NSLog(@"exception: %@", [exception reason]);
//    } @finally {
//
//    };
    
    [self test:@"父类和子类相同property" tap:^(UIButton *button) {
        TestIvarOne *one = [[TestIvarOne alloc] init];
        one.index = 5;
        NSLog(@"");
    }];
}

@end
