//
//  BacktrackTest.m
//  DSPro
//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "BacktrackTest.h"
#import <iostream>
#import <vector>

using namespace std;

// 全排列
static void quanpailie_backtrack_vector(vector<int> &all, vector<int> &cur_result, vector<bool> &visit)
{
    int len = (int)all.size();
    if (cur_result.size() == len) {
        cout << "{";
        for (int i = 0; i < cur_result.size(); ++i) {
            cout << cur_result[i];
            if (i + 1 != cur_result.size()) {
                cout << ",";
            }
        }
        cout << "} ";
        return;
    }

    for (int i = 0; i < len; ++i) {
        if (!visit[i]) {
            int value = all[i];
            visit[i] = true;
            cur_result.push_back(value);
            quanpailie_backtrack_vector(all, cur_result, visit);
            cur_result.pop_back();
            visit[i] = false;
        }
    }
}

@implementation BacktrackTest

+ (void)run
{
    vector<int> v = {37, 78};

    for (int i = 0; i < v.size(); ++i) {
        int value = v[i];
        NSString *name = [NSString stringWithFormat:@"%04d", value];
        Class c = NSClassFromString([NSString stringWithFormat:@"LC%@", name]);
        printf("====== %s ======", name.UTF8String);
        NSParameterAssert(c);
        [c performSelector:@selector(run)];
        printf("\n\n");
    }

    {
        vector<int> all = {1, 3, 2};
        reverse(all.begin(), all.end());
        vector<bool> visit(all.size(), false);
        vector<int> temp_result;
        quanpailie_backtrack_vector(all, temp_result, visit);

        cout << endl << endl;
    }
}

@end
