//
//  LC0646.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <math.h>
#import <string>
#import <vector>
#import <Foundation/Foundation.h>

using namespace std;

@interface LC0646 : NSObject

@end

@implementation LC0646

/*
 最长数对链

 给出 n 个数对。 在每一个数对中，第一个数字总是比第二个数字小。
 现在，我们定义一种跟随关系，当且仅当 b < c 时，数对(c, d) 才可以跟在 (a, b) 后面。我们用这种形式来构造一个数对链。
 给定一个对数集合，找出能够形成的最长数对链的长度。你不需要用到所有的数对，你可以以任何顺序选择其中的一些数对来构造。

 示例 :
 输入: [[1,2], [2,3], [3,4]]
 输出: 2
 解释: 最长的数对链是 [1,2] -> [3,4]
 注意：

 给出数对的个数在 [1, 1000] 范围内。
 */

static int findLongestChain(vector<vector<int>>& pairs)
{
    sort(pairs.begin(), pairs.end(), cmp);
    int len = (int)pairs.size();
    if (len <= 1) {
        return len;
    }
    vector<int> dp(len,1);
    for (int i = 1; i < len; ++i) {
        for (int j = 0; j < i; ++j) {
            if (pairs[j][1] < pairs[i][0]) {
                dp[i] = max(dp[i], dp[j] + 1);
            }
        }
    }
    return dp[len-1];
}

static bool cmp(const vector<int> &a, const vector<int> &b)
{
    return a[0] < b[0];
}

+ (void)run
{
    {
        vector<vector<int>> v = {{5,6},{1,2},{2,3},{3,4}};
        NSParameterAssert(findLongestChain(v) == 3);
    }
    {
        vector<vector<int>> v = {{1,2},{2,3},{3,4}};
        NSParameterAssert(findLongestChain(v) == 2);
    }
}

@end
