//
//  LC0055.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0055.h"
#import <unordered_map>
#import <vector>

using namespace std;

@implementation LC0055

/*
 跳跃游戏

 给定一个非负整数数组，你最初位于数组的第一个位置。

 数组中的每个元素代表你在该位置可以跳跃的最大长度。

 判断你是否能够到达最后一个位置。

 示例 1:

 输入: [2,3,1,1,4]
 输出: true
 解释: 我们可以先跳 1 步，从位置 0 到达 位置 1, 然后再从位置 1 跳 3 步到达最后一个位置。
 示例 2:

 输入: [3,2,1,0,4]
 输出: false
 解释: 无论怎样，你总会到达索引为 3 的位置。但该位置的最大跳跃长度是 0 ， 所以你永远不可能到达最后一个位置。
 */
static bool canJump(vector<int>& nums)
{
    int len = (int)nums.size();
    int farthest = 0;
    for (int i = 0; i < len - 1; ++i) {
        int go = i + nums[i];
        if (farthest < go) {
            farthest = go;
        }
        if (farthest <= i) {
            return false;
        }
    }
    return farthest >= len - 1;
}

+ (void)run
{
    {
        vector<int> input = {2,3,1,1,4};
        NSParameterAssert(canJump(input) == true);
    }
    {
        vector<int> input = {1,2,3};
        NSParameterAssert(canJump(input) == true);
    }
    {
        vector<int> input = {0,1};
        NSParameterAssert(canJump(input) == false);
    }
    {
        vector<int> input = {3,2,1,0,4};
        NSParameterAssert(canJump(input) == false);
    }
}

@end
