//
//  DesignTest.m
//  DSPro
//
//  Created by SLJ on 2020/1/16.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "DesignTest.h"
#import <algorithm>
#import <iostream>
#import <vector>

using namespace std;

@implementation DesignTest

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
}

@end

// 背包 beibao
// void dfs(int cur, vector<int> cur_res, int index) {
//    if (cur == 0) {
//        for (int i = 0; i < cur_res.size(); ++ i) {
//            cout << cur_res[i] << " ";
//        }
//        cout << endl;
//        return;
//    }
//    if (cur < 0) return;
//    for (int i = index; i < w.size(); ++ i) {
//        if (cur - w[i] >= 0) {
//            vector<int> nxt(cur_res);
//            nxt.push_back(w[i]);
//            dfs(cur - w[i], nxt, i);
//        }
//    }
//}
