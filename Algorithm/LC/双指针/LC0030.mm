//
//  LC0030.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0030.h"
#import <string>
#import <unordered_map>
#import <vector>

using namespace std;

@implementation LC0030

/*
 串联所有单词的子串

 给定一个字符串 s 和一些长度相同的单词 words。找出 s 中恰好可以由 words 中所有单词串联形成的子串的起始位置。

 注意子串要与 words 中的单词完全匹配，中间不能有其他字符，但不需要考虑 words 中单词串联的顺序。



 示例 1：

 输入：
   s = "barfoothefoobarman",
   words = ["foo","bar"]
 输出：[0,9]
 解释：
 从索引 0 和 9 开始的子串分别是 "barfoo" 和 "foobar" 。
 输出的顺序不重要, [9,0] 也是有效答案。
 示例 2：

 输入：
   s = "wordgoodgoodgoodbestword",
   words = ["word","good","best","word"]
 输出：[]
 */
static vector<int> findSubstring(string s, vector<string> &words)
{
    vector<int> ret;
    if (s.empty() || words.empty()) {
        return ret;
    }

    unordered_map<string, int> word_map;
    for (auto word : words) {
        word_map[word]++;
    }

    int word_len = (int)words[0].size();
    int word_count = (int)words.size();

    for (int k = 0; k < word_len; ++k) {
        int left = k;
        int right = left;
        int count = 0;
        unordered_map<string, int> window;
        while (left + word_len * word_count <= s.length()) {
            string temp = "";
            while (count < word_count) {
                temp = s.substr(right, word_len);
                if (word_map.find(temp) == word_map.end() || window[temp] > word_map[temp]) {
                    break;
                }
                window[temp]++;
                count++;
                right += word_len;
            }
            if (window == word_map) {
                ret.push_back(left);
            }
            if (word_map.find(temp) != word_map.end()) {
                window[s.substr(left, word_len)]--;
                count--;
                left += word_len;
            } else {
                right += word_len;
                left = right;
                count = 0;
                window.clear();
            }
        }
    }

    return ret;
}

static vector<int> findSubstring_noob(string s, vector<string> &words)
{
    vector<int> ret;
    if (s.empty() || words.empty()) {
        return ret;
    }

    unordered_map<string, int> word_map;
    for (auto word : words) {
        word_map[word]++;
    }

    int len = (int)words[0].size();

    sort(words.begin(), words.end());

    for (int i = 0; i + len * words.size() <= s.length(); ++i) {
        vector<string> temp;
        for (int j = 0; j < words.size(); ++j) {
            temp.push_back(s.substr(i + j * len, len));
        }
        sort(temp.begin(), temp.end());
        if (temp == words) {
            ret.push_back(i);
        }
    }

    return ret;
}

+ (void)run
{
    {
        vector<string> v = {"foo", "bar"};
        vector<int> ret1 = findSubstring("barfoothefoobarman", v);
        vector<int> ret2 = findSubstring_noob("barfoothefoobarman", v);
        vector<int> to = {0, 9};
        NSParameterAssert(ret1 == to && ret2 == to);
    }
    {
        vector<string> v = {"word", "good", "best", "word"};
        vector<int> ret1 = findSubstring("wordgoodgoodgoodbestword", v);
        vector<int> ret2 = findSubstring_noob("wordgoodgoodgoodbestword", v);
        vector<int> to = {};
        NSParameterAssert(ret1 == to && ret2 == to);
    }
    {
        vector<string> v = {"bar", "foo", "the"};
        vector<int> ret1 = findSubstring("barfoofoobarthefoobarman", v);
        vector<int> ret2 = findSubstring_noob("barfoofoobarthefoobarman", v);
        vector<int> to = {6, 9, 12};
        NSParameterAssert(ret1 == to && ret2 == to);
    }
    {
        vector<string> v = {"word", "good", "best", "good"};
        vector<int> ret1 = findSubstring("wordgoodgoodgoodbestword", v);
        vector<int> ret2 = findSubstring_noob("wordgoodgoodgoodbestword", v);
        vector<int> to = {8};
        NSParameterAssert(ret1 == to && ret2 == to);
    }
}

@end
