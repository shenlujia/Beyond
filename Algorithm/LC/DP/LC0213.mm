//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0213)

/*
 打家劫舍 II
 你是一个专业的小偷，计划偷窃沿街的房屋，每间房内都藏有一定的现金。这个地方所有的房屋都围成一圈，这意味着第一个房屋和最后一个房屋是紧挨着的。同时，相邻的房屋装有相互连通的防盗系统，如果两间相邻的房屋在同一晚上被小偷闯入，系统会自动报警。

 给定一个代表每个房屋存放金额的非负整数数组，计算你在不触动警报装置的情况下，能够偷窃到的最高金额。
 示例 1:
 输入: [2,3,2]
 输出: 3
 解释: 你不能先偷窃 1 号房屋（金额 = 2），然后偷窃 3 号房屋（金额 = 2）, 因为他们是相邻的。
 示例 2:
 输入: [1,2,3,1]
 输出: 4
 解释: 你可以先偷窃 1 号房屋（金额 = 1），然后偷窃 3 号房屋（金额 = 3）。
      偷窃到的最高金额 = 1 + 3 = 4 。
 */
static int rob(vector<int>& nums)
{
    if (nums.size() == 0) {
        return 0;
    }
    if (nums.size() == 1) {
        return nums[1];
    }
    vector<int> no_first(nums.begin() + 1, nums.end());
    vector<int> no_last(nums.begin(), nums.end() - 1);
    return max(rob_impl(no_first), rob_impl(no_last));
}

static int rob_impl(vector<int>& nums)
{
    int len = (int) nums.size();
    if (len == 0) {
        return 0;
    }
    if (len == 1) {
        return nums[0];
    }
    
    vector<int> dp(len, 0);
    dp[0] = nums[0];
    dp[1] = max(nums[0], nums[1]);
    for (int i = 2; i < len; ++i) {
        dp[i] = max(dp[i - 1], dp[i - 2] + nums[i]);
    }
    return dp[len - 1];
}

+ (void)run
{
    {
        vector<int> v = {2, 3, 2};
        NSCParameterAssert(rob(v) == 3);
    }
    {
        vector<int> v = {1, 2, 3, 1};
        NSCParameterAssert(rob(v) == 4);
    }
}

LC_CLASS_END
