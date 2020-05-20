//
//  LC0091.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0091.h"
#import <string>
#import <vector>

using namespace std;

@implementation LC0091

/*
 解码方法

 一条包含字母 A-Z 的消息通过以下方式进行了编码：

 'A' -> 1
 'B' -> 2
 ...
 'Z' -> 26
 给定一个只包含数字的非空字符串，请计算解码方法的总数。

 示例 1:

 输入: "12"
 输出: 2
 解释: 它可以解码为 "AB"（1 2）或者 "L"（12）。
 示例 2:
 输入: "226"
 输出: 3
 解释: 它可以解码为 "BZ" (2 26), "VF" (22 6), 或者 "BBF" (2 2 6) 。
 */

static int numDecodings(string s)
{
    vector<int> nums;
    for (int i = 0; i < s.size(); ++i) {
        char c = s[i];
        if ('0' <= c && c <= '9') {
            nums.push_back(c-'0');
        } else {
            return 0;
        }
    }
    int len = (int)nums.size();
    if (len == 0) {
        return 0;
    }
    if (nums[0] == 0) {
        return 0;
    }
    
    vector<int> dp(len+1, 0);
    dp[0] = 1;
    dp[1] = 1;
    for (int i = 2; i <= len; ++i) {
        int current = nums[i-1];
        int previous = nums[i-2];
        int bind = current + previous * 10;
        bool bind_ok = 10 <= bind && bind <= 26;
        if (current == 0) {
            if (bind_ok) {
                dp[i] = dp[i-2];
            } else {
                return 0;
            }
        } else {
            if (bind_ok) {
                dp[i] = dp[i-1] + dp[i-2];
            } else {
                dp[i] = dp[i-1];
            }
        }
    }
    return dp[len];
}

+ (void)run
{
    {
        string s = "12";
        NSParameterAssert(numDecodings(s) == 2);
    }
    {
        string s = "226";
        NSParameterAssert(numDecodings(s) == 3);
    }
}

@end
