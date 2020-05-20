//
//  LC1049.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC1049.h"
#import <string>
#import <vector>
#import <unordered_map>
#import <map>
#import <set>
#import <math.h>
#import <numeric>

using namespace std;

@implementation LC1049

/*
 最后一块石头的重量 II
 有一堆石头，每块石头的重量都是正整数。
 每一回合，从中选出任意两块石头，然后将它们一起粉碎。假设石头的重量分别为 x 和 y，且 x <= y。那么粉碎的可能结果如下：
 如果 x == y，那么两块石头都会被完全粉碎；
 如果 x != y，那么重量为 x 的石头将会完全粉碎，而重量为 y 的石头新重量为 y-x。
 最后，最多只会剩下一块石头。返回此石头最小的可能重量。如果没有石头剩下，就返回 0。

 示例：
 输入：[2,7,4,1,8,1]
 输出：1
 解释：
 组合 2 和 4，得到 2，所以数组转化为 [2,7,1,8,1]，
 组合 7 和 8，得到 1，所以数组转化为 [2,1,1,1]，
 组合 2 和 1，得到 1，所以数组转化为 [1,1,1]，
 组合 1 和 1，得到 0，所以数组转化为 [1]，这就是最优值。
  
 提示：
 1 <= stones.length <= 30
 1 <= stones[i] <= 1000
 */
static int lastStoneWeightII(vector<int>& stones)
{
    int len = (int)stones.size();
    if (len == 0) {
        return 0;
    }
    int sum = accumulate(stones.begin(),stones.end(),0);
    int mid = sum / 2;
    vector<vector<int>> dp(len+1,vector<int>(mid+1,0));
    for (int i = 1; i <= len; ++i) {
        int value = stones[i-1];
        for (int j = 1; j <= mid; ++j) {
            if (j >= value) {
                dp[i][j] = max(dp[i-1][j],value + dp[i-1][j-value]);
            } else {
                dp[i][j] = dp[i-1][j];
            }
        }
    }
    return sum - 2*dp[len][mid];
}

+ (void)run
{
    {
        vector<int> v = {2,7,4,1,8,1};
        NSParameterAssert(lastStoneWeightII(v) == 1);
    }
}

@end
