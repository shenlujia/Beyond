//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0153)

/*
 寻找旋转排序数组中的最小值

 假设按照升序排序的数组在预先未知的某个点上进行了旋转。

 ( 例如，数组 [0,1,2,4,5,6,7] 可能变为 [4,5,6,7,0,1,2] )。
 请找出其中最小的元素。
 你可以假设数组中不存在重复元素。
 示例 1:
 输入: [3,4,5,1,2]
 输出: 1
 示例 2:
 输入: [4,5,6,7,0,1,2]
 输出: 0
 */
static int findMin(vector<int>& nums)
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
    return nums[left];
}

+ (void)run
{
    vector<int> input0 = {7};
    vector<int> input1 = {6, 7};
    vector<int> input2 = {4, 5, 6, 7};
    vector<int> input3 = {4, 5, 6, 7, 0, 1, 2};
    vector<int> input4 = {3, 4, 5, 1, 2};
    vector<int> input5 = {4, 5, 6, 7, -1, 1, 2};
    NSParameterAssert(findMin(input0) == 7);
    NSParameterAssert(findMin(input1) == 6);
    NSParameterAssert(findMin(input2) == 4);
    NSParameterAssert(findMin(input3) == 0);
    NSParameterAssert(findMin(input4) == 1);
    NSParameterAssert(findMin(input5) == -1);
}

LC_CLASS_END
