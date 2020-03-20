//
//  LC0003.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0003.h"
#import <string>
#import <vector>

using namespace std;

@implementation LC0003

/*
 给定一个字符串，请你找出其中不含有重复字符的 最长子串 的长度。

 示例 1:

 输入: "abcabcbb"
 输出: 3
 解释: 因为无重复字符的最长子串是 "abc"，所以其长度为 3。
 示例 2:

 输入: "bbbbb"
 输出: 1
 解释: 因为无重复字符的最长子串是 "b"，所以其长度为 1。
 示例 3:

 输入: "pwwkew"
 输出: 3
 解释: 因为无重复字符的最长子串是 "wke"，所以其长度为 3。
      请注意，你的答案必须是 子串 的长度，"pwke" 是一个子序列，不是子串。
 */
static int lengthOfLongestSubstring(string s)
{
    int max = 0;
    int left = 0;
    for (int right = 0; right < s.size(); ++right) {
        for (int i = left; i < right; ++i) {
            if (s[i] == s[right]) {
                left = i + 1;
                break;
            }
        }
        int len = right - left + 1;
        if (max < len) {
            max = len;
        }
    }
    return max;
}

+ (void)run
{
    NSParameterAssert(lengthOfLongestSubstring("pwwkew") == 3);
}

@end
