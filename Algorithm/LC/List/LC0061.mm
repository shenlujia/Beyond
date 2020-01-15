//
//  LC0061.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0061.h"
#import "ListNode.h"

@implementation LC0061

/*
 旋转链表

 给定一个链表，旋转链表，将链表每个节点向右移动 k 个位置，其中 k 是非负数。

 示例 1:

 输入: 1->2->3->4->5->NULL, k = 2
 输出: 4->5->1->2->3->NULL
 解释:
 向右旋转 1 步: 5->1->2->3->4->NULL
 向右旋转 2 步: 4->5->1->2->3->NULL
 示例 2:

 输入: 0->1->2->NULL, k = 4
 输出: 2->0->1->NULL
 解释:
 向右旋转 1 步: 2->0->1->NULL
 向右旋转 2 步: 1->2->0->NULL
 向右旋转 3 步: 0->1->2->NULL
 向右旋转 4 步: 2->0->1->NULL
 */
static ListNode *rotateRight(ListNode *head, int k)
{
    if (head == nullptr || head->next == nullptr || k <= 0) {
        return head;
    }

    ListNode *cur = head;
    int count = 0;
    while (cur) {
        ++count;
        if (cur->next == nullptr) {
            cur->next = head;
            break;
        }
        cur = cur->next;
    }

    count = count - k % count;
    while (count > 0) {
        --count;
        cur = cur->next;
    }
    ListNode *ret = cur->next;
    cur->next = nullptr;

    return ret;
}

+ (void)run
{
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3});
        ListNode *ret = rotateRight(list, 3);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3});
        ListNode *ret = rotateRight(list, 1);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3, 4});
        ListNode *ret = rotateRight(list, 2);
        ret->print();
    }
}

@end
