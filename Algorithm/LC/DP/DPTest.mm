//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "DPTest.h"

// 2020 背包
static void beibao_dfs(vector<int> &all, int cur, vector<int> &cur_result, int index)
{
    if (cur < 0) {
        return;
    }
    if (cur == 0) {
        for (int i = 0; i < cur_result.size(); ++i) {
            cout << cur_result[i] << " ";
        }
        cout << endl;
        return;
    }
    for (int i = index; i < all.size(); ++i) {
        if (cur - all[i] >= 0) {
            vector<int> next(cur_result);
            next.push_back(all[i]);
            beibao_dfs(all, cur - all[i], next, i);
        }
    }
}

static void beibao_dp(vector<int> &all, vector<vector<bool>> &choice, int cur, vector<int> &cur_result, int index)
{
    if (cur < 0) {
        return;
    }
    if (cur == 0) {
        for (int i = 0; i < cur_result.size(); ++i) {
            cout << cur_result[i] << " ";
        }
        cout << endl;
        return;
    }
    for (int i = 0; i < all.size(); ++i) {
        if (choice[i + 1][cur] && cur - all[i] >= 0) {
            vector<int> next(cur_result);
            next.push_back(all[i]);
            beibao_dp(all, choice, cur - all[i], next, i);
        }
    }
}

@implementation DPTest

+ (void)run
{
    vector<int> v0 = {5, 10, 53, 62, 63, 64, 72, 91};
    vector<int> v1 = {120, 121, 122, 123, 139, 152, 188, 198, 213, 221, 264, 279, 300, 309, 322, 338, 343, 416, 486};
    vector<int> v2 = {516, 523, 576, 646, 647, 650, 673, 688, 698, 712, 714, 718, 740, 746, 790, 813, 837, 877, 983};
    vector<int> v3 = {1024, 1025, 1027, 1039, 1048, 1049, 1139, 1143, 1186, 1218, 1277};
    
    vector<int> v;
    v.insert(v.end(), v0.begin(), v0.end());
    v.insert(v.end(), v1.begin(), v1.end());
    v.insert(v.end(), v2.begin(), v2.end());
    v.insert(v.end(), v3.begin(), v3.end());
    sort(v.begin(), v.end());
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
        vector<int> all = {31, 251, 404, 500, 965, 996, 1024};
        vector<int> temp_result;
        beibao_dfs(all, 2020, temp_result, 0);
        cout << endl;
    }
    {
        vector<int> all = {31, 251, 404, 500, 965, 996, 1024};
        vector<int> temp_result;
        int sum = 2020;
        vector<int> dp(sum + 1, -9999);
        dp[0] = 0;
        vector<vector<bool>> choice(sum + 1, vector<bool>(sum + 1, false));
        for (int i = 1; i <= all.size(); ++i) {
            int value = all[i - 1];
            // 这里与 0-1 背包有遍历顺序的差异
            for (int j = value; j <= sum; ++j) {
                if (dp[j - value] >= 0) {
                    // 为了记录一个选取数组，从而回溯 dp 路径
                    choice[i][j] = true;
                    dp[j] = max(dp[j], dp[j - value] + value);
                }
            }
        }
        beibao_dp(all, choice, sum, temp_result, 0);
        cout << endl;
    }
}

LC_CLASS_END
