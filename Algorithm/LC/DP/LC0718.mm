//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0718)

/*
 最长重复子数组
 给两个整数数组 A 和 B ，返回两个数组中公共的、长度最长的子数组的长度。
 示例 1:
 输入:
 A: [1,2,3,2,1]
 B: [3,2,1,4,7]
 输出: 3
 解释:
 长度最长的公共子数组是 [3, 2, 1]。
 说明:
 1 <= len(A), len(B) <= 1000
 0 <= A[i], B[i] < 100
 */

static int findLength(vector<int>& A, vector<int>& B)
{
    int m = (int)A.size();
    int n = (int)B.size();
    vector<vector<int>> dp(m + 1, vector<int>(n + 1, 0));
    int ret = 0;
    for (int i = 1; i <= m; ++i) {
        for (int j = 1; j <= n; ++j) {
            if (A[i - 1] == B[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1] + 1;
                ret = max(ret, dp[i][j]);
            }
        }
    }
    return ret;
}

+ (void)run
{
    {
        vector<int> v1 = {0, 1, 1, 1, 1};
        vector<int> v2 = {1, 0, 1, 0, 1};
        NSCParameterAssert(findLength(v1, v2) == 2);
    }
    {
        vector<int> v1 = {1, 2, 3, 2, 1};
        vector<int> v2 = {3, 2, 1, 4, 7};
        NSCParameterAssert(findLength(v1, v2) == 3);
    }
}

LC_CLASS_END
