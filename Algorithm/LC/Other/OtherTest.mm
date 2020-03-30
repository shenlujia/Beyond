//
//  BinaryTreeTest.m
//  DSPro
//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "OtherTest.h"
#import <vector>

@implementation OtherTest

+ (void)run
{
    std::vector<int> v = {};

    for (int i = 0; i < v.size(); ++i) {
        int value = v[i];
        NSString *name = [NSString stringWithFormat:@"%04d", value];
        Class c = NSClassFromString([NSString stringWithFormat:@"LC%@", name]);
        printf("====== %s ======", name.UTF8String);
        NSParameterAssert(c);
        [c performSelector:@selector(run)];
        printf("\n\n");
    }
}

@end
