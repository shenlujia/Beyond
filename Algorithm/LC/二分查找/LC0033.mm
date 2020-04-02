//
//  LC0033.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0033.h"
#import <vector>

using namespace std;

@implementation LC0033

/*
 搜索旋转排序数组

 假设按照升序排序的数组在预先未知的某个点上进行了旋转。

 ( 例如，数组 [0,1,2,4,5,6,7] 可能变为 [4,5,6,7,0,1,2] )。

 搜索一个给定的目标值，如果数组中存在这个目标值，则返回它的索引，否则返回 -1 。

 你可以假设数组中不存在重复的元素。

 你的算法时间复杂度必须是 O(log n) 级别。

 示例 1:

 输入: nums = [4,5,6,7,0,1,2], target = 0
 输出: 4
 示例 2:

 输入: nums = [4,5,6,7,0,1,2], target = 3
 输出: -1
 */
static int search(vector<int> &nums, int target)
{
    int len = (int)nums.size();
    if (len == 0) {
        return -1;
    }
    int max_index = index_of_max_in_nums(nums);
    if (nums[len - 1] > target) {
        if (max_index == len - 1) {
            max_index = -1;
        }
        return index_of_value_in_nums(nums, max_index + 1, len - 1, target);
    } else {
        return index_of_value_in_nums(nums, 0, max_index, target);
    }
}

static int index_of_value_in_nums(vector<int> &nums, int left, int right, int target)
{
    int len = (int)nums.size();
    if (len == 0) {
        return -1;
    }
    left = max(left, 0);
    left = min(left, len - 1);
    right = min(right, len - 1);

    while (left <= right) { // 注意
        int mid = (right + left) / 2;
        if (nums[mid] == target) {
            return mid;
        } else if (nums[mid] < target) {
            left = mid + 1; // 注意
        } else if (nums[mid] > target) {
            right = mid - 1; // 注意
        }
    }
    return -1;
}

static int find_rotate_index(vector<int> &nums)
{
    int len = (int)nums.size();
    if (len <= 1) {
        return 0;
    }
    if (nums[0] < nums[len - 1]) {
        return 0;
    }

    int left = 0;
    int right = len - 1;
    while (left <= right) {
        int mid = (left + right) / 2;
        if (mid == left) {
            return nums[mid] > nums[mid + 1] ? mid : (mid + 1);
        }
        if (mid == right) {
            return nums[mid] > nums[mid - 1] ? mid : (mid - 1);
        }
        if (nums[left] < nums[mid]) {
            left = mid;
        }
        if (nums[right] < nums[mid]) {
            right = mid;
        }
    }
    return -1;
}

+ (void)run
{
    {
        vector<int> input0 = {7};
        vector<int> input1 = {6, 7};
        vector<int> input2 = {4, 5, 6, 7};
        vector<int> input3 = {4, 5, 6, 7, 0, 1, 2};
        NSParameterAssert(index_of_max_in_nums(input0) == 0);
        NSParameterAssert(index_of_max_in_nums(input1) == 1);
        NSParameterAssert(index_of_max_in_nums(input2) == 3);
        NSParameterAssert(index_of_max_in_nums(input3) == 3);
    }
    {
        vector<int> input = {1, 3};
        NSParameterAssert(search(input, 1) == 0);
    }
    {
        vector<int> input = {4, 5, 6, 7, 0, 1, 2};
        NSParameterAssert(search(input, 0) == 4);
    }
    {
        vector<int> input = {4, 5, 6, 7, 0, 1, 2};
        NSParameterAssert(search(input, 3) == -1);
    }
}

@end
