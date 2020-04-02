//
//  LC0076.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0076.h"
#import <string>
#import <unordered_map>
#import <vector>

using namespace std;

@implementation LC0076

/*
 最小覆盖子串

 给你一个字符串 S、一个字符串 T，请在字符串 S 里面找出：包含 T 所有字母的最小子串。

 示例：

 输入: S = "ADOBECODEBANC", T = "ABC"
 输出: "BANC"
 说明：

 如果 S 中不存这样的子串，则返回空字符串 ""。
 如果 S 中存在这样的子串，我们保证它是唯一的答案。
 */
static string minWindow_noob(string s, string t)
{
    // 比较暴力 会超时
    string ret;
    if (s.empty() || t.empty()) {
        return ret;
    }
    
    unordered_map<char, int> to;
    for (int i = 0; i < t.size(); ++i) {
        to[t[i]]++;
    }
    
    int len = (int)s.size();
    int left = 0;
    int right = 0;
    while (left < len && right < len) {
        unordered_map<char, int> temp;
        for (int i = left; i <= right; ++i) {
            char c = s[i];
            temp[c]++;
        }
        bool ok = true;
        for (auto it = to.begin(); it != to.end(); ++it) {
            if (temp[it->first] < it->second) {
                ok = false;
                break;
            }
        }
        if (ok) {
            string sub_s = s.substr(left, right - left + 1);
            if (ret.empty()) {
                ret = sub_s;
            }
            if (ret.size() > sub_s.size()) {
                ret = sub_s;
            }
            left++;
        } else {
            right++;
        }
    }
    
    return ret;
}

static string minWindow(string s, string t)
{
    if (s.empty() || t.empty()) {
        return "";
    }
    
    unordered_map<char, int> to;
    for (int i = 0; i < t.size(); ++i) {
        to[t[i]]++;
    }
    
    int len = (int)s.size();
    int left = 0;
    int right = 0;
    unordered_map<char, int> window;
    int start = 0;
    int min_len = INT_MAX;
    int match_count = 0;
    while (right < len) {
        char c = s[right];
        if (to.count(c)) {
            window[c]++;
            if (window[c] == to[c]) {
                match_count++;
            }
        }
        right++;
        
        while (match_count == to.size() && left < right) {
            int current_len = right - left;
            if (min_len > current_len) {
                min_len = current_len;
                start = left;
            }
            
            char c_left = s[left];
            if (to.count(c_left)) {
                window[c_left]--;
                if (window[c_left] < to[c_left]) {
                    match_count--;
                }
            }
            left++;
        }
    }
    
    return min_len == INT_MAX ? "" : s.substr(start, min_len);
}

+ (void)run
{
    {
        string s0 = minWindow("ADOBECODEBANC", "ABC");
        string s1 = minWindow_noob("ADOBECODEBANC", "ABC");
        NSParameterAssert(s0 == s1 && s0 == "BANC");
    }
    {
        string s0 = minWindow("ADOBECODEBANC", "ABCD");
        string s1 = minWindow_noob("ADOBECODEBANC", "ABCD");
        NSParameterAssert(s0 == s1 && s0 == "ADOBEC");
    }
    {
        string s0 = minWindow("ADOBECODEBANC", "ABCDG");
        string s1 = minWindow_noob("ADOBECODEBANC", "ABCDG");
        NSParameterAssert(s0 == s1 && s0 == "");
    }
}

@end
