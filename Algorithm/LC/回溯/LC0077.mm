//
//  LC0077.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0077.h"
#import <queue>
#import <set>
#import <unordered_map>
#import <vector>

using namespace std;

@implementation LC0077

/*
 组合

 给定两个整数 n 和 k，返回 1 ... n 中所有可能的 k 个数的组合。

 示例:

 输入: n = 4, k = 2
 输出:
 [
   [2,4],
   [3,4],
   [2,3],
   [1,2],
   [1,3],
   [1,4],
 ]
 */
static vector<vector<int>> combine(int n, int k)
{
    vector<vector<int>> ret;
    if (n < k || k <= 0) {
        return ret;
    }
    vector<int> temp;
    combine_impl(ret, temp, n, k, 1);
    return ret;
}

static void combine_impl(vector<vector<int>> &ret, vector<int> &current, int n, int k, int start)
{
    if (k == current.size()) {
        ret.push_back(current);
        return;
    }
    for (int i = start; i <= n; ++i) {
        current.push_back(i);
        combine_impl(ret, current, n, k, i + 1);
        current.pop_back();
    }
}

+ (void)run
{
    vector<vector<int>> ret = combine(4, 2);
    NSParameterAssert(ret.size() == 6);
}

@end
