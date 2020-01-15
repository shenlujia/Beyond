//
//  LC0206.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0206.h"
#import "ListNode.h"

@implementation LC0206

/*
 反转链表

 反转一个单链表。

 示例:

 输入: 1->2->3->4->5->NULL
 输出: 5->4->3->2->1->NULL
 进阶:
 你可以迭代或递归地反转链表。你能否用两种方法解决这道题？
 */
static ListNode *reverseList(ListNode *head)
{
    if (head == NULL || head->next == NULL) {
        return head;
    }
    ListNode *pre = NULL;
    ListNode *current = head;
    while (current) {
        ListNode *next = current->next;
        current->next = pre;
        pre = current;
        current = next;
    }
    return pre;
}

static ListNode *reverseList_2(ListNode *head)
{
    if (head == nullptr || head->next == nullptr) {
        return head;
    }
    ListNode *ret = reverseList_2(head->next);
    head->next->next = head;
    head->next = nullptr;
    return ret;
}

+ (void)run
{
    {
        ListNode *list = new ListNode(vector<int>{1, 1, 2});
        ListNode *ret = reverseList(list);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1, 1, 2});
        ListNode *ret = reverseList_2(list);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3, 4, 5});
        ListNode *ret = reverseList(list);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3, 4, 5});
        ListNode *ret = reverseList_2(list);
        ret->print();
    }
}

@end
