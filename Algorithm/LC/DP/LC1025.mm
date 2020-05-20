//
//  LC1025.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC1025.h"
#import <string>
#import <vector>
#import <unordered_map>

using namespace std;

@implementation LC1025

/*
 除数博弈

 爱丽丝和鲍勃一起玩游戏，他们轮流行动。爱丽丝先手开局。
 最初，黑板上有一个数字 N 。在每个玩家的回合，玩家需要执行以下操作：
 选出任一 x，满足 0 < x < N 且 N % x == 0 。
 用 N - x 替换黑板上的数字 N 。
 如果玩家无法执行这些操作，就会输掉游戏。

 只有在爱丽丝在游戏中取得胜利时才返回 True，否则返回 false。假设两个玩家都以最佳状态参与游戏。
 示例 1：
 输入：2
 输出：true
 解释：爱丽丝选择 1，鲍勃无法进行操作。
 示例 2：
 输入：3
 输出：false
 解释：爱丽丝选择 1，鲍勃也选择 1，然后爱丽丝无法进行操作。
  
 提示：
 1 <= N <= 1000
 */
static bool divisorGame(int N)
{
    if (N <= 1) {
        return false;
    }
    vector<int> dp(N+1,0);
    dp[2] = 1;
    for (int i = 3; i <= N; ++i) {
        int max = i / 2;
        for (int j = 1; j <= max; ++j) {
            if (i % j == 0 && dp[i-j] == 0) {
                dp[i] = 1;
                break;
            }
        }
    }
    return dp[N] == 1;
}

+ (void)run
{
    {
        NSParameterAssert(divisorGame(4) == true);
    }
    {
        NSParameterAssert(divisorGame(3) == false);
    }
    {
        NSParameterAssert(divisorGame(35) == false);
    }
}

@end
