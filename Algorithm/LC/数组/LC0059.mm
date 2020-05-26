//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0059)

/*
 螺旋矩阵 II
 给定一个正整数 n，生成一个包含 1 到 n2 所有元素，且元素按顺时针顺序螺旋排列的正方形矩阵。
 示例:
 输入: 3
 输出:
 [
  [ 1, 2, 3 ],
  [ 8, 9, 4 ],
  [ 7, 6, 5 ]
 ]
 */

static vector<vector<int>> generateMatrix(int n)
{
    vector<vector<int>> ret(n, vector<int>(n, 0));
    
    vector<vector<int>> directions = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}};
    for (int temp = 1, i = 0, j = 0, directionIndex = 0; temp <= n * n; ++temp) {
        ret[i][j] = temp;
        int new_i = i + directions[directionIndex][0];
        int new_j = j + directions[directionIndex][1];
        if (0 <= new_i && new_i < n && 0 <= new_j && new_j < n && ret[new_i][new_j] == 0) {
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
        vector<vector<int>> v = {{1, 2, 3}, {8, 9, 4}, {7, 6, 5}};
        NSParameterAssert(generateMatrix(3) == v);
    }
}

LC_CLASS_END
