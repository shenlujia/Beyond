//
//  LC0037.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0037.h"
#import <queue>
#import <set>
#import <unordered_map>
#import <vector>

using namespace std;

@implementation LC0037

/*
 解数独

 编写一个程序，通过已填充的空格来解决数独问题。

 一个数独的解法需遵循如下规则：

 数字 1-9 在每一行只能出现一次。
 数字 1-9 在每一列只能出现一次。
 数字 1-9 在每一个以粗实线分隔的 3x3 宫内只能出现一次。
 空白格用 '.' 表示。

 一个数独。

 答案被标成红色。

 Note:
 给定的数独序列只包含数字 1-9 和字符 '.' 。
 你可以假设给定的数独只有唯一解。
 给定数独永远是 9x9 形式的。
 */
static bool solveSudoku(vector<vector<char>> &board)
{
    return dfs(board, (int)board.size(), 0, 0);
}

static bool dfs(vector<vector<char>> &board, int size, int i, int j)
{
    if (i == size) {
        return board[size - 1][size - 1] != '.';
    }
    if (board[i][j] != '.') {
        return j == size - 1 ? dfs(board, size, i + 1, 0) : dfs(board, size, i, j + 1);
    }
    for (int x = 0; x < size; ++x) {
        char c = '1' + x;
        if (is_valid(board, size, i, j, c)) {
            board[i][j] = c;
            if (j == size - 1) {
                if (dfs(board, size, i + 1, 0)) {
                    return true;
                }
            } else {
                if (dfs(board, size, i, j + 1)) {
                    return true;
                }
            }
            board[i][j] = '.';
        }
    }
    return false;
}

static bool is_valid(vector<vector<char>> &board, int size, int i, int j, char c)
{
    for (int k = 0; k < size; ++k) {
        if (board[i][k] == c) {
            return false;
        }
    }
    for (int k = 0; k < size; ++k) {
        if (board[k][j] == c) {
            return false;
        }
    }
    int big_i_start = i / 3 * 3;
    int big_j_start = j / 3 * 3;
    for (int a = big_i_start; a < big_i_start + 3; ++a) {
        for (int b = big_j_start; b < big_j_start + 3; ++b) {
            if (board[a][b] == c) {
                return false;
            }
        }
    }
    return true;
}

+ (void)run
{
    vector<vector<char>> codes = {{'5', '3', '.', '.', '7', '.', '.', '.', '.'}, {'6', '.', '.', '1', '9', '5', '.', '.', '.'},
                                  {'.', '9', '8', '.', '.', '.', '.', '6', '.'}, {'8', '.', '.', '.', '6', '.', '.', '.', '3'},
                                  {'4', '.', '.', '8', '.', '3', '.', '.', '1'}, {'7', '.', '.', '.', '2', '.', '.', '.', '6'},
                                  {'.', '6', '.', '.', '.', '.', '2', '8', '.'}, {'.', '.', '.', '4', '1', '9', '.', '.', '5'},
                                  {'.', '.', '.', '.', '8', '.', '.', '7', '9'}};

    bool ok = solveSudoku(codes);
    vector<char> line0 = {'5', '3', '4', '6', '7', '8', '9', '1', '2'};
    NSParameterAssert(ok && codes[0] == line0);
}

@end
