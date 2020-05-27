//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(1218)

/*
 最长定差子序列
 给你一个整数数组 arr 和一个整数 difference，请你找出 arr 中所有相邻元素之间的差等于给定 difference 的等差子序列，并返回其中最长的等差子序列的长度。

 示例 1：
 输入：arr = [1,2,3,4], difference = 1
 输出：4
 解释：最长的等差子序列是 [1,2,3,4]。
 示例 2：
 输入：arr = [1,3,5,7], difference = 1
 输出：1
 解释：最长的等差子序列是任意单个元素。
 示例 3：
 输入：arr = [1,5,7,8,5,3,4,2,1], difference = -2
 输出：4
 解释：最长的等差子序列是 [7,5,3,1]。
  
 提示：
 1 <= arr.length <= 10^5
 -10^4 <= arr[i], difference <= 10^4
 */
static int longestSubsequence(vector<int>& arr, int difference)
{
    int ret = 1;
    int len = (int)arr.size();
    vector<int> dp(len, 1);
    unordered_map<int, int> m_map;
    for (int i = 0; i < len; ++i) {
        int value = arr[i];
        int previous = value - difference;
        if (m_map.find(previous) != m_map.end()) {
            dp[i] = dp[m_map[previous]] + 1;
            ret = max(ret, dp[i]);
        }
        m_map[value] = i;
    }
    return ret;
}

+ (void)run
{
    {
        vector<int> v = {1, 5, 7, 8, 5, 3, 4, 2, 1};
        NSCParameterAssert(longestSubsequence(v, -2) == 4);
    }
    {
        vector<int> v = {1, 2, 3, 4};
        NSCParameterAssert(longestSubsequence(v, 1) == 4);
    }
}

LC_CLASS_END
