//
//  LC0203.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0203.h"
#import "ListNode.h"

@implementation LC0203

/*
 移除链表元素

 删除链表中等于给定值 val 的所有节点。

 示例:

 输入: 1->2->6->3->4->5->6, val = 6
 输出: 1->2->3->4->5
 */
static ListNode *removeElements(ListNode *head, int val)
{
    ListNode temp = ListNode(-1);
    temp.next = head;
    ListNode *current = &temp;

    while (current->next) {
        if (current->next->val == val) {
            current->next = current->next->next;
        } else {
            current = current->next;
        }
    }
    return temp.next;
}

+ (void)run
{
    {
        ListNode *list1 = new ListNode(vector<int>{2, 2, 4, 3});
        ListNode *ret = removeElements(list1, 2);
        ret->print();
    }
}

@end
