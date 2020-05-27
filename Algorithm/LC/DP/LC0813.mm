//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0813)

/*
 最大平均值和的分组
 我们将给定的数组 A 分成 K 个相邻的非空子数组 ，我们的分数由每个子数组内的平均值的总和构成。计算我们所能得到的最大分数是多少。
 注意我们必须使用 A 数组中的每一个数进行分组，并且分数不一定需要是整数。
 示例:
 输入:
 A = [9,1,2,3,9]
 K = 3
 输出: 20
 解释:
 A 的最优分组是[9], [1, 2, 3], [9]. 得到的分数是 9 + (1 + 2 + 3) / 3 + 9 = 20.
 我们也可以把 A 分成[9, 1], [2], [3, 9].
 这样的分组得到的分数为 5 + 2 + 6 = 13, 但不是最大值.
 说明:
 1 <= A.length <= 100.
 1 <= A[i] <= 10000.
 1 <= K <= A.length.
 答案误差在 10^-6 内被视为是正确的。
 */

static double largestSumOfAverages(vector<int>& A, int K)
{
    int len = (int)A.size();
    
    vector<double> sum(len + 1, 0);
    vector<vector<double>> dp(len + 1, vector<double>(K + 1, 0));
    for (int i = 1; i <= len; ++i) {
        sum[i] = sum[i - 1] + A[i - 1];
        dp[i][1] = sum[i] / i;
    }

    for (int i = 1; i <= len; ++i) {
        for (int k = 2; k <= K; ++k) {
            for (int j = 1; j < i; ++j) {
                double suffix = (sum[i] - sum[j]) / (i - j);
                dp[i][k] = max(dp[i][k], dp[j][k - 1] + suffix);
            }
        }
    }
    
    return dp[len][K];
}

+ (void)run
{
    {
        vector<int> v = {3, 1, 2};
        NSCParameterAssert(largestSumOfAverages(v, 2) == 4.5);
    }
    {
        vector<int> v = {9, 1, 2, 3, 9};
        NSCParameterAssert(largestSumOfAverages(v, 3) == 20);
    }
}

LC_CLASS_END
