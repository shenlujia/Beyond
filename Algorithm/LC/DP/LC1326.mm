//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(1326)

/*
 单词拆分

 给定一个非空字符串 s 和一个包含非空单词列表的字典 wordDict，判定 s 是否可以被空格拆分为一个或多个在字典中出现的单词。
 说明：
 拆分时可以重复使用字典中的单词。
 你可以假设字典中没有重复的单词。
 示例 1：
 输入: s = "leetcode", wordDict = ["leet", "code"]
 输出: true
 解释: 返回 true 因为 "leetcode" 可以被拆分成 "leet code"。
 示例 2：
 输入: s = "applepenapple", wordDict = ["apple", "pen"]
 输出: true
 解释: 返回 true 因为 "applepenapple" 可以被拆分成 "apple pen apple"。
      注意你可以重复使用字典中的单词。
 示例 3：
 输入: s = "catsandog", wordDict = ["cats", "dog", "sand", "and", "cat"]
 输出: false
 */

static bool wordBreak(string s, vector<string>& wordDict)
{
    int len = (int)s.size();
    vector<bool> dp(len + 1, false);
    dp[0] = true;
    int max_valid_start = 0;
    for (int i = 0; i < len; ++i) {
        if (dp[i] == false) {
            continue;
        }
        for (int j = 0; j < wordDict.size(); ++j) {
            string &other = wordDict[j];
            bool ok = word_equal(s, i, other);
            if (ok) {
                int next_start = i + (int)other.size();
                if (len == next_start) {
                    return true;
                }
                dp[next_start] = true;
                max_valid_start = max(max_valid_start, next_start);
            }
        }
    }
    return false;
}

static bool word_equal(string &s, int start, string &other)
{
    int len = (int)other.size();
    for (int i = 0; i < len; ++i) {
        if (s[i + start] != other[i]) {
            return false;
        }
    }
    return true;
}

+ (void)run
{
    {
        vector<string> v = {"leet", "code"};
        NSParameterAssert(wordBreak("leetcode", v) == true);
    }
    {
        vector<string> v = {"apple", "pen"};
        NSParameterAssert(wordBreak("applepenapple", v) == true);
    }
    {
        vector<string> v = {"cats", "dog", "sand", "and", "cat"};
        NSParameterAssert(wordBreak("catsandog", v) == false);
    }
}

LC_CLASS_END
