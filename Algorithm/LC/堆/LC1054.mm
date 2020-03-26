//
//  LC1054.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC1054.h"
#import <queue>
#import <unordered_map>
#import <vector>

using namespace std;

@implementation LC1054

/*
 距离相等的条形码

 在一个仓库里，有一排条形码，其中第 i 个条形码为 barcodes[i]。

 请你重新排列这些条形码，使其中两个相邻的条形码 不能 相等。 你可以返回任何满足该要求的答案，此题保证存在答案。



 示例 1：

 输入：[1,1,1,2,2,2]
 输出：[2,1,2,1,2,1]
 示例 2：

 输入：[1,1,1,1,2,2,3,3]
 输出：[1,3,1,3,2,1,2,1]


 提示：

 1 <= barcodes.length <= 10000
 1 <= barcodes[i] <= 10000
 */
static vector<int> rearrangeBarcodes(vector<int> &barcodes)
{
    unordered_map<int, int> hash_map;
    for (auto value : barcodes) {
        if (hash_map.find(value) == hash_map.end()) {
            hash_map[value] = 1;
        } else {
            hash_map[value]++;
        }
    }

    priority_queue<pair<int, int>> pq;
    for (auto entry : hash_map) {
        pq.push(make_pair(entry.second, entry.first));
    }

    vector<int> ret;
    while (pq.size() >= 2) {
        auto top1 = pq.top();
        pq.pop();
        auto top2 = pq.top();
        pq.pop();
        ret.push_back(top1.second);
        ret.push_back(top2.second);
        top1.first--;
        top2.first--;
        if (top1.first > 0) {
            pq.push(top1);
        }
        if (top2.first > 0) {
            pq.push(top2);
        }
    }
    if (pq.size() > 0) {
        auto top = pq.top();
        ret.push_back(top.second);
    }

    return ret;
}

+ (void)run
{
    vector<int> codes = {1, 1, 1, 2, 2, 2};
    vector<int> ret = rearrangeBarcodes(codes);
    NSParameterAssert(ret[0] == 2);
}

@end
