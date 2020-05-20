//
//  LC0576.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0576.h"
#import <math.h>
#import <string>
#import <vector>

using namespace std;

@implementation LC0576

/*
 出界的路径数

 给定一个 m × n 的网格和一个球。球的起始坐标为 (i,j) ，你可以将球移到相邻的单元格内，或者往上、下、左、右四个方向上移动使球穿过网格边界。但是，你最多可以移动 N 次。找出可以将球移出边界的路径数量。答案可能非常大，返回 结果 mod 109 + 7 的值。

 示例 1：
 输入: m = 2, n = 2, N = 2, i = 0, j = 0
 输出: 6
 解释:
 示例 2：
 输入: m = 1, n = 3, N = 3, i = 0, j = 1
 输出: 12
 解释:

 说明:
 球一旦出界，就不能再被移动回网格内。
 网格的长度和高度在 [1,50] 的范围内。
 N 在 [0,50] 的范围内。
 */

static int findPaths(int m, int n, int N, int i, int j)
{
    if (N <= 0) {
        return 0;
    }
    int MOD = 1000000007;
    vector<vector<vector<int>>> dp(m+2,vector<vector<int>>(n+2,vector<int>(N+1,0)));
    for (int i = 0; i <= m+1; ++i) {
        dp[i][0][0] = 1;
        dp[i][n+1][0] = 1;
    }
    for (int i = 0; i <= n+1; ++i) {
        dp[0][i][0] = 1;
        dp[m+1][i][0] = 1;
    }
    for (int k = 1; k <=N; ++k) {
        for (int i = 1; i <= m; ++i) {
            for (int j = 1; j <= n; ++j) {
                long long value = dp[i-1][j][k-1] + dp[i][j-1][k-1];
                value +=dp[i+1][j][k-1] + dp[i][j+1][k-1];
                dp[i][j][k] = value % MOD;
            }
        }
    }
    int ret = 0;
    for (int k = 1; k <=N; ++k) {
        ret = (ret + dp[i+1][j+1][k]) % MOD;
    }
    return ret;
}

+ (void)run
{
    {
        NSParameterAssert(findPaths(2,2,2,0,0) == 6);
    }
    {
        NSParameterAssert(findPaths(1,3,3,0,1) == 12);
    }
}

@end
