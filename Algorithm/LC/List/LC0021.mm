//
//  LC0021.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0021.h"
#import "ListNode.h"

@implementation LC0021

/*
 合并两个有序链表

 将两个有序链表合并为一个新的有序链表并返回。新链表是通过拼接给定的两个链表的所有节点组成的。

 示例：

 输入：1->2->4, 1->3->4
 输出：1->1->2->3->4->4
 */
static ListNode *mergeTwoLists(ListNode *l1, ListNode *l2)
{
    ListNode temp = ListNode(0);
    ListNode *current = &temp;
    while (l1 && l2) {
        if (l1->val < l2->val) {
            current->next = l1;
            l1 = l1->next;
            current = current->next;
        } else {
            current->next = l2;
            l2 = l2->next;
            current = current->next;
        }
    }
    if (l1) {
        current->next = l1;
    } else if (l2) {
        current->next = l2;
    }
    return temp.next;
}

+ (void)run
{
    {
        ListNode *list1 = new ListNode(vector<int>{1, 2, 4});
        ListNode *list2 = new ListNode(vector<int>{1, 3, 4});
        ListNode *ret = mergeTwoLists(list1, list2);
        ret->print();
    }
}

@end
