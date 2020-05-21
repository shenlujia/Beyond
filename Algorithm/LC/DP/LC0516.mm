//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0516)

/*
 最长回文子序列
 给定一个字符串s，找到其中最长的回文子序列。可以假设s的最大长度为1000。

 示例 1:
 输入:

 "bbbab"
 输出:

 4
 一个可能的最长回文子序列为 "bbbb"。

 示例 2:
 输入:

 "cbbd"
 输出:

 2
 一个可能的最长回文子序列为 "bb"。
 */
static int longestPalindromeSubseq(string s)
{
    int len = (int)s.length();
    if (len <= 1) {
        return len;
    }

    vector<vector<int>> dp(len, vector<int>(len, 0));
    for (int i = 0; i < len; ++i) {
        dp[i][i] = 1;
    }
    for (int step = 1; step < len; ++step) {
        for (int i = 0; i + step < len; ++i) {
            int j = i + step;
            if (s[i] == s[j]) {
                dp[i][j] = dp[i + 1][j - 1] + 2;
            } else {
                dp[i][j] = max(dp[i][j - 1], dp[i + 1][j]);
            }
        }
    }
    return dp[0][len - 1];
}

+ (void)run
{
    NSParameterAssert(longestPalindromeSubseq("cbbd") == 2);
    NSParameterAssert(longestPalindromeSubseq("bbbab") == 4);
}

LC_CLASS_END
