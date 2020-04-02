//
//  LC0045.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0045.h"
#import <unordered_map>
#import <vector>

using namespace std;

@implementation LC0045

/*
 跳跃游戏 II

 给定一个非负整数数组，你最初位于数组的第一个位置。
 数组中的每个元素代表你在该位置可以跳跃的最大长度。
 你的目标是使用最少的跳跃次数到达数组的最后一个位置。

 示例:

 输入: [2,3,1,1,4]
 输出: 2
 解释: 跳到最后一个位置的最小跳跃数是 2。
      从下标为 0 跳到下标为 1 的位置，跳 1 步，然后跳 3 步到达数组的最后一个位置。
 说明:

 假设你总是可以到达数组的最后一个位置。
 */
static int jump_dp(vector<int>& nums)
{
    // 这题如果用常规动态规划会超时 需要剪枝才能过
    int len = (int)nums.size();
    if (len <= 1) {
        return 0;
    }
    vector<int> step(len, 99999999);
    step[0] = 0;
    for (int i = 0; i < len;) {
        int j_max = i + nums[i];
        int next_i = i + 1;
        int next_max = 0;
        for (int j = i + 1; j <= j_max && j < len; ++j) {
            int current_max = j + nums[j];
            if (current_max >= next_max) {
                next_i = j;
                next_max = current_max;
            }
            step[j] = min(step[j], step[i] + 1);
        }
        i = next_i;
    }
    return step[len - 1];
}

static int jump(vector<int>& nums)
{
    // 这题如果用常规动态规划会超时 需要剪枝才能过 剪枝优化后就是贪心了
    int ans = 0;
    int end = 0;
    int maxPos = 0;
    for (int i = 0; i < (int)nums.size() - 1; ++i)
    {
        maxPos = max(nums[i] + i, maxPos);
        if (i == end)
        {
            end = maxPos;
            ans++;
        }
    }
    return ans;
}

+ (void)run
{
    {
        vector<int> input = {2,3,1,1,4};
        NSParameterAssert(jump(input) == 2);
        NSParameterAssert(jump_dp(input) == 2);
    }
    {
        vector<int> input = {1,2,3};
        NSParameterAssert(jump(input) == 2);
        NSParameterAssert(jump_dp(input) == 2);
    }
}

@end
