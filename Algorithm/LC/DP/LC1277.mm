//
//  LC1277.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC1277.h"
#import <string>
#import <vector>
#import <unordered_map>
#import <map>
#import <set>

using namespace std;

@implementation LC1277

/*
 统计全为 1 的正方形子矩阵

 给你一个 m * n 的矩阵，矩阵中的元素不是 0 就是 1，请你统计并返回其中完全由 1 组成的 正方形 子矩阵的个数。

 示例 1：
 输入：matrix = [
   [0,1,1,1],
   [1,1,1,1],
   [0,1,1,1]
 ]
 输出：15
 解释：
 边长为 1 的正方形有 10 个。
 边长为 2 的正方形有 4 个。
 边长为 3 的正方形有 1 个。
 正方形的总数 = 10 + 4 + 1 = 15.
 示例 2：

 输入：matrix = [
   [1,0,1],
   [1,1,0],
   [1,1,0]
 ]
 输出：7
 解释：
 边长为 1 的正方形有 6 个。
 边长为 2 的正方形有 1 个。
 正方形的总数 = 6 + 1 = 7.

 提示：
 1 <= arr.length <= 300
 1 <= arr[0].length <= 300
 0 <= arr[i][j] <= 1
 */
static int countSquares(vector<vector<int>>& matrix)
{
    int m = (int)matrix.size();
    int n = (int)matrix[0].size();
    vector<vector<int>> f(m, vector<int>(n));
    int ans = 0;
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
            if (i == 0 || j == 0) {
                f[i][j] = matrix[i][j];
            }
            else if (matrix[i][j] == 0) {
                f[i][j] = 0;
            }
            else {
                f[i][j] = min(min(f[i][j - 1], f[i - 1][j]), f[i - 1][j - 1]) + 1;
            }
            ans += f[i][j];
        }
    }
    return ans;
}

+ (void)run
{
    {
        vector<vector<int>> v = {{0,1,1,1},{1,1,1,1},{0,1,1,1}};
        NSParameterAssert(countSquares(v) == 15);
    }
    {
        vector<vector<int>> v = {{1,0,1},{1,1,0},{1,1,0}};
        NSParameterAssert(countSquares(v) == 7);
    }
}

@end
