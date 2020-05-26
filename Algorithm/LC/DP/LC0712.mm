//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0712)

/*
 两个字符串的最小ASCII删除和
 给定两个字符串s1, s2，找到使两个字符串相等所需删除字符的ASCII值的最小和。

 示例 1:
 输入: s1 = "sea", s2 = "eat"
 输出: 231
 解释: 在 "sea" 中删除 "s" 并将 "s" 的值(115)加入总和。
 在 "eat" 中删除 "t" 并将 116 加入总和。
 结束时，两个字符串相等，115 + 116 = 231 就是符合条件的最小和。
 示例 2:
 输入: s1 = "delete", s2 = "leet"
 输出: 403
 解释: 在 "delete" 中删除 "dee" 字符串变成 "let"，
 将 100[d]+101[e]+101[e] 加入总和。在 "leet" 中删除 "e" 将 101[e] 加入总和。
 结束时，两个字符串都等于 "let"，结果即为 100+101+101+101 = 403 。
 如果改为将两个字符串转换为 "lee" 或 "eet"，我们会得到 433 或 417 的结果，比答案更大。
 注意:
 0 < s1.length, s2.length <= 1000。
 所有字符串中的字符ASCII值在[97, 122]之间。
 */

static int minimumDeleteSum(string s1, string s2)
{
    int m = (int)s1.size();
    int n = (int)s2.size();
    vector<vector<int>> dp(m + 1, vector<int>(n + 1, 0));
    for (int i = 1; i <= m; ++i) {
        dp[i][0] = dp[i - 1][0] + s1[i - 1];
    }
    for (int j = 1; j <= n; ++j) {
        dp[0][j] = dp[0][j - 1] + s2[j - 1];
    }
    for (int i = 1; i <= m; ++i) {
        for (int j = 1; j <= n; ++j) {
            if (s1[i - 1] == s2[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1];
            } else {
                int temp = min(dp[i - 1][j] + s1[i - 1], dp[i][j - 1] + s2[j - 1]);
                dp[i][j] = min(temp, dp[i - 1][j - 1] + s1[i - 1] + s2[j - 1]);
            }
        }
    }
    return dp[m][n];
}

+ (void)run
{
    {
        string s1 = "sea";
        string s2 = "eat";
        NSCParameterAssert(minimumDeleteSum(s1, s2) == 231);
    }
    {
        string s1 = "delete";
        string s2 = "leet";
        NSCParameterAssert(minimumDeleteSum(s1, s2) == 403);
    }
}

LC_CLASS_END
