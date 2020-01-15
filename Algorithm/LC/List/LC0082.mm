//
//  LC0082.m
//  DSPro
//
//  Created by SLJ on 2020/1/14.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0082.h"
#import "ListNode.h"

@implementation LC0082

/*
 删除排序链表中的重复元素 II

 给定一个排序链表，删除所有含有重复数字的节点，只保留原始链表中 没有重复出现 的数字。

 示例 1:

 输入: 1->2->3->3->4->4->5
 输出: 1->2->5
 示例 2:

 输入: 1->1->1->2->3
 输出: 2->3
 */
static ListNode *deleteDuplicates(ListNode *head)
{
    if (head == NULL || head->next == NULL) {
        return head;
    }

    ListNode temp = ListNode(-1);
    temp.next = head;

    ListNode *slow = &temp;
    ListNode *fast = head;
    while (fast) {
        if ((fast->next != NULL && fast->val != fast->next->val) || fast->next == NULL) {
            if (slow->next == fast) {
                slow = fast;
            } else {
                slow->next = fast->next;
            }
        }
        fast = fast->next;
    }

    return temp.next;
}

+ (void)run
{
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3, 3, 4, 4, 5});
        ListNode *ret = deleteDuplicates(list);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{});
        ListNode *ret = deleteDuplicates(list);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1, 1, 1, 2, 3});
        ListNode *ret = deleteDuplicates(list);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1, 1});
        ListNode *ret = deleteDuplicates(list);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1});
        ListNode *ret = deleteDuplicates(list);
        ret->print();
    }
}

@end
