//
//  LC0141.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0141.h"
#import "ListNode.h"

@implementation LC0141

/*
 环形链表

 给定一个链表，判断链表中是否有环。

 为了表示给定链表中的环，我们使用整数 pos 来表示链表尾连接到链表中的位置（索引从 0 开始）。 如果 pos 是 -1，则在该链表中没有环。

 示例 1：

 输入：head = [3,2,0,-4], pos = 1
 输出：true
 解释：链表中有一个环，其尾部连接到第二个节点。

 示例 2：

 输入：head = [1,2], pos = 0
 输出：true
 解释：链表中有一个环，其尾部连接到第一个节点。

 示例 3：

 输入：head = [1], pos = -1
 输出：false
 解释：链表中没有环。

 进阶：

 你能用 O(1)（即，常量）内存解决此问题吗？
 */
static bool hasCycle(ListNode *head)
{
    if (head == nullptr || head->next == nullptr) {
        return false;
    }
    ListNode *slow = head;
    ListNode *fast = head;
    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
        if (slow == fast) {
            return true;
        }
    }
    return false;
}

+ (void)run
{
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3, 4, 5});
        list->print();
        printf("\n%s\n", hasCycle(list) ? "hasCycle" : "noCycle");
    }
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3, 4, 5});
        list->print();
        list->next->next->next = list;
        printf("\n%s\n", hasCycle(list) ? "hasCycle" : "noCycle");
    }
}

@end
