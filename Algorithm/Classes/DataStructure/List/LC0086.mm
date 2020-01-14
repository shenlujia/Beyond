//
//  LC0086.m
//  DSPro
//
//  Created by SLJ on 2020/1/14.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0086.h"
#import "ListNode.h"

@implementation LC0086

/*
 给定一个链表和一个特定值 x，对链表进行分隔，使得所有小于 x 的节点都在大于或等于 x 的节点之前。

 你应当保留两个分区中每个节点的初始相对位置。

 示例:

 输入: head = 1->4->3->2->5->2, x = 3
 输出: 1->2->2->4->3->5
 */
static ListNode *partition(ListNode *head, int x)
{
    ListNode *list1 = NULL;
    ListNode *list1Current = NULL;
    ListNode *list2 = NULL;
    ListNode *list2Current = NULL;

    ListNode *currentNode = head;
    while (currentNode != NULL) {
        if (currentNode->val < x) {
            if (list1 == NULL) {
                list1 = currentNode;
                list1Current = currentNode;
            } else {
                list1Current->next = currentNode;
                list1Current = currentNode;
            }
        } else {
            if (list2 == NULL) {
                list2 = currentNode;
                list2Current = currentNode;
            } else {
                list2Current->next = currentNode;
                list2Current = currentNode;
            }
        }
        currentNode = currentNode->next;
    }
    if (list1Current) {
        list1Current->next = list2;
    }
    if (list2Current) {
        list2Current->next = NULL;
    }

    if (list1 != NULL) {
        return list1;
    }
    return list2;
}

+ (void)run
{
    {
        ListNode *list = new ListNode(vector<int>{1, 4, 3, 2, 5, 2});
        ListNode *ret = partition(list, 3);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{});
        ListNode *ret = partition(list, 3);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1});
        ListNode *ret = partition(list, 0);
        ret->print();
    }
    {
        ListNode *list = new ListNode(vector<int>{1});
        ListNode *ret = partition(list, 2);
        ret->print();
    }
}

@end
