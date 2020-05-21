//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0647)

/*
 回文子串

 给定一个字符串，你的任务是计算这个字符串中有多少个回文子串。
 具有不同开始位置或结束位置的子串，即使是由相同的字符组成，也会被计为是不同的子串。

 示例 1:
 输入: "abc"
 输出: 3
 解释: 三个回文子串: "a", "b", "c".
 示例 2:
 输入: "aaa"
 输出: 6
 说明: 6个回文子串: "a", "a", "a", "aa", "aa", "aaa".
 */

static int countSubstrings(string s)
{
    int len = (int)s.size();
    if (len <= 1) {
        return len;
    }
    int ret = 0;
    vector<vector<int>> dp(len, vector<int>(len, 0));
    for (int i = 0; i < len; ++i) {
        dp[i][i] = 1;
        ++ret;
        if (i < len - 1 && s[i] == s[i + 1]) {
            dp[i][i + 1] = 1;
            ++ret;
        }
    }
    for (int step = 2; step < len; ++step) {
        for (int i = 0; i < len; ++i) {
            int j = i + step;
            if (j < len) {
                if (dp[i + 1][j - 1] && s[i] == s[j]) {
                    dp[i][j] = 1;
                    ++ret;
                }
            }
        }
    }
    return ret;
}

+ (void)run
{
    {
        NSParameterAssert(countSubstrings("aaaaa") == 15);
    }
    {
        NSParameterAssert(countSubstrings("abc") == 3);
    }
    {
        NSParameterAssert(countSubstrings("aaa") == 6);
    }
}

LC_CLASS_END
