//
//  LC0120.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0120.h"
#import <math.h>
#import <string>
#import <vector>

using namespace std;

@implementation LC0120

/*
 三角形最小路径和

 给定一个三角形，找出自顶向下的最小路径和。每一步只能移动到下一行中相邻的结点上。
 相邻的结点 在这里指的是 下标 与 上一层结点下标 相同或者等于 上一层结点下标 + 1 的两个结点。

 例如，给定三角形：
 [
      [2],
     [3,4],
    [6,5,7],
   [4,1,8,3]
 ]
 自顶向下的最小路径和为 11（即，2 + 3 + 5 + 1 = 11）。

 说明：
 如果你可以只使用 O(n) 的额外空间（n 为三角形的总行数）来解决这个问题，那么你的算法会很加分。
 */

static int minimumTotal(vector<vector<int>>& triangle)
{
    int len = (int)triangle.size();
    if (len == 0) {
        return 0;
    }
    for (int i = 1; i < len; ++i) {
        vector<int> &pre = triangle[i-1];
        vector<int> &cur = triangle[i];
        int cur_len = (int)cur.size();
        cur[0] += pre[0];
        cur[cur_len-1] += pre[cur_len-2];
        for (int j = 1; j < cur_len - 1; ++j) {
            cur[j] += min(pre[j-1],pre[j]);
        }
    }
    int ret = INT_MAX;
    vector<int> &last = triangle[len-1];
    for (int i = 0; i < len; ++i) {
        ret = min(ret,last[i]);
    }
    return ret;
}

+ (void)run
{
    {
        vector<vector<int>> v = {{2},{3,4},{6,5,7},{4,1,8,3}};
        NSParameterAssert(minimumTotal(v) == 11);
    }
}

@end
