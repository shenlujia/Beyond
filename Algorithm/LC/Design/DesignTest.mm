//
//  DesignTest.m
//  DSPro
//
//  Created by SLJ on 2020/1/16.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "DesignTest.h"
#import "WeakImpl.h"
#import <algorithm>
#import <iostream>
#import <objc/runtime.h>
#import <vector>

using namespace std;

@implementation DesignTest

- (void)once
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self otherOnce];
    });
    NSLog(@"遇到第一只熊猫宝宝...");
}

- (void)otherOnce
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self once];
    });
    NSLog(@"遇到第二只熊猫宝宝...");
}

+ (void)run
{
    vector<int> v = {146, 155, 232, 460, 622, 641, 706};
    for (int i = 0; i < v.size(); ++i) {
        int value = v[i];
        NSString *name = [NSString stringWithFormat:@"%04d", value];
        Class c = NSClassFromString([NSString stringWithFormat:@"LC%@", name]);
        printf("====== %s ======", name.UTF8String);
        NSParameterAssert(c);
        [c performSelector:@selector(run)];
        printf("\n\n");
    }

    [WeakImpl run];
}

@end
