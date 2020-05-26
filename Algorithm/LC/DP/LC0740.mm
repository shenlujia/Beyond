//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0740)

/*
 删除与获得点数
 给定一个整数数组 nums ，你可以对它进行一些操作。
 每次操作中，选择任意一个 nums[i] ，删除它并获得 nums[i] 的点数。之后，你必须删除每个等于 nums[i] - 1 或 nums[i] + 1 的元素。
 开始你拥有 0 个点数。返回你能通过这些操作获得的最大点数。
 示例 1:
 输入: nums = [3, 4, 2]
 输出: 6
 解释:
 删除 4 来获得 4 个点数，因此 3 也被删除。
 之后，删除 2 来获得 2 个点数。总共获得 6 个点数。
 示例 2:
 输入: nums = [2, 2, 3, 3, 3, 4]
 输出: 9
 解释:
 删除 3 来获得 3 个点数，接着要删除两个 2 和 4 。
 之后，再次删除 3 获得 3 个点数，再次删除 3 获得 3 个点数。
 总共获得 9 个点数。
 注意:
 nums的长度最大为20000。
 每个整数nums[i]的大小都在[1, 10000]范围内。
 */
static int deleteAndEarn(vector<int>& nums)
{
    map<int, int> m_map;
    for (int i = 0; i < nums.size(); ++i) {
        int value = nums[i];
        ++m_map[value];
    }
    
    vector<int> dp(10001, 0);
    for (auto it : m_map) {
        dp[it.first] = it.first * it.second;
    }
    
    int len = (int)dp.size();
    int ret = max(dp[0], dp[1]);
    for (int i = 2; i < len; ++i) {
        if (dp[i] == 0) {
            dp[i] = dp[i - 1];
            continue;
        }
        dp[i] = max(dp[i - 1], dp[i - 2] + dp[i]);
        ret = max(ret, dp[i]);
    }
    return ret;
}

+ (void)run
{
    {
        vector<int> v = {1, 1, 1, 2, 4, 5, 5, 5, 6};
        NSCParameterAssert(deleteAndEarn(v) == 18);
    }
    {
        vector<int> v = {3, 4, 2};
        NSCParameterAssert(deleteAndEarn(v) == 6);
    }
    {
        vector<int> v = {2, 2, 3, 3, 3, 4};
        NSCParameterAssert(deleteAndEarn(v) == 9);
    }
}

LC_CLASS_END
