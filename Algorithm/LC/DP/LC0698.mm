//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

LC_CLASS_BEGIN(0698)

/*
 划分为k个相等的子集
 给定一个整数数组  nums 和一个正整数 k，找出是否有可能把这个数组分成 k 个非空子集，其总和都相等。
 示例 1：
 输入： nums = [4, 3, 2, 3, 5, 2, 1], k = 4
 输出： True
 说明： 有可能将其分成 4 个子集（5），（1,4），（2,3），（2,3）等于总和。

 提示：
 1 <= k <= len(nums) <= 16
 0 < nums[i] < 10000
 */

static bool canPartitionKSubsets(vector<int>& nums, int k)
{
    // 应该是回溯 todo...
    int target = 0;
    for(auto x:nums) target += x;
    if(target%k) return false;
    target /= k;
    
    sort(nums.begin(),nums.end(),greater<int>());
    
    int n = (int)nums.size();
    vector<int> path;
    
    function<bool(int)> dfs = [&] (int u) {
        if(u==n) return true;
        if(nums[u] > target) return false;
        
        for(int i = 0 ; i < path.size() ; i++) {
            if(path[i] + nums[u] > target) continue;
            path[i]+=nums[u];
            if(dfs(u+1)) return true;
            path[i]-=nums[u];
        }
        if(path.size() == k) return false;
        
        path.push_back(nums[u]);
        if(dfs(u+1)) return true;
        path.pop_back();
        return false;
    };
    return dfs(0);
}

+ (void)run
{
    {
        vector<int> v = {4, 3, 2, 3, 5, 2, 1};
        NSParameterAssert(canPartitionKSubsets(v, 4) == true);
    }
    {
        vector<int> v = {10, 10, 10, 7, 7, 7, 7, 7, 7, 6, 6, 6};
        NSParameterAssert(canPartitionKSubsets(v, 3) == true);
    }
}

LC_CLASS_END
