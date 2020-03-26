//
//  LC0011.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0011.h"
#import <string>
#import <vector>

using namespace std;

@implementation LC0011

/*
 盛最多水的容器

 给你 n 个非负整数 a1，a2，...，an，每个数代表坐标中的一个点 (i, ai) 。在坐标内画 n 条垂直线，垂直线 i 的两个端点分别为 (i, ai) 和 (i,
 0)。找出其中的两条线，使得它们与 x 轴共同构成的容器可以容纳最多的水。

 说明：你不能倾斜容器，且 n 的值至少为 2。

 图中垂直线代表输入数组 [1,8,6,2,5,4,8,3,7]。在此情况下，容器能够容纳水（表示为蓝色部分）的最大值为 49。

 示例：

 输入：[1,8,6,2,5,4,8,3,7]
 输出：49
 */
static int maxArea(vector<int> &height)
{
    int ret = 0;
    int len = (int)height.size();
    int left = 0;
    int right = len - 1;
    while (left < right) {
        int area = (right - left) * min(height[left], height[right]);
        ret = max(ret, area);
        if (height[left] < height[right]) {
            ++left;
        } else {
            --right;
        }
    }
    return ret;
}

static int maxArea_noob(vector<int> &height)
{
    int ret = 0;
    int len = (int)height.size();
    for (int i = 0; i < len; ++i) {
        for (int j = i + 1; j < len; ++j) {
            int h = min(height[i], height[j]);
            ret = max(ret, h * (j - i));
        }
    }
    return ret;
}

+ (void)run
{
    {
        vector<int> v = {1, 8, 6, 2, 5, 4, 8, 3, 7};
        int ret = maxArea(v);
        NSParameterAssert(ret == 49);
    }
    {
        vector<int> v = {1, 8, 6, 2, 5, 4, 8, 3, 7};
        int ret = maxArea_noob(v);
        NSParameterAssert(ret == 49);
    }
}

@end
