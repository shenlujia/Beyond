//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0322)

/*
 零钱兑换
 给定不同面额的硬币 coins 和一个总金额 amount。编写一个函数来计算可以凑成总金额所需的最少的硬币个数。如果没有任何一种硬币组合能组成总金额，返回 -1。
 示例 1:
 输入: coins = [1, 2, 5], amount = 11
 输出: 3
 解释: 11 = 5 + 5 + 1
 示例 2:
 输入: coins = [2], amount = 3
 输出: -1
 说明:
 你可以认为每种硬币的数量是无限的。
 */
static int coinChange(vector<int>& coins, int amount)
{
    if (amount <= 0) {
        return 0;
    }
    int coin_len = (int)coins.size();
    if (coin_len == 0) {
        return -1;
    }
    
    vector<int> dp(amount + 1, -1);
    dp[0] = 0;
    for (int i = 1; i <= amount; ++i) {
        for (int j = 0; j < coin_len; ++j) {
            int coin = coins[j];
            if (i >= coin && dp[i - coin] >= 0) {
                if (dp[i] < 0) {
                    dp[i] = dp[i - coin] + 1;
                } else {
                    dp[i] = min(dp[i], dp[i - coin] + 1);
                }
            }
        }
    }
    return dp[amount];
}

+ (void)run
{
    {
        vector<int> v = {1, 2, 5};
        NSCParameterAssert(coinChange(v, 11) == 3);
    }
    {
        vector<int> v = {2};
        NSCParameterAssert(coinChange(v, 3) == -1);
    }
}

LC_CLASS_END
