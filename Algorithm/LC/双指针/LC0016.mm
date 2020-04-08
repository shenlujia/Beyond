//
//  LC0016.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0016.h"
#import <string>
#import <vector>

using namespace std;

@implementation LC0016

/*
 最接近的三数之和

 给定一个包括 n 个整数的数组 nums 和 一个目标值 target。找出 nums 中的三个整数，使得它们的和与 target 最接近。返回这三个数的和。假定每组输入只存在唯一答案。

 例如，给定数组 nums = [-1，2，1，-4], 和 target = 1.

 与 target 最接近的三个数的和为 2. (-1 + 2 + 1 = 2).
 */
static int threeSumClosest(vector<int> &nums, int target)
{
    int len = (int)nums.size();
    if (len <= 2) {
        return 0;
    }

    sort(nums.begin(), nums.end());

    int ret = INT_MAX;

    for (int i = 0; i < len; ++i) {
        int left = i + 1;
        int right = len - 1;
        while (left < right) {
            int temp_sum = nums[i] + nums[left] + nums[right];
            if (ret == INT_MAX) {
                ret = temp_sum;
            }
            if (abs(temp_sum - target) < abs(ret - target)) {
                ret = temp_sum;
            }
            if (ret == target) {
                return ret;
            }
            if (temp_sum < target) {
                left++;
            } else {
                right--;
            }
        }
    }

    return ret;
}

+ (void)run
{
    vector<int> v = {-1, 2, 1, -4};
    NSParameterAssert(threeSumClosest(v, 1) == 2);
}

@end
