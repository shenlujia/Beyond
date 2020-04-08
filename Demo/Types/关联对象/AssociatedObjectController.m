//
//  AssociatedObjectController.m
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AssociatedObjectController.h"
#import <objc/runtime.h>

@class AssociatedObjectTestOne;

@interface AssociatedObjectTestMain : NSObject

@property (nonatomic, strong) NSObject *obj1;
@property (nonatomic, strong) AssociatedObjectTestOne *property ;
@property (nonatomic, strong) NSObject *obj2;
@property (nonatomic, strong) NSObject *obj3;

- (void)print;

@end

@interface AssociatedObjectTestOne : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) AssociatedObjectTestMain *main_weak;
@property (nonatomic, assign) AssociatedObjectTestMain *main_assign;

@end

@implementation AssociatedObjectTestOne

- (void)dealloc
{
    [self.main_assign print];
    NSLog(@"~AssociatedObjectTestOne: %@", self.name);
    printf("\n");
}

@end

@implementation AssociatedObjectTestMain

- (void)dealloc
{
    [self print];
    NSLog(@"~AssociatedObjectTestMain");
    printf("\n");
}

- (void)print
{
    AssociatedObjectTestOne *ass = objc_getAssociatedObject(self, @selector(title));
    NSLog(@"property:%@ associatedObject:%@ obj1:%p obj2:%p obj3:%p", self.property.name, ass.name, self.obj1, self.obj2, self.obj3);
}

@end

@interface AssociatedObjectController ()

@end

@implementation AssociatedObjectController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"Main所有属性: %@", [self allProperties:[AssociatedObjectTestMain class]]);
    NSLog(@"Main所有方法: %@", [self allMethods:[AssociatedObjectTestMain class]]);

    [self test:@"test"
           setup:nil
        callback:^(UIButton *button) {
            AssociatedObjectTestMain *main = [[AssociatedObjectTestMain alloc] init];
            main.obj1 = [NSMutableArray array];
            main.obj2 = [UIViewController new];
            main.obj3 = [NSMutableArray array];

            AssociatedObjectTestOne *property = [[AssociatedObjectTestOne alloc] init];
            property.name = @"property";
            property.main_weak = main;
            property.main_assign = main;
            main.property = property;

            AssociatedObjectTestOne *associatedObject = [[AssociatedObjectTestOne alloc] init];
            associatedObject.name = @"associatedObject";
            associatedObject.main_weak = main;
            associatedObject.main_assign = main;
            objc_setAssociatedObject(main, @selector(title), associatedObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }];
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
