//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0054)

/*
 螺旋矩阵

 给定一个包含 m x n 个元素的矩阵（m 行, n 列），请按照顺时针螺旋顺序，返回矩阵中的所有元素。
 示例 1:
 输入:
 [
  [ 1, 2, 3 ],
  [ 4, 5, 6 ],
  [ 7, 8, 9 ]
 ]
 输出: [1,2,3,6,9,8,7,4,5]
 示例 2:
 输入:
 [
   [1, 2, 3, 4],
   [5, 6, 7, 8],
   [9,10,11,12]
 ]
 输出: [1,2,3,4,8,12,11,10,9,5,6,7]
 */

static vector<int> spiralOrder(vector<vector<int>>& matrix)
{
    vector<int> ret;
    int m = (int)matrix.size();
    if (m == 0) {
        return ret;
    }
    int n = (int)matrix[0].size();
    if (n == 0) {
        return ret;
    }
    
    vector<vector<bool>> visited(m, vector<bool>(n, false));
    vector<vector<int>> directions = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}};
    for (int temp = 0, i = 0, j = 0, directionIndex = 0; temp < m * n; ++temp) {
        ret.push_back(matrix[i][j]);
        visited[i][j] = true;
        int new_i = i + directions[directionIndex][0];
        int new_j = j + directions[directionIndex][1];
        if (0 <= new_i && new_i < m && 0 <= new_j && new_j < n && visited[new_i][new_j] == false) {
            i = new_i;
            j = new_j;
        } else {
            directionIndex = (directionIndex + 1) % directions.size();
            i += directions[directionIndex][0];
            j += directions[directionIndex][1];
        }
    }
    return ret;
}

+ (void)run
{
    {
        vector<vector<int>> v = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
        vector<int> ret = {1, 2, 3, 6, 9, 8, 7, 4, 5};
        NSParameterAssert(spiralOrder(v) == ret);
    }
    {
        vector<vector<int>> v = {{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}};
        vector<int> ret = {1, 2, 3, 4, 8, 12, 11, 10, 9, 5, 6, 7};
        NSParameterAssert(spiralOrder(v) == ret);
    }
}

LC_CLASS_END
