//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0221)

/*
 最大正方形
 在一个由 0 和 1 组成的二维矩阵内，找到只包含 1 的最大正方形，并返回其面积。
 示例:
 输入:
 1 0 1 0 0
 1 0 1 1 1
 1 1 1 1 1
 1 0 0 1 0
 输出: 4
 */

static int maximalSquare(vector<vector<char>>& matrix)
{
    int m = (int)matrix.size();
    if (m == 0) {
        return 0;
    }
    int n = (int)matrix[0].size();
    
    int ret = 0;
    vector<vector<int>> dp(m, vector<int>(n, 0));
    for (int i = 0; i < m; ++i) {
        if (matrix[i][0] == '1') {
            dp[i][0] = 1;
            ret = 1;
        }
    }
    for (int i = 0; i < n; ++i) {
        if (matrix[0][i] == '1') {
            dp[0][i] = 1;
            ret = 1;
        }
    }
    for (int i = 1; i < m; ++i) {
        for (int j = 1; j < n; ++j) {
            if (matrix[i][j] == '1') {
                int temp = min(dp[i - 1][j - 1], min(dp[i - 1][j], dp[i][j - 1])) + 1;
                dp[i][j] = temp;
                ret = max(ret, temp * temp);
            }
        }
    }
    return ret;
}

+ (void)run
{
    {
        vector<vector<char>> v = {{'0', '1'}};
        NSParameterAssert(maximalSquare(v) == 1);
    }
    {
        vector<vector<char>> v = {{'1', '0', '1', '0', '0'}, {'1', '0', '1', '1', '1'}, {'1', '1', '1', '1', '1'}, {'1', '0', '0', '1', '0'}};
        NSParameterAssert(maximalSquare(v) == 4);
    }
}

LC_CLASS_END
