//
//  LC0047.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0047.h"
#import <queue>
#import <set>
#import <unordered_map>
#import <vector>

using namespace std;

@implementation LC0047

/*
 全排列 II

 给定一个可包含重复数字的序列，返回所有不重复的全排列。

 示例:

 输入: [1,1,2]
 输出:
 [
   [1,1,2],
   [1,2,1],
   [2,1,1]
 ]
 */
static vector<vector<int>> permuteUnique(vector<int> &nums)
{
    sort(nums.begin(), nums.end());

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
            if (i >= 1 && !visit[i - 1] && nums[i] == nums[i - 1]) {
                continue;
            }
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
    vector<int> input = {1, 2, 2, 2};
    vector<vector<int>> ret = permuteUnique(input);
    NSParameterAssert(ret.size() == 4);
}

@end
