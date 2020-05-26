//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(1139)

/*
 最大的以 1 为边界的正方形
 给你一个由若干 0 和 1 组成的二维网格 grid，请你找出边界全部由 1 组成的最大 正方形 子网格，并返回该子网格中的元素数量。如果不存在，则返回 0。
 示例 1：
 输入：grid = [[1,1,1],[1,0,1],[1,1,1]]
 输出：9
 示例 2：
 输入：grid = [[1,1,0,0]]
 输出：1
  
 提示：
 1 <= grid.length <= 100
 1 <= grid[0].length <= 100
 grid[i][j] 为 0 或 1
 */
static int largest1BorderedSquare(vector<vector<int>>& grid)
{
    int m = (int)grid.size();
    int n = (int)grid[0].size();
    vector<vector<int>> h_count(m, vector<int>(n, 0));
    vector<vector<int>> v_count(m, vector<int>(n, 0));
    int ret = 0;
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
            if (grid[i][j] == 0) {
                continue;
            }
            h_count[i][j] = 1;
            v_count[i][j] = 1;
            ret = max(ret, 1);
            if (i > 0 || j > 0) {
                if (i > 0) {
                    v_count[i][j] += v_count[i - 1][j];
                }
                if (j > 0) {
                    h_count[i][j] += h_count[i][j - 1];
                }
                int length = min(v_count[i][j], h_count[i][j]);
                for (int k = length; k > 1; --k) {
                    int new_i = i - k + 1;
                    int new_j = j - k + 1;
                    if (new_i >= 0 && new_j >= 0) {
                        if (v_count[i][new_j] >= k && h_count[new_i][j] >= k) {
                            ret = max(ret, k * k);
                            break;
                        }
                    }
                }
            }
        }
    }
    return ret;
}

+ (void)run
{
    {
        vector<vector<int>> v = {{0, 0, 0, 1}};
        NSParameterAssert(largest1BorderedSquare(v) == 1);
    }
    {
        vector<vector<int>> v = {{1, 1, 1}, {1, 0, 1}, {1, 1, 1}};
        NSParameterAssert(largest1BorderedSquare(v) == 9);
    }
    {
        vector<vector<int>> v = {{1, 1, 0, 0}};
        NSParameterAssert(largest1BorderedSquare(v) == 1);
    }
}

LC_CLASS_END
