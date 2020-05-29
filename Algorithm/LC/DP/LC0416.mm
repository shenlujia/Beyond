//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0416)

/*
 分割等和子集
 给定一个只包含正整数的非空数组。是否可以将这个数组分割成两个子集，使得两个子集的元素和相等。
 注意:
 每个数组中的元素不会超过 100
 数组的大小不会超过 200
 示例 1:
 输入: [1, 5, 11, 5]
 输出: true
 解释: 数组可以分割成 [1, 5, 5] 和 [11].
 示例 2:
 输入: [1, 2, 3, 5]
 输出: false
 解释: 数组不能分割成两个元素和相等的子集.
 */

static bool canPartition_dp(vector<int>& nums)
{
    int len = (int)nums.size();
    int sum = accumulate(nums.begin(), nums.end(), 0);
    if (sum % 2) {
        return false;
    }
    int target = sum / 2;
    vector<vector<bool>> dp(len + 1, vector<bool>(target + 1, false));
    for (int i = 0; i <= len; ++i) {
        dp[i][0] = true;
    }
    for (int i = 1; i <= len; ++i) {
        int value = nums[i - 1];
        for (int j = 1; j <= target; ++j) {
            if (j < value) {
                dp[i][j] = dp[i - 1][j];
            } else {
                dp[i][j] = dp[i - 1][j] || dp[i - 1][j - value];
            }
        }
    }
    return dp[len][target];
}

static bool canPartition_dfs(vector<int>& nums) // 超时
{
    int sum = accumulate(nums.begin(), nums.end(), 0);
    if (sum % 2) {
        return false;
    }
    int target = sum / 2;
    return dfs_impl(nums, target, 0);
}

static bool dfs_impl(vector<int>& nums, int target, int i)
{
    if (target < 0 || i == nums.size()) {
        return false;
    }
    if (target == 0) {
        return true;
    }
    return dfs_impl(nums, target - nums[i], i + 1) || dfs_impl(nums, target, i + 1);
}

+ (void)run
{
    {
        vector<int> v = {1, 5, 11, 5};
        NSCParameterAssert(canPartition_dp(v) == true);
        NSCParameterAssert(canPartition_dfs(v) == true);
    }
    {
        vector<int> v = {1, 2, 3, 5};
        NSCParameterAssert(canPartition_dp(v) == false);
        NSCParameterAssert(canPartition_dfs(v) == false);
    }
}

LC_CLASS_END
