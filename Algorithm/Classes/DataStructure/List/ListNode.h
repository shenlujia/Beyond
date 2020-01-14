//
//  ListNode.h
//  DSPro
//
//  Created by SLJ on 2020/1/14.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <vector>

using namespace std;

#ifndef ListNode_h
#define ListNode_h

class ListNode
{
  public:
    int val;
    ListNode *next;
    ListNode(int x);

    // 从 {1,2,4,3,5} 创建
    ListNode(const vector<int> &values);
    // 输出: 1->2->4->3->5
    void print();
};

#endif /* ListNode_h */
