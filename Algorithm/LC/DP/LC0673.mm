//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0673)

/*
 最长递增子序列的个数

 给定一个未排序的整数数组，找到最长递增子序列的个数。
 示例 1:
 输入: [1,3,5,4,7]
 输出: 2
 解释: 有两个最长递增子序列，分别是 [1, 3, 4, 7] 和[1, 3, 5, 7]。
 示例 2:
 输入: [2,2,2,2,2]
 输出: 5
 解释: 最长递增子序列的长度是1，并且存在5个子序列的长度为1，因此输出5。
 注意: 给定的数组长度不超过 2000 并且结果一定是32位有符号整数。
 */

static int findNumberOfLIS(vector<int>& nums)
{
    int len = (int)nums.size();
    if (len <= 1) {
        return len;
    }
    vector<int> dp_count(len, 1); // 每个index对应的最大长度的个数
    vector<int> dp_len(len, 1); // 每个index对应的最大长度
    int max_len = 1;
    for (int i = 1; i < len; ++i) {
        for (int j = 0; j < i; ++j) {
            if (nums[i] > nums[j]) {
                int current_len = dp_len[j] + 1;
                if (dp_len[i] == current_len) {
                    dp_count[i] += dp_count[j];
                } else if (dp_len[i] < current_len) {
                    dp_len[i] = current_len;
                    dp_count[i] = dp_count[j];
                }
                max_len = max(current_len, max_len);
            }
        }
    }
    int ret = 0;
    for (int i = 0; i < len; ++i) {
        if (dp_len[i] == max_len) {
            ret += dp_count[i];
        }
    }
    return ret;
}

+ (void)run
{
    {
        vector<int> v = {1, 2, 4, 3, 5, 4, 7, 2};
        NSParameterAssert(findNumberOfLIS(v) == 3);
    }
    {
        vector<int> v = {1, 3, 5, 4, 7};
        NSParameterAssert(findNumberOfLIS(v) == 2);
    }
    {
        vector<int> v = {2, 2, 2, 2, 2};
        NSParameterAssert(findNumberOfLIS(v) == 5);
    }
}

LC_CLASS_END
