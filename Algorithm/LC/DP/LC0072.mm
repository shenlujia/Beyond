//
//  LC0072.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0072.h"
#import <string>
#import <vector>

using namespace std;

@implementation LC0072

/*
 编辑距离

 给定两个单词 word1 和 word2，计算出将 word1 转换成 word2 所使用的最少操作数 。

 你可以对一个单词进行如下三种操作：

 插入一个字符
 删除一个字符
 替换一个字符
 示例 1:

 输入: word1 = "horse", word2 = "ros"
 输出: 3
 解释:
 horse -> rorse (将 'h' 替换为 'r')
 rorse -> rose (删除 'r')
 rose -> ros (删除 'e')
 示例 2:

 输入: word1 = "intention", word2 = "execution"
 输出: 5
 解释:
 intention -> inention (删除 't')
 inention -> enention (将 'i' 替换为 'e')
 enention -> exention (将 'n' 替换为 'x')
 exention -> exection (将 'n' 替换为 'c')
 exection -> execution (插入 'u')
 */
static int minDistance(string word1, string word2)
{
    int len1 = (int)word1.size();
    int len2 = (int)word2.size();
    if (len1 == 0) {
        return len2;
    }
    if (len2 == 0) {
        return len1;
    }
    vector<vector<int>> dp(len1 + 1, vector<int>(len2 + 1, 0));
    for (int i = 1; i <= len1; ++i) {
        dp[i][0] = i;
    }
    for (int j = 1; j <= len2; ++j) {
        dp[0][j] = j;
    }
    for (int i = 1; i <= len1; ++i) {
        for (int j = 1; j <= len2; ++j) {
            if (word1[i - 1] == word2[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1];
            } else {
                int temp = min(dp[i][j - 1], dp[i - 1][j]);
                dp[i][j] = min(temp, dp[i - 1][j - 1]) + 1;
            }
        }
    }
    return dp[len1][len2];
}

+ (void)run
{
    {
        string s1 = "intention";
        string s2 = "execution";
        NSParameterAssert(minDistance(s1, s2) == 5);
    }
    {
        string s1 = "horse";
        string s2 = "ros";
        NSParameterAssert(minDistance(s1, s2) == 3);
    }
    {
        string s1 = "ab";
        string s2 = "ac";
        NSParameterAssert(minDistance(s1, s2) == 1);
    }
    {
        string s1 = "a";
        string s2 = "a";
        NSParameterAssert(minDistance(s1, s2) == 0);
    }
}

@end
