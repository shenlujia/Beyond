//
//  LC0986.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0986.h"
#import <vector>

using namespace std;

@implementation LC0986

/*
 区间列表的交集
 给定两个由一些闭区间组成的列表，每个区间列表都是成对不相交的，并且已经排序。

 返回这两个区间列表的交集。

 （形式上，闭区间 [a, b]（其中 a <= b）表示实数 x 的集合，而 a <= x <= b。两个闭区间的交集是一组实数，要么为空集，要么为闭区间。例如，[1, 3] 和 [2, 4] 的交集为
 [2, 3]。）

 示例：

 输入：A = [[0,2],[5,10],[13,23],[24,25]], B = [[1,5],[8,12],[15,24],[25,26]]
 输出：[[1,2],[5,5],[8,10],[15,23],[24,24],[25,25]]
 注意：输入和所需的输出都是区间对象组成的列表，而不是数组或列表。


 提示：

 0 <= A.length < 1000
 0 <= B.length < 1000
 0 <= A[i].start, A[i].end, B[i].start, B[i].end < 10^9
 */
static vector<vector<int>> intervalIntersection(vector<vector<int>> &A, vector<vector<int>> &B)
{
    vector<vector<int>> ret;
    int i = 0;
    int j = 0;
    while (i < A.size() && j < B.size()) {
        vector<int> &a = A[i];
        vector<int> &b = B[j];
        int a1 = a[0];
        int a2 = a[1];
        int b1 = b[0];
        int b2 = b[1];
        if (a2 < b1) {
            ++i;
            continue;
        }
        if (a1 > b2) {
            ++j;
            continue;
        }
        vector<int> one;
        one.push_back(max(a1, b1));
        one.push_back(min(a2, b2));
        ret.push_back(one);
        if (a2 > b2) {
            ++j;
        } else {
            ++i;
        }
    }
    return ret;
}

+ (void)run
{
}

@end
