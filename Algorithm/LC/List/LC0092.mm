//
//  LC0092.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0092.h"
#import "ListNode.h"

@implementation LC0092

/*
 反转链表 II

 反转从位置 m 到 n 的链表。请使用一趟扫描完成反转。

 说明:
 1 ≤ m ≤ n ≤ 链表长度。

 示例:

 输入: 1->2->3->4->5->NULL, m = 2, n = 4
 输出: 1->4->3->2->5->NULL
 */
static ListNode *reverseBetween(ListNode *head, int m, int n)
{
    if (head == nullptr || head->next == nullptr) {
        return head;
    }
    if (m <= 0 || n <= 0 || m >= n) {
        return head;
    }

    ListNode *dummy = new ListNode(-1);
    ListNode *pre = dummy;
    dummy->next = head;
    n = n - m;
    while (--m > 0) {
        pre = pre->next; // eg 1->2->3->4->5->NULL, m = 2, n = 4 pre指向1
    }
    ListNode *cur = pre->next; // cur指向2
    while (n-- > 0) {
        ListNode *tmp = cur->next; //记录3->4->5->NULL
        cur->next = tmp->next;     //断开2->3,实现2->4
        tmp->next = pre->next;     //断开3->4,实现3->2
        pre->next = tmp;           //断开1->2,实现1->3， 一次循环后变为1->3->2->4->5->NULL，下次循环原理相同
    }
    return dummy->next;
}

+ (void)run
{
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3, 4, 5});
        ListNode *ret = reverseBetween(list, 2, 4);
        ret->print();
    }
}

@end
