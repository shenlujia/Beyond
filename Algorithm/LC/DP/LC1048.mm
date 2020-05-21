//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(1048)

/*
 最长字符串链
 给出一个单词列表，其中每个单词都由小写英文字母组成。
 如果我们可以在 word1 的任何地方添加一个字母使其变成 word2，那么我们认为 word1 是 word2 的前身。例如，"abc" 是 "abac" 的前身。
 词链是单词 [word_1, word_2, ..., word_k] 组成的序列，k >= 1，其中 word_1 是 word_2 的前身，word_2 是 word_3 的前身，依此类推。
 从给定单词列表 words 中选择单词组成词链，返回词链的最长可能长度。

 示例：
 输入：["a","b","ba","bca","bda","bdca"]
 输出：4
 解释：最长单词链之一为 "a","ba","bda","bdca"。
  
 提示：
 1 <= words.length <= 1000
 1 <= words[i].length <= 16
 words[i] 仅由小写英文字母组成。
 */
static int longestStrChain(vector<string>& words)
{
    int len = (int)words.size();
    if (len <= 1) {
        return len;
    }
    sort(words.begin(), words.end(), cmp);

    int ret = 1;
    vector<int> dp(len, 1);
    for (int i = 0; i < len; ++i) {
        for (int j = i + 1; j < len; ++j) {
            if (isNext(words[i], words[j])) {
                dp[j] = max(dp[j],dp[i]+1);
            }
            ret = max(ret, dp[j]);
        }

    }
    return ret;
}

static bool isNext(string& a,string& b)
{
    if (a.size() + 1 != b.size()) {
        return false;
    }
    int chance = true;
    int i = 0;
    int j = 0;
    while (i < a.size() && j < b.size()) {
        if (a[i] == b[j]) {
            ++i;
            ++j;
            continue;
        }

        if (!chance) {
            return false;
        }
        chance = false;
        ++j;
    }
    
    return true;
}

static bool cmp(string& a,string& b)
{
    return a.size()<b.size();
}

+ (void)run
{
    {
        vector<string> v = {"ksqvsyq","ks","kss","czvh","zczpzvdhx","zczpzvh","zczpzvhx","zcpzvh","zczvh","gr","grukmj","ksqvsq","gruj","kssq","ksqsq","grukkmj","grukj","zczpzfvdhx","gru"};
        NSParameterAssert(longestStrChain(v) == 7);
    }
    {
        vector<string> v = {"a","ba","bca","bda","bdca","b"};
        NSParameterAssert(longestStrChain(v) == 4);
    }
}

LC_CLASS_END
