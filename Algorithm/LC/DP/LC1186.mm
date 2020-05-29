//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(1186)

/*
 删除一次得到子数组最大和
 给你一个整数数组，返回它的某个 非空 子数组（连续元素）在执行一次可选的删除操作后，所能得到的最大元素总和。
 换句话说，你可以从原数组中选出一个子数组，并可以决定要不要从中删除一个元素（只能删一次哦），（删除后）子数组中至少应当有一个元素，然后该子数组（剩下）的元素总和是所有子数组之中最大的。
 注意，删除一个元素后，子数组 不能为空。
 请看示例：
 示例 1：
 输入：arr = [1,-2,0,3]
 输出：4
 解释：我们可以选出 [1, -2, 0, 3]，然后删掉 -2，这样得到 [1, 0, 3]，和最大。
 示例 2：
 输入：arr = [1,-2,-2,3]
 输出：3
 解释：我们直接选出 [3]，这就是最大和。
 示例 3：
 输入：arr = [-1,-1,-1,-1]
 输出：-1
 解释：最后得到的子数组不能为空，所以我们不能选择 [-1] 并从中删去 -1 来得到 0。
      我们应该直接选择 [-1]，或者选择 [-1, -1] 再从中删去一个 -1。
 提示：
 1 <= arr.length <= 10^5
 -10^4 <= arr[i] <= 10^4
 */

static int maximumSum(vector<int>& arr)
{
    int len = (int)arr.size();
    if (len == 1) {
        return arr[0];
    }
    
    vector<vector<int>> dp(len, vector<int>(2, 0)); // 0不删除的最大和 1删除某个后的最大和
    dp[0][0] = arr[0];
    dp[0][1] = INT_MIN;
    dp[1][0] = max(arr[1], arr[0] + arr[1]);
    dp[1][1] = max(arr[0], arr[1]);
    int ret = max(dp[0][0], max(dp[1][0], dp[1][1]));
    for (int i = 2; i < len; ++i) {
        dp[i][0] = max(arr[i], dp[i - 1][0] + arr[i]); // 要么从当前数开始，要么从前一个数开始
        dp[i][1] = max(dp[i - 1][1], dp[i - 2][0]) + arr[i]; // 要么删除arr[i-1]之前的任意数, 要么删除arr[i-1]
        ret = max(ret, max(dp[i][0], dp[i][1]));
    }
    
    return ret;
}

+ (void)run
{
    {
        vector<int> v = {2, 1, -2, -5, -2};
        NSCParameterAssert(maximumSum(v) == 3);
    }
    {
        vector<int> v = {1, -2, 0, 3};
        NSCParameterAssert(maximumSum(v) == 4);
    }
    {
        vector<int> v = {-1, -1, -1, -1};
        NSCParameterAssert(maximumSum(v) == -1);
    }
}

LC_CLASS_END
