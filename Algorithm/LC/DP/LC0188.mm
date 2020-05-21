//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0188)

/*
 买卖股票的最佳时机 IV

 给定一个数组，它的第 i 个元素是一支给定的股票在第 i 天的价格。

 设计一个算法来计算你所能获取的最大利润。你最多可以完成 k 笔交易。

 注意: 你不能同时参与多笔交易（你必须在再次购买前出售掉之前的股票）。

 示例 1:

 输入: [2,4,1], k = 2
 输出: 2
 解释: 在第 1 天 (股票价格 = 2) 的时候买入，在第 2 天 (股票价格 = 4) 的时候卖出，这笔交易所能获得利润 = 4-2 = 2 。
 示例 2:

 输入: [3,2,6,5,0,3], k = 2
 输出: 7
 解释: 在第 2 天 (股票价格 = 2) 的时候买入，在第 3 天 (股票价格 = 6) 的时候卖出, 这笔交易所能获得利润 = 6-2 = 4 。
      随后，在第 5 天 (股票价格 = 0) 的时候买入，在第 6 天 (股票价格 = 3) 的时候卖出, 这笔交易所能获得利润 = 3-0 = 3 。
 */
static int maxProfit(int k, vector<int> &prices)
{
    // todo...
    return 0;
}

+ (void)run
{
    {
        vector<int> v = {1, 5, 6, 1, 2, 3, 1, 2, 3};
        NSParameterAssert(maxProfit(2, v) <= 7);
    }
    {
        vector<int> v = {2, 4, 1};
        NSParameterAssert(maxProfit(2, v) <= 2);
    }
    {
        vector<int> v = {3, 2, 6, 5, 0, 3};
        NSParameterAssert(maxProfit(2, v) <= 7);
    }
}

LC_CLASS_END
