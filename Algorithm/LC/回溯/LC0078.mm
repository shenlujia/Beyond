//
//  LC0078.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0078.h"
#import <vector>

using namespace std;

@implementation LC0078

/*
 子集
 给定一组不含重复元素的整数数组 nums，返回该数组所有可能的子集（幂集）。

 说明：解集不能包含重复的子集。

 示例:

 输入: nums = [1,2,3]
 输出:
 [
   [3],
   [1],
   [2],
   [1,2,3],
   [1,3],
   [2,3],
   [1,2],
   []
 ]
 */
static vector<vector<int>> subsets(vector<int> &nums)
{
    vector<vector<int>> ret;
    vector<int> temp;
    subsets_impl(ret, nums, temp, (int)nums.size());
    return ret;
}

static void subsets_impl(vector<vector<int>> &ret, vector<int> &nums, vector<int> &temp_result, int depth)
{
    if (depth <= 0) {
        ret.push_back(temp_result);
        return;
    }
    int value = nums[depth - 1];
    temp_result.push_back(value);
    subsets_impl(ret, nums, temp_result, depth - 1); // 情况一：集合中有该元素
    temp_result.pop_back();
    subsets_impl(ret, nums, temp_result, depth - 1); // 情况二：集合中无该元素
}

static vector<vector<int>> subsets_digui(vector<int> &nums)
{
    vector<vector<int>> ret;
    subsets_digui_impl(ret, nums, 0);
    return ret;
}

static void subsets_digui_impl(vector<vector<int>> &ret, vector<int> &nums, int index)
{
    if (index > nums.size()) {
        return;
    }
    if (index == nums.size()) {
        ret.push_back(vector<int>());
        return;
    }
    int value = nums[index];
    subsets_digui_impl(ret, nums, index + 1);
    size_t total = ret.size();
    for (size_t i = 0; i < total; ++i) {
        vector<int> v = ret[i];
        v.push_back(value);
        ret.push_back(v);
    }
}

+ (void)run
{
    vector<int> v = {1, 2, 3};
    vector<vector<int>> ret1 = subsets(v);
    vector<vector<int>> ret2 = subsets_digui(v);
    sort(ret1.begin(), ret1.end());
    sort(ret2.begin(), ret2.end());
    NSParameterAssert(ret1.size() == 8 && ret1 == ret2);
}

@end
