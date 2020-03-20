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
    subsets_impl(ret, nums, 0);
    return ret;
}

static void subsets_impl(vector<vector<int>> &ret, vector<int> &nums, int index)
{
    if (index > nums.size()) {
        return;
    }
    if (index == nums.size()) {
        ret.push_back(vector<int>());
        return;
    }
    int value = nums[index];
    subsets_impl(ret, nums, index + 1);
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
    printf("%lu\n", subsets(v).size());
}

@end
