//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0005)

/*
 最长回文子串

 给定一个字符串 s，找到 s 中最长的回文子串。你可以假设 s 的最大长度为 1000。

 示例 1：
 输入: "babad"
 输出: "bab"
 注意: "aba" 也是一个有效答案。
 示例 2：

 输入: "cbbd"
 输出: "bb"
 */
static string longestPalindrome(string s)
{
    int len = (int)s.size();
    if (len <= 1) {
        return s;
    }
    
    int max = 1;
    int start = 0;
    
    vector<vector<int>> dp(len, vector<int>(len, 0));
    for (int i = 0; i < len; ++i) {
        dp[i][i] = 1;
        if (i + 1 < len) {
            if (s[i] == s[i + 1]) {
                dp[i][i + 1] = 1;
                max = 2;
                start = i;
            }
        }
    }
    
    for (int l = 3; l <= len; ++l) {
        for (int i = 0; i < len; ++i) {
            int right = i + l - 1;
            if (right < len) {
                if (s[i] == s[right]) {
                    if (dp[i + 1][right - 1]) {
                        dp[i][right] = 1;
                        if (max < l) {
                            max = l;
                            start = i;
                        }
                    }
                }
            }
        }
    }
    return s.substr(start, max);
}

+ (void)run
{
    {
        NSParameterAssert(longestPalindrome("abcda") == "a");
    }
    {
        NSParameterAssert(longestPalindrome("babad") == "bab");
    }
    {
        NSParameterAssert(longestPalindrome("aaabbbaaa") == "aaabbbaaa");
    }
}

LC_CLASS_END
