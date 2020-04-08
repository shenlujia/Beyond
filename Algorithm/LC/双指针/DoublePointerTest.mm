//
//  DoublePointerTest.m
//  DSPro
//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "DoublePointerTest.h"
#import <vector>

/*
 滑动窗口套路：
 int left = 0, right = 0;
 while (right < s.size()) {
     window.add(s[right]);
     right++;

     while (valid) {
         window.remove(s[left]);
         left++;
     }
 }
 */

@implementation DoublePointerTest

+ (void)run
{
    std::vector<int> v = {3, 11, 16, 18, 30, 76};

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
