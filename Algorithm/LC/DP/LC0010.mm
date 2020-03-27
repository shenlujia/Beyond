//
//  LC0010.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0010.h"
#import <math.h>
#import <string>
#import <vector>

using namespace std;

@implementation LC0010

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
    int ns = (int)s.length();
    int np = (int)p.length();

    if (p.empty()) {
        return s.empty();
    }

    vector<vector<int>> dp(ns + 1, vector<int>(np + 1, 0));
    dp[0][0] = 1;
    for (int i = 1; i <= np; i++) {
        if (i - 2 >= 0 && p[i - 1] == '*' && p[i - 2]) {
            dp[0][i] = dp[0][i - 2];
        }
    }

    for (int i = 1; i <= ns; i++) {
        for (int j = 1; j <= np; j++) {
            if (p[j - 1] == s[i - 1] || p[j - 1] == '.')
                dp[i][j] = dp[i - 1][j - 1];
            if (p[j - 1] == '*') {
                bool zero, one;
                if (j - 2 >= 0) {
                    zero = dp[i][j - 2];
                    one = (p[j - 2] == s[i - 1] || p[j - 2] == '.') && dp[i - 1][j];
                    if (zero > 0 || one > 0) {
                        dp[i][j] = 1;
                    }
                }
            }
        }
    }
    return dp[ns][np] > 0;
}

static bool isMatch_2(string s, string p)
{
    return isMatch_2_helper(s, p, 0, 0);
}

static bool isMatch_2_helper(string &s, string &p, int i, int j)
{
    int ns = (int)s.size();
    int np = (int)p.size();
    if (np == j) {
        if (ns == i)
            return true;
        return false;
    }
    bool one = false, zero = false;
    if (j + 1 < np && p[j + 1] == '*') {         // 遇到*时
        zero = isMatch_2_helper(s, p, i, j + 2); // 使用0次
        if (!zero && (i < ns) && (p[j] == s[i] || p[j] == '.')) {
            one = isMatch_2_helper(s, p, i + 1, j); // 使用多次
        }
        return zero || one;
    } else {
        if ((i < ns) && (p[j] == s[i] || p[j] == '.')) {
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
    NSParameterAssert(isMatch("aa", "a") == false);
    NSParameterAssert(isMatch("aa", "a*") == true);
    NSParameterAssert(isMatch("ab", ".*") == true);
    NSParameterAssert(isMatch("aab", "c*a*b") == true);
    NSParameterAssert(isMatch("mississippi", "mis*is*p*.") == false);

    NSParameterAssert(isMatch_2("aa", "a") == false);
    NSParameterAssert(isMatch_2("aa", "a*") == true);
    NSParameterAssert(isMatch_2("ab", ".*") == true);
    NSParameterAssert(isMatch_2("aab", "c*a*b") == true);
    NSParameterAssert(isMatch_2("mississippi", "mis*is*p*.") == false);

    NSParameterAssert(isMatch_god("aa", "a") == false);
    NSParameterAssert(isMatch_god("aa", "a*") == true);
    NSParameterAssert(isMatch_god("ab", ".*") == true);
    NSParameterAssert(isMatch_god("aab", "c*a*b") == true);
    NSParameterAssert(isMatch_god("mississippi", "mis*is*p*.") == false);
}

@end
