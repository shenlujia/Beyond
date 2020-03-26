//
//  LC0032.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0032.h"
#import <stack>
#import <string>
#import <vector>

using namespace std;

@implementation LC0032

/*
 最长有效括号

 给定一个只包含 '(' 和 ')' 的字符串，找出最长的包含有效括号的子串的长度。

 示例 1:

 输入: "(()"
 输出: 2
 解释: 最长有效括号子串为 "()"
 示例 2:

 输入: ")()())"
 输出: 4
 解释: 最长有效括号子串为 "()()"
 */
static int longestValidParentheses_stack(string s)
{
    stack<int> m_stack;
    m_stack.push(-1);
    int max = 0;
    for (int i = 0; i < s.length(); ++i) {
        if (s[i] == '(') {
            m_stack.push(i);
        } else {
            m_stack.pop();
            if (m_stack.empty()) {
                m_stack.push(i);
            } else {
                int count = i - m_stack.top();
                if (max < count) {
                    max = count;
                }
            }
        }
    }
    return max;
}

static int longestValidParentheses_double_pointer(string s)
{
    int max = 0;
    int left = 0;
    int right = 0;
    for (int i = 0; i < s.length(); ++i) {
        if (s[i] == '(') {
            left++;
        } else {
            right++;
        }
        if (left == right) {
            if (max < right * 2) {
                max = right * 2;
            }
        } else if (right > left) {
            left = right = 0;
        }
    }

    left = right = 0;
    for (int i = (int)s.length() - 1; i >= 0; --i) {
        if (s[i] == '(') {
            left++;
        } else {
            right++;
        }
        if (left == right) {
            if (max < right * 2) {
                max = right * 2;
            }
        } else if (left > right) {
            left = right = 0;
        }
    }
    return max;
}

static bool isFullValid(string &s)
{
    stack<char> m_stack;
    for (auto c : s) {
        if (c == '(') {
            m_stack.push(c);
        } else {
            if (m_stack.empty()) {
                return false;
            } else {
                m_stack.pop();
            }
        }
    }
    return m_stack.empty();
}

static int longestValidParentheses_noob(string s)
{
    int len = (int)s.size();
    int max = 0;
    for (int i = 0; i < len; ++i) {
        for (int j = i + 2; j <= len; ++j) {
            string substring = s.substr(i, j - i);
            if (isFullValid(substring)) {
                if (max < substring.length()) {
                    max = (int)substring.length();
                }
            }
        }
    }
    return max;
}

static int longestValidParentheses_dp(string s)
{
    int len = (int)s.size();
    vector<int> dp(len, 0);

    int max = 0;
    for (int i = 1; i < len; ++i) {
        if (s[i] == ')') {
            if (s[i - 1] == '(') {
                if (i >= 2) {
                    dp[i] = dp[i - 2] + 2;
                } else {
                    dp[i] = 2;
                }
            } else {
                int pre_index = i - dp[i - 1] - 1;
                if (pre_index >= 0 && s[pre_index] == '(') {
                    if (pre_index >= 1) {
                        dp[i] = dp[i - 1] + dp[pre_index - 1] + 2;
                    } else {
                        dp[i] = dp[i - 1] + 2;
                    }
                }
            }
            if (max < dp[i]) {
                max = dp[i];
            }
        }
    }
    return max;
}

+ (void)run
{
    NSParameterAssert(longestValidParentheses_stack(")()())") == 4);
    NSParameterAssert(longestValidParentheses_stack("(()") == 2);
    NSParameterAssert(longestValidParentheses_stack("()(()") == 2);

    NSParameterAssert(longestValidParentheses_noob(")()())") == 4);
    NSParameterAssert(longestValidParentheses_noob("(()") == 2);
    NSParameterAssert(longestValidParentheses_noob("()(()") == 2);

    NSParameterAssert(longestValidParentheses_double_pointer(")()())") == 4);
    NSParameterAssert(longestValidParentheses_double_pointer("(()") == 2);
    NSParameterAssert(longestValidParentheses_double_pointer("()(()") == 2);

    NSParameterAssert(longestValidParentheses_dp(")()())") == 4);
    NSParameterAssert(longestValidParentheses_dp("(()") == 2);
    NSParameterAssert(longestValidParentheses_dp("()(()") == 2);
}

@end
