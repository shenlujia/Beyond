//
//  LC0046.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0046.h"
#import <queue>
#import <set>
#import <unordered_map>
#import <vector>

using namespace std;

@implementation LC0046

/*
 全排列

 给定一个 没有重复 数字的序列，返回其所有可能的全排列。

 示例:

 输入: [1,2,3]
 输出:
 [
   [1,2,3],
   [1,3,2],
   [2,1,3],
   [2,3,1],
   [3,1,2],
   [3,2,1]
 ]
 */
static vector<vector<int>> permute(vector<int>& nums)
{
    vector<vector<int>> ret;
    vector<int> temp;
    vector<bool> visit(nums.size(), false);
    impl(ret, nums, temp, visit);
    return ret;
}

static void impl(vector<vector<int>> &ret, vector<int> &nums, vector<int> &current, vector<bool> &visit)
{
    if (nums.size() == current.size()) {
        ret.push_back(current);
        return;
    }
    for (int i = 0; i < nums.size(); ++i) {
        if (!visit[i]) {
            current.push_back(nums[i]);
            visit[i] = true;
            impl(ret, nums, current, visit);
            current.pop_back();
            visit[i] = false;
        }
    }
}

+ (void)run
{
    vector<int> input = {1,2,3};
    vector<vector<int>> ret = permute(input);
    NSParameterAssert(ret.size() == 6);
}

@end
