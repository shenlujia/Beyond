//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0033)

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
static int search(vector<int>& nums, int target)
{
    int left = 0;
    int right = (int)nums.size() - 1;
    while (left <= right) {
        int mid = (left + right) / 2;
        if (nums[mid] == target) {
            return mid;
        }
        if (nums[mid] > nums[left]) {
            //说明左半部分是单调递增的7 8 9 0 1
            if (target >= nums[left] && target < nums[mid]) {//7 8
                right = mid - 1;
            }else{//0 1
                left = mid + 1;
            }
        }else if (nums[mid] < nums[left]) {
            //说明右半部分是单调递增的7 8 9 0 1 2 3 4 5
            if (target > nums[mid] && target <= nums[right]) { //2 3 4 5
                left = mid + 1;
            }else{//7 8 9 0
                right = mid - 1;
            }
        }else{
            //[3,1] target = 1 nums[mid] = 3 不是我们需要的，且left = mid = 0，所以left也不是，所以过滤left->left++
            left++;
        }
    }
    return -1;
}

static int search_easy(vector<int> &nums, int target)
{
    int len = (int)nums.size();
    if (len == 0) {
        return -1;
    }
    int start = find_original_start(nums);
    if (start == 0) {
        return index_of_value(nums, 0, len - 1, target);
    }
    if (nums[0] <= target) {
        return index_of_value(nums, 0, start - 1, target);
    } else {
        return index_of_value(nums, start, len - 1, target);
    }
}

static int index_of_value(vector<int> &nums, int left, int right, int target)
{
    int len = (int)nums.size();
    if (len == 0) {
        return -1;
    }

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

static int find_original_start(vector<int> &nums)
{
    int left = 0;
    int right = (int)nums.size() - 1;
    while (left < right) {
        int mid = left + (right - left) / 2;
        if (nums[mid] > nums[right]) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    return left;
}

+ (void)run
{
    {
        vector<int> input0 = {7};
        vector<int> input1 = {6, 7};
        vector<int> input2 = {4, 5, 6, 7};
        vector<int> input3 = {4, 5, 6, 7, 0, 1, 2};
        NSParameterAssert(find_original_start(input0) == 0);
        NSParameterAssert(find_original_start(input1) == 0);
        NSParameterAssert(find_original_start(input2) == 0);
        NSParameterAssert(find_original_start(input3) == 4);
    }
    {
        vector<int> input = {3, 1};
        NSParameterAssert(search(input, 3) == 0);
        NSParameterAssert(search_easy(input, 3) == 0);
    }
    {
        vector<int> input = {1, 3};
        NSParameterAssert(search(input, 1) == 0);
        NSParameterAssert(search_easy(input, 1) == 0);
    }
    {
        vector<int> input = {4, 5, 6, 7, 0, 1, 2};
        NSParameterAssert(search(input, 0) == 4);
        NSParameterAssert(search_easy(input, 0) == 4);
    }
    {
        vector<int> input = {4, 5, 6, 7, 0, 1, 2};
        NSParameterAssert(search(input, 3) == -1);
        NSParameterAssert(search_easy(input, 3) == -1);
    }
}

LC_CLASS_END
