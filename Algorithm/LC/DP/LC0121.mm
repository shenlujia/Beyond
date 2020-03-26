//
//  LC0121.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0121.h"
#import <string>
#import <vector>

using namespace std;

@implementation LC0121

/*
 买卖股票的最佳时机

 给定一个数组，它的第 i 个元素是一支给定股票第 i 天的价格。

 如果你最多只允许完成一笔交易（即买入和卖出一支股票一次），设计一个算法来计算你所能获取的最大利润。

 注意：你不能在买入股票前卖出股票。

 示例 1:

 输入: [7,1,5,3,6,4]
 输出: 5
 解释: 在第 2 天（股票价格 = 1）的时候买入，在第 5 天（股票价格 = 6）的时候卖出，最大利润 = 6-1 = 5 。
      注意利润不能是 7-1 = 6, 因为卖出价格需要大于买入价格。
 示例 2:

 输入: [7,6,4,3,1]
 输出: 0
 解释: 在这种情况下, 没有交易完成, 所以最大利润为 0。
 */
static int maxProfit(vector<int> &prices)
{
    int len = (int)prices.size();
    if (len <= 1)
        return 0;
    vector<int> diff(len - 1);
    for (int i = 0; i < len - 1; ++i) {
        diff[i] = prices[i + 1] - prices[i];
    }

    vector<int> dp(diff.size());
    dp[0] = max(0, diff[0]);
    int profit = dp[0];
    for (int i = 1; i < diff.size(); ++i) {
        dp[i] = max(0, dp[i - 1] + diff[i]);
        profit = max(profit, dp[i]);
    }
    return profit;
}

static int maxProfit_clean(vector<int> &prices)
{
    int len = (int)prices.size();
    if (len <= 1) {
        return 0;
    }
    int ret = 0;
    int pre_min = prices[0];
    for (int i = 0; i < len; ++i) {
        int temp = prices[i];
        if (ret < temp - pre_min) {
            ret = temp - pre_min;
        }
        pre_min = min(pre_min, temp);
    }
    return ret;
}

+ (void)run
{
    {
        vector<int> v = {7, 6, 4, 3, 1};
        NSParameterAssert(maxProfit(v) == 0);
        NSParameterAssert(maxProfit_clean(v) == 0);
    }
    {
        vector<int> v = {7, 1, 5, 3, 6, 4};
        NSParameterAssert(maxProfit(v) == 5);
        NSParameterAssert(maxProfit_clean(v) == 5);
    }
}

@end
