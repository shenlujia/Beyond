//
//  LC0053.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0053.h"
#import <math.h>
#import <string>
#import <vector>

using namespace std;

@implementation LC0053

/*
 最大子序和

 给定一个整数数组 nums ，找到一个具有最大和的连续子数组（子数组最少包含一个元素），返回其最大和。

 示例:

 输入: [-2,1,-3,4,-1,2,1,-5,4],
 输出: 6
 解释: 连续子数组 [4,-1,2,1] 的和最大，为 6。
 进阶:

 如果你已经实现复杂度为 O(n) 的解法，尝试使用更为精妙的分治法求解。
 */

static int maxSubArray(vector<int>& nums)
{
    int len = (int)nums.size();
    if (len == 0) {
        return 0;
    }
    vector<int> dp(nums);
    int ret = dp[0];
    for (int i = 1; i < len; ++i) {
        if (dp[i - 1] > 0) {
            dp[i] += dp[i - 1];
        }
        ret = max(ret, dp[i]);
    }
    return ret;
}

+ (void)run
{
    {
        vector<int> v = {-2,1,-3,4,-1,2,1,-5,4};
        NSParameterAssert(maxSubArray(v) == 6);
    }
}

@end
