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
static void solveSudoku(vector<vector<char>> &board)
{
    // todo...
}

+ (void)run
{
    vector<vector<char>> codes = {{'5', '3', '.', '.', '7', '.', '.', '.', '.'}, {'6', '.', '.', '1', '9', '5', '.', '.', '.'},
                                  {'.', '9', '8', '.', '.', '.', '.', '6', '.'}, {'8', '.', '.', '.', '6', '.', '.', '.', '3'},
                                  {'4', '.', '.', '8', '.', '3', '.', '.', '1'}, {'7', '.', '.', '.', '2', '.', '.', '.', '6'},
                                  {'7', '.', '.', '.', '2', '.', '.', '.', '6'}, {'.', '6', '.', '.', '.', '.', '2', '8', '.'},
                                  {'.', '.', '.', '4', '1', '9', '.', '.', '5'}, {'.', '.', '.', '.', '8', '.', '.', '7', '9'}};

    solveSudoku(codes);
    vector<char> line0 = {'5', '3', '4', '6', '7', '8', '9', '1', '2'};
    NSParameterAssert(codes[0].size() == line0.size());
}

@end
