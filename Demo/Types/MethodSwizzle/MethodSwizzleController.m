//
//  MethodSwizzleController.m
//  Beyond
//
//  Created by ZZZ on 2024/3/8.
//  Copyright © 2024 SLJ. All rights reserved.
//

#import "MethodSwizzleController.h"
#import "SSEasy.h"

#pragma mark - original

@interface MethodSwizzleTestAAA : NSObject

@end

@implementation MethodSwizzleTestAAA

- (void)funcAAA
{
    ss_easy_log(@"aaa funcAAA");
}

@end

@interface MethodSwizzleTestMain : NSObject

@property (nonatomic, strong, readonly) MethodSwizzleTestAAA *aaa;

@end

@implementation MethodSwizzleTestMain

- (void)dealloc
{
    
}

- (instancetype)init
{
    self = [super init];
    _aaa = [[MethodSwizzleTestAAA alloc] init];
    return self;
}

@end

#pragma mark - fake

@interface MethodSwizzleTestSubServiceFake : NSProxy

@property (nonatomic, copy) NSString *name;

@end

@implementation MethodSwizzleTestSubServiceFake

- (void)dealloc
{
    
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    ss_easy_log(@"fake: %@ %@", self.name, NSStringFromSelector(invocation.selector));
}

- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}

+ (BOOL)respondsToSelector:(SEL)aSelector
{
    return YES;
}

@end

@interface MethodSwizzleTestMainFake : NSObject

@property (nonatomic, strong) NSMutableDictionary *map;

@end

@implementation MethodSwizzleTestMainFake

static id getSubService(MethodSwizzleTestMainFake *fake, SEL selector) {
    NSString *name = NSStringFromSelector(selector);
    if (!name) {
        return nil;
    }
    id obj = fake.map[name];
    if (!obj) {
        MethodSwizzleTestSubServiceFake *ss = [MethodSwizzleTestSubServiceFake alloc];
        ss.name = name;
        fake.map[name] = ss;
        obj = ss;
    }
    return obj;
}

- (void)dealloc
{
    
}

- (instancetype)init
{
    self = [super init];
    _map = [NSMutableDictionary dictionary];
    return self;
}

- (id)get_method_types
{
    // do nothings
    return nil;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    Method method = class_getInstanceMethod([self class], @selector(get_method_types));
    class_addMethod([self class], sel, (IMP)getSubService, method_getTypeEncoding(method));
    return YES;
}

+ (BOOL)respondsToSelector:(SEL)aSelector
{
    return YES;
}

@end

#pragma mark - cases

@interface MethodSwizzleController ()

@property (nonatomic, strong) MethodSwizzleTestMain *main;
@property (nonatomic, strong) MethodSwizzleTestMainFake *fake;

@end

@implementation MethodSwizzleController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MethodSwizzleTestMain *main = [[MethodSwizzleTestMain alloc] init];
    self.main = main;
    MethodSwizzleTestMainFake *fake = [[MethodSwizzleTestMainFake alloc] init];
    self.fake = fake;
    
    [self test:@"main.aaa.func" tap:^(UIButton *button, NSDictionary *userInfo) {
        [main.aaa funcAAA];
    }];
    
    [self test:@"fake main.aaa.func" tap:^(UIButton *button, NSDictionary *userInfo) {
        MethodSwizzleTestMain *main = (id)fake;
        [main.aaa funcAAA];
    }];
}

@end
