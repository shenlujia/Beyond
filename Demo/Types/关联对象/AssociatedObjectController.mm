//
//  AssociatedObjectController.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AssociatedObjectController.h"
#import <objc/runtime.h>
#import <string>
#include <mutex>
#import "MacroHeader.h"

using namespace std;

class TestDeallocCpp1Class
{
  public:
    string name;
    NSObject *test_oc;
    TestDeallocCpp1Class()
    {
        static int index = 100;
        NSString *s = @(index++).stringValue;
        name = string(s.UTF8String);
        test_oc = [[NSClassFromString(@"Test1Base") alloc] init];
    }
    ~TestDeallocCpp1Class()
    {
        printf("~TestDeallocCpp1Class: %s\n", name.c_str());
    }
    static TestDeallocCpp1Class &shared1()
    {
        static TestDeallocCpp1Class a;
        a.name = "shared1";
        return a;
    }
    static TestDeallocCpp1Class &shared2()
    {

        static std::recursive_mutex mutex_ss;
        static TestDeallocCpp1Class *b = new TestDeallocCpp1Class();
        b->name = "shared2";
        return *b;
    }
    static TestDeallocCpp1Class &k1;
    static TestDeallocCpp1Class k2;
};


TestDeallocCpp1Class &TestDeallocCpp1Class::k1 = *new TestDeallocCpp1Class();
TestDeallocCpp1Class TestDeallocCpp1Class::k2;


static TestDeallocCpp1Class p_cpp_obj1;
TestDeallocCpp1Class p_cpp_obj2;

@class Test1Prop;

@interface Test1Base : NSObject

@property (nonatomic, strong) NSObject *base1;
@property (nonatomic, strong) NSObject *base2;

@end

@implementation Test1Base

- (void)dealloc
{
    printf("~Test1Base\n");
}

@end

@interface Test1Derived : Test1Base

@property (nonatomic, assign) TestDeallocCpp1Class cpp_obj1;
@property (nonatomic, strong) NSObject *obj1;
@property (nonatomic, strong) Test1Prop *prop1;
@property (nonatomic, strong) NSObject *obj2;
@property (nonatomic, assign) NSInteger intValue;
@property (nonatomic, strong) Test1Prop *prop2;
@property (nonatomic, strong) NSObject *obj3;
@property (nonatomic, assign) TestDeallocCpp1Class cpp_obj2;

- (void)print;

@end

@interface Test1Prop : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) Test1Derived *main_weak;
@property (nonatomic, assign) Test1Derived *main_assign;

@end

@implementation Test1Prop

- (void)dealloc
{
    NSLog(@"~Test1Prop: %@", self.name);
    [self.main_assign print];
    printf("\n");
}

@end

@implementation Test1Derived

- (void)dealloc
{
    NSLog(@"~Test1Derived");
    [self print];
    printf("\n");
}

+ (void)classMethod
{
}

- (void)print
{
    Test1Prop *ass = objc_getAssociatedObject(self, @selector(title));
    NSLog(@"base1:%p base2:%p", self.base1, self.base2);
    NSLog(@"obj1:%p prop1:%@ obj2:%p int:%ld prop2:%@ obj3:%p associated:%@", self.obj1, self.prop1.name, self.obj2, self.intValue, self.prop2.name, self.obj3,
          ass.name);
}

@end

@implementation Test1Derived (MORE)

- (void)hij
{
}

- (void)abc
{
}

- (void)def
{
}

@end

@interface AssociatedObjectController ()

@end

@implementation AssociatedObjectController

+ (void)load
{
    NSLog(@"AssociatedObjectController load");
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    PRINT_BLANK_LINE
    NSLog(@"%@:", NSStringFromClass([Test1Base class]));
    NSLog(@"ivar: %@", [self allIvars:[Test1Base class]]);
    NSLog(@"property: %@", [self allProperties:[Test1Base class]]);
    NSLog(@"方法: %@", [self allMethods:[Test1Base class]]);
    
    PRINT_BLANK_LINE
    NSLog(@"%@:", NSStringFromClass([Test1Derived class]));
    NSLog(@"ivar: %@", [self allIvars:[Test1Derived class]]);
    NSLog(@"property: %@", [self allProperties:[Test1Derived class]]);
    NSLog(@"方法: %@", [self allMethods:[Test1Derived class]]);
    
    TestDeallocCpp1Class::k1.name = "k1";
    TestDeallocCpp1Class::k2.name = "k2";
    TestDeallocCpp1Class::shared1();
    TestDeallocCpp1Class::shared2();

    [self test:@"test" tap:^(UIButton *button, NSDictionary *userInfo) {
        Test1Derived *main = [[Test1Derived alloc] init];
        //               main.cpp_obj1.name = "cpp_obj1";
        //               main.cpp_obj2.name = "cpp_obj2";
        main.base1 = [UIViewController new];
        main.base2 = [UIView new];
        main.obj1 = [UIStackView new];
        main.obj2 = [UIViewController new];
        main.obj3 = [UIColor new];
        main.intValue = 888;

        Test1Prop *prop1 = [[Test1Prop alloc] init];
        prop1.name = @"prop1";
        prop1.main_weak = main;
        prop1.main_assign = main;
        main.prop1 = prop1;
        Test1Prop *prop2 = [[Test1Prop alloc] init];
        prop2.name = @"prop2";
        prop2.main_weak = main;
        prop2.main_assign = main;
        main.prop2 = prop2;

        Test1Prop *associatedObject = [[Test1Prop alloc] init];
        associatedObject.name = @"associated";
        associatedObject.main_weak = main;
        associatedObject.main_assign = main;
        objc_setAssociatedObject(main, @selector(title), associatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }];
}

- (NSArray *)allIvars:(Class)cls
{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList(cls, &count);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; ++i) {
        Ivar property = ivars[i];
        const char *cName = ivar_getName(property);
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [array addObject:name];
    }
    free(ivars);
    return array;
}

- (NSArray *)allProperties:(Class)cls
{
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; ++i) {
        objc_property_t property = properties[i];
        const char *cName = property_getName(property);
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [array addObject:name];
    }
    free(properties);
    return array;
}

- (NSArray *)allMethods:(Class)cls
{
    unsigned int count = 0;
    Method *methods = class_copyMethodList([cls class], &count);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; ++i) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
        [array addObject:name];
    }
    free(methods);
    return array;
}

@end
