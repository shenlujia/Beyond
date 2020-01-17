//
//  DesignTest.m
//  DSPro
//
//  Created by SLJ on 2020/1/16.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "DesignTest.h"
#import <vector>

using namespace std;

@implementation DesignTest

+ (void)run
{
    vector<int> v = {146, 155, 460, 622, 641, 706};

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
