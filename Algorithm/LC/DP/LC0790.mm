//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0790)

/*
 多米诺和托米诺平铺
 有两种形状的瓷砖：一种是 2x1 的多米诺形，另一种是形如 "L" 的托米诺形。两种形状都可以旋转。
 XX  <- 多米诺
 XX  <- "L" 托米诺
 X
 给定 N 的值，有多少种方法可以平铺 2 x N 的面板？返回值 mod 10^9 + 7。
 （平铺指的是每个正方形都必须有瓷砖覆盖。两个平铺不同，当且仅当面板上有四个方向上的相邻单元中的两个，使得恰好有一个平铺有一个瓷砖占据两个正方形。）
 示例:
 输入: 3
 输出: 5
 解释:
 下面列出了五种不同的方法，不同字母代表不同瓷砖：
 XYZ XXZ XYY XXY XYY
 XYZ YYZ XZZ XYY XXY
 */
static int numTilings(int N)
{
    const long long MOD = 1000000007;
    if (N == 1) {
        return 1;
    }
    // 0 -> i 列铺完后 i + 1 列为空
    // 1 -> i 列铺完后 i + 1 列为上有下空
    // 2 -> i 列铺完后 i + 1 列为上空下有
    vector<vector<long long>> dp(N, vector<long long>(3, 0));
    dp[0][0] = dp[0][1] = dp[0][2] = 1;
    dp[1][0] = dp[1][1] = dp[1][2] = 2;
    for (int i = 2; i < N; ++i) {
        dp[i][0] = (dp[i - 1][0] + dp[i - 2][0] + dp[i - 2][1] + dp[i - 2][2]) % MOD;
        dp[i][1] = (dp[i - 1][0] + dp[i - 1][2]) % MOD;
        dp[i][2] = (dp[i - 1][0] + dp[i - 1][1]) % MOD;
    }
    return (int)dp[N-1][0];
}

+ (void)run
{
    {
        NSCParameterAssert(numTilings(3) == 5);
    }
}

LC_CLASS_END
