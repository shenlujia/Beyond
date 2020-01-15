//
//  LC0002.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0002.h"
#import "ListNode.h"

@implementation LC0002

/*
 两数相加

 给出两个 非空 的链表用来表示两个非负的整数。其中，它们各自的位数是按照 逆序 的方式存储的，并且它们的每个节点只能存储 一位 数字。

 如果，我们将这两个数相加起来，则会返回一个新的链表来表示它们的和。

 您可以假设除了数字 0 之外，这两个数都不会以 0 开头。

 示例：

 输入：(2 -> 4 -> 3) + (5 -> 6 -> 4)
 输出：7 -> 0 -> 8
 原因：342 + 465 = 807
 */
static ListNode *addTwoNumbers(ListNode *l1, ListNode *l2)
{
    ListNode temp = ListNode(0);
    ListNode *current = &temp;

    int extra = 0;
    while (l1 && l2) {
        l1->val += l2->val + extra;
        if (l1->val >= 10) {
            l1->val -= 10;
            extra = 1;
        } else {
            extra = 0;
        }
        current->next = l1;

        l1 = l1->next;
        l2 = l2->next;
        current = current->next;
    }

    if (l1) {
        current->next = l1;
    } else if (l2) {
        current->next = l2;
    }

    while (current->next && extra) {
        current->next->val += extra;
        if (current->next->val >= 10) {
            current->next->val -= 10;
            extra = 1;
        } else {
            extra = 0;
        }
        current = current->next;
    }
    if (extra) {
        current->next = new ListNode(1);
    }

    return temp.next;
}

+ (void)run
{
    {
        ListNode *list1 = new ListNode(vector<int>{2, 4, 3});
        ListNode *list2 = new ListNode(vector<int>{5, 6, 4});
        ListNode *ret = addTwoNumbers(list1, list2);
        ret->print();
    }
    {
        ListNode *list1 = new ListNode(vector<int>{2, 4, 5});
        ListNode *list2 = new ListNode(vector<int>{5, 6, 4});
        ListNode *ret = addTwoNumbers(list1, list2);
        ret->print();
    }
}

@end
