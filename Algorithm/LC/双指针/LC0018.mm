//
//  LC0018.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0018.h"
#import <string>
#import <vector>

using namespace std;

@implementation LC0018

/*
 四数之和

 给定一个包含 n 个整数的数组 nums 和一个目标值 target，判断 nums 中是否存在四个元素 a，b，c 和 d ，使得 a + b + c + d 的值与 target
 相等？找出所有满足条件且不重复的四元组。

 注意：

 答案中不可以包含重复的四元组。

 示例：

 给定数组 nums = [1, 0, -1, 0, -2, 2]，和 target = 0。

 满足要求的四元组集合为：
 [
   [-1,  0, 0, 1],
   [-2, -1, 1, 2],
   [-2,  0, 0, 2]
 ]
 */
static vector<vector<int>> fourSum(vector<int> &nums, int target)
{
    vector<vector<int>> ret;
    sort(nums.begin(), nums.end());
    int len = (int)nums.size();
    for (int m = 0; m < len; ++m) {
        if (m > 0 && nums[m] == nums[m - 1]) {
            continue;
        }
        if (nums[m] * 4 > target) { // 最小的数大于target/4 跳过
            break;
        }
        for (int n = m + 1; n < len; ++n) {
            if (n > m + 1 && nums[n] == nums[n - 1]) {
                continue;
            }
            int left = n + 1;
            int right = len - 1;
            while (left < right) {
                if (nums[right] * 4 < target) { // 最大的数小于target/4 跳过
                    break;
                }
                int sum = nums[m] + nums[n] + nums[left] + nums[right];
                if (sum < target) {
                    ++left;
                } else if (sum > target) {
                    --right;
                } else {
                    ret.push_back({nums[m], nums[n], nums[left], nums[right]});
                    while (left < right && nums[left] == nums[left + 1]) {
                        ++left;
                    }
                    while (left < right && nums[right] == nums[right - 1]) {
                        --right;
                    }
                    ++left;
                    --right;
                }
            }
        }
    }
    return ret;
}

+ (void)run
{
    {
        vector<int> v = {1, 0, -1, 0, -2, 2};
        vector<vector<int>> ret = fourSum(v, 0);
        NSParameterAssert(ret.size() == 3);
    }
    {
        vector<int> v = {0, 0, 0, 0};
        vector<vector<int>> ret = fourSum(v, 0);
        NSParameterAssert(ret.size() == 1);
    }
}

@end
