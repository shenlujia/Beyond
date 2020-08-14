//
//  Person.m
//  HSKVO
//
//  Created by shenlujia on 2016/1/7.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>

@implementation Engine

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
}

@end

@implementation Car

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _engine = [[Engine alloc] init];
    }
    return self;
}

@end

@implementation Person

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _car = [[Car alloc] init];
        _userInfo = [NSMutableArray array];
    }
    return self;
}

@end
