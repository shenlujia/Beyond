//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0343)

/*
 整数拆分
 给定一个正整数 n，将其拆分为至少两个正整数的和，并使这些整数的乘积最大化。 返回你可以获得的最大乘积。
 示例 1:
 输入: 2
 输出: 1
 解释: 2 = 1 + 1, 1 × 1 = 1。
 示例 2:
 输入: 10
 输出: 36
 解释: 10 = 3 + 3 + 4, 3 × 3 × 4 = 36。
 */
static int integerBreak(int n)
{
    vector<int> dp(n + 1, 0);
    dp[0] = 1;
    dp[1] = 1;
    dp[2] = 1;
    for(int i = 3; i <= n; ++i) {
        for(int j = 1; j < i; j++){
            int t1 = max(dp[j] * (i - j), j * dp[i - j]);
            int t2 = max(dp[j] * dp[i - j], j * (i - j));
            dp[i] = max(dp[i], max(t1, t2));
        }
    }
    return dp[n];
}

+ (void)run
{
    {
        NSCParameterAssert(integerBreak(20) == 1458);
    }
    {
        NSCParameterAssert(integerBreak(2) == 1);
    }
    {
        NSCParameterAssert(integerBreak(10) == 36);
    }
}

LC_CLASS_END
