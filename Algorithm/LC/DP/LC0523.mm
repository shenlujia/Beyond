//
//  LC0523.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0523.h"
#import <string>
#import <vector>
#import <unordered_map>

using namespace std;

@implementation LC0523

/*
 连续的子数组和

 给定一个包含非负数的数组和一个目标整数 k，编写一个函数来判断该数组是否含有连续的子数组，其大小至少为 2，总和为 k 的倍数，即总和为 n*k，其中 n 也是一个整数。

 示例 1:
 输入: [23,2,4,6,7], k = 6
 输出: True
 解释: [2,4] 是一个大小为 2 的子数组，并且和为 6。
 
 示例 2:
 输入: [23,2,6,4,7], k = 6
 输出: True
 解释: [23,2,6,4,7]是大小为 5 的子数组，并且和为 42。
 说明:

 数组的长度不会超过10,000。
 你可以认为所有数字总和在 32 位有符号整数范围内。
 */
static bool checkSubarraySum(vector<int>& nums, int k)
{
    // 时间复杂度O(n2) 空间复杂度O(n)
    int len = (int)nums.size();
    vector<int> sum(len, 0);
    for (int i = 0; i < len; ++i) {
        if (i == 0) {
            sum[i] = nums[i];
        } else {
            sum[i] = sum[i - 1] + nums[i];
        }
    }
    for (int i = 0; i < len - 1; ++i) {
        for (int j = i + 1; j < len; ++j) {
            int current = sum[j] - sum[i] + nums[i];
            if (k == 0) {
                if (current == 0) {
                    return true;
                }
            } else {
                if (current % k == 0) {
                    return true;
                }
            }
        }
    }
    return false;
}

+ (void)run
{
    {
        vector<int> v = {23, 2, 4, 6, 7};
        NSParameterAssert(checkSubarraySum(v, 6) == true);
    }
    {
        vector<int> v = {23, 2, 6, 4, 7};
        NSParameterAssert(checkSubarraySum(v, 6) == true);
    }
    {
        vector<int> v = {0, 0};
        NSParameterAssert(checkSubarraySum(v, 0) == true);
    }
    {
        vector<int> v = {2, 4, 3};
        NSParameterAssert(checkSubarraySum(v, -6) == true);
    }
}

@end
