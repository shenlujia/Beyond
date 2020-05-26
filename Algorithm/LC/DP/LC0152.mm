//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0152)

/*
 乘积最大子数组

 给你一个整数数组 nums ，请你找出数组中乘积最大的连续子数组（该子数组中至少包含一个数字），并返回该子数组所对应的乘积。
 示例 1:
 输入: [2,3,-2,4]
 输出: 6
 解释: 子数组 [2,3] 有最大乘积 6。
 示例 2:
 输入: [-2,0,-1]
 输出: 0
 解释: 结果不能为 2, 因为 [-2,-1] 不是子数组。
 */

static int maxProduct(vector<int>& nums)
{
    int len = (int)nums.size();
    if (len == 0) {
        return 0;
    }
    vector<int> dp_min(nums);
    vector<int> dp_max(nums);
    for (int i = 1; i < len; ++i) {
        int temp0 = dp_min[i - 1] * nums[i];
        int temp1 = dp_max[i - 1] * nums[i];
        dp_min[i] = min(dp_min[i], min(temp0, temp1));
        dp_max[i] = max(dp_max[i], max(temp0, temp1));
    }
    return *max_element(dp_max.begin(), dp_max.end());
}

+ (void)run
{
    {
        vector<int> v = {2, 3, -2, 4};
        NSParameterAssert(maxProduct(v) == 6);
    }
    {
        vector<int> v = {-2, 0, -1};
        NSParameterAssert(maxProduct(v) == 0);
    }
}

LC_CLASS_END
