//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0010)

/*
 正则表达式匹配

 给你一个字符串 s 和一个字符规律 p，请你来实现一个支持 '.' 和 '*' 的正则表达式匹配。

 '.' 匹配任意单个字符
 '*' 匹配零个或多个前面的那一个元素
 所谓匹配，是要涵盖 整个 字符串 s的，而不是部分字符串。

 说明:

 s 可能为空，且只包含从 a-z 的小写字母。
 p 可能为空，且只包含从 a-z 的小写字母，以及字符 . 和 *。
 示例 1:

 输入:
 s = "aa"
 p = "a"
 输出: false
 解释: "a" 无法匹配 "aa" 整个字符串。
 示例 2:

 输入:
 s = "aa"
 p = "a*"
 输出: true
 解释: 因为 '*' 代表可以匹配零个或多个前面的那一个元素, 在这里前面的元素就是 'a'。因此，字符串 "aa" 可被视为 'a' 重复了一次。
 示例 3:

 输入:
 s = "ab"
 p = ".*"
 输出: true
 解释: ".*" 表示可匹配零个或多个（'*'）任意字符（'.'）。
 示例 4:

 输入:
 s = "aab"
 p = "c*a*b"
 输出: true
 解释: 因为 '*' 表示零个或多个，这里 'c' 为 0 个, 'a' 被重复一次。因此可以匹配字符串 "aab"。
 示例 5:

 输入:
 s = "mississippi"
 p = "mis*is*p*."
 输出: false
 */

static bool isMatch(string s, string p)
{
    int len1 = (int)s.length();
    int len2 = (int)p.length();

    if (p.empty()) {
        return s.empty();
    }

    vector<vector<bool>> dp(len1 + 1, vector<bool>(len2 + 1, false));
    dp[0][0] = 1;
    for (int j = 2; j <= len2; ++j) {
        if (p[j - 1] == '*') {
            dp[0][j] = dp[0][j - 2];
        }
    }

    for (int i = 1; i <= len1; ++i) {
        for (int j = 1; j <= len2; ++j) {
            if (p[j - 1] == s[i - 1] || p[j - 1] == '.') {
                dp[i][j] = dp[i - 1][j - 1];
                continue;
            }
            if (p[j - 1] == '*') {
                if (j - 2 >= 0) {
                    bool zero = dp[i][j - 2];                                             // 后第二位不使用
                    bool one = (p[j - 2] == s[i - 1] || p[j - 2] == '.') && dp[i - 1][j]; // 后第二位使用一次以上
                    dp[i][j] = zero || one;
                }
            }
        }
    }
    return dp[len1][len2];
}

static bool isMatch_2(string s, string p)
{
    return isMatch_2_helper(s, p, 0, 0);
}

static bool isMatch_2_helper(string &s, string &p, int i, int j)
{
    int len1 = (int)s.size();
    int len2 = (int)p.size();
    if (len2 == j) {
        if (len1 == i) {
            return true;
        }
        return false;
    }
    bool one = false;
    bool zero = false;
    if (j + 1 < len2 && p[j + 1] == '*') {       // 遇到*时
        zero = isMatch_2_helper(s, p, i, j + 2); // 使用0次
        if (!zero && (i < len1) && (p[j] == s[i] || p[j] == '.')) {
            one = isMatch_2_helper(s, p, i + 1, j); // 使用多次
        }
        return zero || one;
    } else {
        if ((i < len1) && (p[j] == s[i] || p[j] == '.')) {
            return isMatch_2_helper(s, p, i + 1, j + 1); // 当前字符正常匹配
        } else {
            return false; // 不匹配
        }
    }
    return false;
}

static bool isMatch_god(string s, string p)
{
    if (p.empty()) {
        return s.empty();
    }

    bool first_match = !s.empty() && (s[0] == p[0] || p[0] == '.');

    if (p.length() >= 2 && p[1] == '*') {
        return isMatch(s, p.substr(2)) || (first_match && isMatch(s.substr(1), p));
    } else {
        return first_match && isMatch(s.substr(1), p.substr(1));
    }
}

+ (void)run
{
    NSParameterAssert(isMatch("", ".*") == true);
    NSParameterAssert(isMatch("", ".*b*") == true);
    NSParameterAssert(isMatch("aa", "a") == false);
    NSParameterAssert(isMatch("aa", "a*") == true);
    NSParameterAssert(isMatch("ab", ".*") == true);
    NSParameterAssert(isMatch("aab", "c*a*b") == true);
    NSParameterAssert(isMatch("mississippi", "mis*is*p*.") == false);

    NSParameterAssert(isMatch_2("", ".*") == true);
    NSParameterAssert(isMatch_2("", ".*b*") == true);
    NSParameterAssert(isMatch_2("aa", "a") == false);
    NSParameterAssert(isMatch_2("aa", "a*") == true);
    NSParameterAssert(isMatch_2("ab", ".*") == true);
    NSParameterAssert(isMatch_2("aab", "c*a*b") == true);
    NSParameterAssert(isMatch_2("mississippi", "mis*is*p*.") == false);

    NSParameterAssert(isMatch_god("", ".*") == true);
    NSParameterAssert(isMatch_god("", ".*b*") == true);
    NSParameterAssert(isMatch_god("aa", "a") == false);
    NSParameterAssert(isMatch_god("aa", "a*") == true);
    NSParameterAssert(isMatch_god("ab", ".*") == true);
    NSParameterAssert(isMatch_god("aab", "c*a*b") == true);
    NSParameterAssert(isMatch_god("mississippi", "mis*is*p*.") == false);
}

LC_CLASS_END
