//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0309)

/*
 最佳买卖股票时机含冷冻期
 给定一个整数数组，其中第 i 个元素代表了第 i 天的股票价格 。
 设计一个算法计算出最大利润。在满足以下约束条件下，你可以尽可能地完成更多的交易（多次买卖一支股票）:
 你不能同时参与多笔交易（你必须在再次购买前出售掉之前的股票）。
 卖出股票后，你无法在第二天买入股票 (即冷冻期为 1 天)。
 示例:
 输入: [1,2,3,0,2]
 输出: 3
 解释: 对应的交易状态为: [买入, 卖出, 冷冻期, 买入, 卖出]
 */

static int maxProfit(vector<int>& prices)
{
    int len = (int)prices.size();
    if (len <= 1) {
        return 0;
    }
    
    /*
     天数
     0表示不动 1表示卖出 2表示买入
     0表示不持有的最大利润 1表示持有的最大利润
     */
    vector<vector<vector<int>>> dp(len, vector<vector<int>>(3, vector<int>(2, -999999)));
    dp[0][0][0] = 0;
    dp[0][2][1] = -prices[0];
    for (int i = 1; i < len; ++i) {
        int value = prices[i];
        dp[i][0][0] = max(dp[i - 1][0][0], dp[i - 1][1][0]);
        dp[i][0][1] = max(dp[i - 1][0][1], dp[i - 1][2][1]);
        dp[i][1][0] = max(dp[i - 1][2][1], dp[i - 1][0][1]) + value;
        // dp[i][1][1] 无效
        // dp[i][2][0] 无效
        dp[i][2][1] = dp[i - 1][0][0] - value;
    }
    
    return max(dp[len - 1][0][0], dp[len - 1][1][0]);
}

static int maxProfit_2(vector<int>& prices)
{
    int len = (int)prices.size();
    if (len <= 1) {
        return 0;
    }
    
    //定义三个数组 表示三种状态，其中A--观望，B--持股，C--卖出A[i]表示第i天A状态的最佳利润
    //转移状态： A--A，不变，A--B买入 -prices， B--B观望，B--C卖出 +prices， C--A 冷却
    vector<int> A(len, 0);
    vector<int> B(len, 0);
    vector<int> C(len, 0);
    B[0] = C[0] = -prices[0];
    for (int i = 1; i < len; ++i) {
        //变为A状态有两种，A-A和C-A
        A[i] = max(A[i - 1], C[i - 1]);
        //变为B状态有两种，B-B和A-B（-prices）
        B[i] = max(A[i - 1] - prices[i], B[i - 1]);
        //变为C只有一种，即B-C（+prices）
        C[i] = B[i - 1] + prices[i];
    }
    return max(A[len - 1], C[len - 1]);
}

+ (void)run
{
    {
        vector<int> v = {1, 2, 3, 0, 2};
        NSCParameterAssert(maxProfit(v) == 3);
        NSCParameterAssert(maxProfit_2(v) == 3);
    }
}

LC_CLASS_END
