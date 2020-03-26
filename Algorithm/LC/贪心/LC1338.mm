//
//  LC1338.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC1338.h"
#import <unordered_map>
#import <vector>

using namespace std;

@implementation LC1338

/*
 数组大小减半

 给你一个整数数组 arr。你可以从中选出一个整数集合，并删除这些整数在数组中的每次出现。

 返回 至少 能删除数组中的一半整数的整数集合的最小大小。



 示例 1：

 输入：arr = [3,3,3,3,5,5,5,2,2,7]
 输出：2
 解释：选择 {3,7} 使得结果数组为 [5,5,5,2,2]、长度为 5（原数组长度的一半）。
 大小为 2 的可行集合有 {3,5},{3,2},{5,2}。
 选择 {2,7} 是不可行的，它的结果数组为 [3,3,3,3,5,5,5]，新数组长度大于原数组的二分之一。
 示例 2：

 输入：arr = [7,7,7,7,7,7]
 输出：1
 解释：我们只能选择集合 {7}，结果数组为空。
 示例 3：

 输入：arr = [1,9]
 输出：1
 示例 4：

 输入：arr = [1000,1000,3,7]
 输出：1
 示例 5：

 输入：arr = [1,2,3,4,5,6,7,8,9,10]
 输出：5


 提示：

 1 <= arr.length <= 10^5
 arr.length 为偶数
 1 <= arr[i] <= 10^5
 */
static int minSetSize(vector<int> &arr)
{
    unordered_map<int, int> hash_map;
    for (auto i : arr) {
        if (hash_map.find(i) != hash_map.end()) {
            hash_map[i]++;
        } else {
            hash_map[i] = 1;
        }
    }

    vector<int> values;
    for (auto i : hash_map) {
        values.push_back(i.second);
    }
    sort(values.begin(), values.end());

    int total = 0;
    int count = 0;
    for (int i = (int)values.size() - 1; i >= 0; --i) {
        ++count;
        total += values[i];
        if (total * 2 >= arr.size()) {
            break;
        }
    }
    return count;
}

+ (void)run
{
    vector<int> codes = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int ret = minSetSize(codes);
    NSParameterAssert(ret == 5);
}

@end
