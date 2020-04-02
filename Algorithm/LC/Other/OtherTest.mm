//
//  BinaryTreeTest.m
//  DSPro
//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "OtherTest.h"
#import <deque>
#import <queue>
#import <stack>
#import <vector>

using namespace std;

// 单调栈 Monotonic Stack
// Next Greater Number 的原始问题：给你一个数组，返回一个等长的数组，对应索引存储着下一个更大元素，如果没有更大的元素，就存
// -1。不好用语言解释清楚，直接上一个例子：
// 给你一个数组 [2,1,2,4,3]，你返回数组 [4,2,4,-1,-1]。
vector<int> nextGreaterElement(vector<int> &nums)
{
    if (nums.empty()) {
        return vector<int>();
    }
    vector<int> ret(nums.size(), 0);
    stack<int> s;
    for (int i = (int)nums.size() - 1; i >= 0; --i) {
        while (!s.empty() && s.top() <= nums[i]) {
            s.pop();
        }
        if (s.empty()) {
            ret[i] = -1;
        } else {
            ret[i] = s.top();
        }
        s.push(nums[i]);
    }
    return ret;
}

@implementation OtherTest

+ (void)run
{
    vector<int> v = {};

    for (int i = 0; i < v.size(); ++i) {
        int value = v[i];
        NSString *name = [NSString stringWithFormat:@"%04d", value];
        Class c = NSClassFromString([NSString stringWithFormat:@"LC%@", name]);
        printf("====== %s ======", name.UTF8String);
        NSParameterAssert(c);
        [c performSelector:@selector(run)];
        printf("\n\n");
    }

    {
        vector<int> input = {2, 1, 2, 4, 3};
        vector<int> output = {4, 2, 4, -1, -1};
        NSParameterAssert(output == nextGreaterElement(input));
    }
}

@end
