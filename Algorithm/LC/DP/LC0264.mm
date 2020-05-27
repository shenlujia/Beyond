//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0264)

/*
 丑数 II
 编写一个程序，找出第 n 个丑数。
 丑数就是质因数只包含 2, 3, 5 的正整数。
 示例:
 输入: n = 10
 输出: 12
 解释: 1, 2, 3, 4, 5, 6, 8, 9, 10, 12 是前 10 个丑数。
 说明:
 1 是丑数。
 n 不超过1690。
 通过次数25,411提交次数49,077
 */
static int nthUglyNumber(int n)
{
    vector<int> dp(n, 0);
    dp[0] = 1;
    int dp2 = 0;
    int dp3 = 0;
    int dp5 = 0;
    for (int i = 1; i < n; ++i) {
        int temp = min(dp[dp2] * 2, dp[dp3] * 3);
        dp[i] = min(temp, dp[dp5] * 5);
        if (dp[i] == dp[dp2] * 2) {
            dp2++;
        }
        if (dp[i] == dp[dp3] * 3) {
            dp3++;
        }
        if (dp[i] == dp[dp5] * 5) {
            dp5++;
        }
    }
    return dp[n - 1];
}

+ (void)run
{
    {
        NSCParameterAssert(nthUglyNumber(1680) == 2025000000);
    }
}

LC_CLASS_END
