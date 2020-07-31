//
//  BinarySearchTest.m
//  DSPro
//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "BinarySearchTest.h"
#import <iostream>
#import <vector>

using namespace std;

/*
 寻找一个数（基本的二分搜索）
 因为我们初始化 right = nums.length - 1 所以决定了我们的「搜索区间」是 [left, right] 所以决定了 while (left <= right)
 同时也决定了 left = mid+1 和 right = mid-1
 因为我们只需找到一个 target 的索引即可 所以当 nums[mid] == target 时可以立即返回
 */
static int binarySearch(vector<int> nums, int target)
{
    int len = (int)nums.size();
    if (len == 0) {
        return -1;
    }

    int left = 0;
    int right = len - 1; // 注意

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

/*
 寻找左侧边界的二分搜索
 因为我们初始化 right = nums.length 所以决定了我们的「搜索区间」是 [left, right) 所以决定了 while (left < right)
 同时也决定了 left = mid+1 和 right = mid
 因为我们需找到 target 的最左侧索引 所以当 nums[mid] == target 时不要立即返回 而要收紧右侧边界以锁定左侧边界
 */
static int left_bound(vector<int> nums, int target)
{
    int len = (int)nums.size();
    if (len == 0) {
        return -1;
    }

    int left = 0;
    int right = len; // 注意

    while (left < right) { // 注意
        int mid = (left + right) / 2;
        if (nums[mid] == target) {
            right = mid;
        } else if (nums[mid] < target) {
            left = mid + 1;
        } else if (nums[mid] > target) {
            right = mid; // 注意
        }
    }
    return left < len ? left : -1;
}

/*
 寻找右侧边界的二分搜索
 因为我们初始化 right = nums.length 所以决定了我们的「搜索区间」是 [left, right) 所以决定了 while (left < right)
 同时也决定了 left = mid+1 和 right = mid
 因为我们需找到 target 的最右侧索引 所以当 nums[mid] == target 时不要立即返回 而要收紧左侧边界以锁定右侧边界
 又因为收紧左侧边界时必须 left = mid + 1 所以最后无论返回 left 还是 right，必须减一
 */
static int right_bound(vector<int> nums, int target)
{
    int len = (int)nums.size();
    if (len == 0) {
        return -1;
    }

    int left = 0;
    int right = len;

    while (left < right) {
        int mid = (left + right) / 2;
        if (nums[mid] == target) {
            left = mid + 1; // 注意
        } else if (nums[mid] < target) {
            left = mid + 1;
        } else if (nums[mid] > target) {
            right = mid;
        }
    }
    return left < len ? left - 1 : -1; // 注意
}

@implementation BinarySearchTest

+ (void)run
{
    vector<int> v = {33, 69, 153};

    for (int i = 0; i < v.size(); ++i) {
        int value = v[i];
        NSString *name = [NSString stringWithFormat:@"%04d", value];
        Class c = NSClassFromString([NSString stringWithFormat:@"LC%@", name]);
        printf("====== %s ======", name.UTF8String);
        NSParameterAssert(c);
        [c performSelector:@selector(run)];
        printf("\n\n");
    }

    vector<int> nums = {1, 2, 2, 2, 3, 4, 5, 5, 6};
    NSParameterAssert(binarySearch(nums, 7) == -1);
    NSParameterAssert(left_bound(nums, 7) == -1);
    NSParameterAssert(right_bound(nums, 7) == -1);
    NSParameterAssert(binarySearch(nums, 2) == 1);
    NSParameterAssert(left_bound(nums, 2) == 1);
    NSParameterAssert(right_bound(nums, 2) == 3);
}

@end
