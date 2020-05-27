//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0279)

/*
 完全平方数
 给定正整数 n，找到若干个完全平方数（比如 1, 4, 9, 16, ...）使得它们的和等于 n。你需要让组成和的完全平方数的个数最少。
 示例 1:
 输入: n = 12
 输出: 3
 解释: 12 = 4 + 4 + 4.
 示例 2:
 输入: n = 13
 输出: 2
 解释: 13 = 4 + 9.
 */
static int numSquares(int n)
{
    int k = sqrt(n);
    vector<int> values(k, 0);
    for (int i = 1; i <= k; ++i) {
        values[i - 1] = i * i;
    }
    vector<int> dp(n + 1, -1);
    dp[0] = 0;
    for (int i = 1; i <= n; ++i) {
        for (int j = 0; j < k; ++j) {
            int value = values[j];
            if (value <= i) {
                if (dp[i] >= 0) {
                    dp[i] = min(dp[i], dp[i - value] + 1);
                } else {
                    dp[i] = dp[i - value] + 1;
                }
            }
        }
    }
    return dp[n];
}

+ (void)run
{
    {
        NSCParameterAssert(numSquares(13) == 2);
    }
}

LC_CLASS_END
