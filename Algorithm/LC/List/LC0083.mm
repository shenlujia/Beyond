//
//  LC0083.m
//  DSPro
//
//  Created by SLJ on 2020/1/14.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0083.h"
#import "ListNode.h"

@implementation LC0083

/*
 删除排序链表中的重复元素

 给定一个排序链表，删除所有重复的元素，使得每个元素只出现一次。

 示例 1:

 输入: 1->1->2
 输出: 1->2
 示例 2:

 输入: 1->1->2->3->3
 输出: 1->2->3
 */
static ListNode *deleteDuplicates(ListNode *head)
{
    if (head == NULL || head->next == NULL) {
        return head;
    }

    ListNode *current = head;
    while (1) {
        if (current == NULL || current->next == NULL) {
            break;
        }
        ListNode *next = current->next;
        if (current->val == next->val) {
            current->next = next->next;
        } else {
            current = current->next;
        }
    }

    return head;
}

+ (void)run
{
    {
        ListNode *list = new ListNode(vector<int>{1, 1, 2});
        ListNode *ret = deleteDuplicates(list);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{});
        ListNode *ret = deleteDuplicates(list);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1, 1, 2, 3, 3});
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
