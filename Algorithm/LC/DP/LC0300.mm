//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0300)

/*
 最长上升子序列
 给定一个无序的整数数组，找到其中最长上升子序列的长度。
 示例:
 输入: [10,9,2,5,3,7,101,18]
 输出: 4
 解释: 最长的上升子序列是 [2,3,7,101]，它的长度是 4。
 说明:
 可能会有多种最长上升子序列的组合，你只需要输出对应的长度即可。
 你算法的时间复杂度应该为 O(n2) 。
 进阶: 你能将算法的时间复杂度降低到 O(n log n) 吗?
 */

static int lengthOfLIS(vector<int>& nums)
{
    int len = (int)nums.size();
    if (len <= 1) {
        return len;
    }
    vector<int> dp(len, 1);
    int ret = 1;
    for (int i = 1; i < len; ++i) {
        for (int j = 0; j < i; ++j) {
            if (nums[i] > nums[j]) {
                dp[i] = max(dp[i], dp[j] + 1);
                ret = max(ret, dp[i]);
            }
        }
    }
    return ret;
}

static int lengthOfLIS_binary(vector<int>& nums)
{
    int len = (int)nums.size();
    if (len <= 1) {
        return len;
    }
    vector<int> up;
    up.push_back(nums[0]);
    for (int i = 1; i < len; ++i) {
        if (nums[i] > up.back()) {
            up.push_back(nums[i]);
        } else {
            auto it = lower_bound(up.begin(), up.end(), nums[i]);
            *it = nums[i];
        }
    }
    return (int)up.size();
}

+ (void)run
{
    {
        vector<int> v = {10, 9, 2, 5, 3, 7, 101, 18};
        NSCParameterAssert(lengthOfLIS(v) == 4);
        NSCParameterAssert(lengthOfLIS_binary(v) == 4);
    }
}

LC_CLASS_END
