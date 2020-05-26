//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0714)

/*
 买卖股票的最佳时机含手续费
 给定一个整数数组 prices，其中第 i 个元素代表了第 i 天的股票价格 ；非负整数 fee 代表了交易股票的手续费用。

 你可以无限次地完成交易，但是你每笔交易都需要付手续费。如果你已经购买了一个股票，在卖出它之前你就不能再继续购买股票了。
 返回获得利润的最大值。
 注意：这里的一笔交易指买入持有并卖出股票的整个过程，每笔交易你只需要为支付一次手续费。
 示例 1:
 输入: prices = [1, 3, 2, 8, 4, 9], fee = 2
 输出: 8
 解释: 能够达到的最大利润:
 在此处买入 prices[0] = 1
 在此处卖出 prices[3] = 8
 在此处买入 prices[4] = 4
 在此处卖出 prices[5] = 9
 总利润: ((8 - 1) - 2) + ((9 - 4) - 2) = 8.
 注意:
 0 < prices.length <= 50000.
 0 < prices[i] < 50000.
 0 <= fee < 50000.
 */

static int maxProfit(vector<int>& prices, int fee)
{
    int len = (int)prices.size();
    // 设置一个二维数组，表示是否持有股票时，状态的变化
    vector<vector<int>> dp(len, vector<int>(2, 0));
    dp[0][0] = 0;
    dp[0][1] = -prices[0];
    for (int i = 1; i < len; ++i) {
        // 表示没有股票在手时，身上含有的金额,状态的变化
        dp[i][0] = max(dp[i - 1][0], dp[i - 1][1] + prices[i] - fee);
        // 表示有股票在手时，含有的金额状态的变化
        dp[i][1] = max(dp[i - 1][1], dp[i - 1][0] - prices[i]);
    }
    return dp[len - 1][0];
}

+ (void)run
{
    {
        vector<int> v = {1, 3, 2, 8, 4, 9};
        NSCParameterAssert(maxProfit(v, 2) == 8);
    }
}

LC_CLASS_END
