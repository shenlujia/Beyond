//
//  ListTest.m
//  DSPro
//
//  Created by SLJ on 2020/1/14.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ListTest.h"
#import "ListNode.h"

@implementation ListTest

+ (void)run
{
    vector<int> v = {2, 21, 61, 82, 83, 86, 92, 141, 142, 203, 206, 237, 328};

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
