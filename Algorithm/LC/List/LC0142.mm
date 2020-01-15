//
//  LC0142.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0142.h"
#import "ListNode.h"

@implementation LC0142

/*
 环形链表 II

 给定一个链表，返回链表开始入环的第一个节点。 如果链表无环，则返回 null。

 为了表示给定链表中的环，我们使用整数 pos 来表示链表尾连接到链表中的位置（索引从 0 开始）。 如果 pos 是 -1，则在该链表中没有环。

 说明：不允许修改给定的链表。

 示例 1：

 输入：head = [3,2,0,-4], pos = 1
 输出：tail connects to node index 1
 解释：链表中有一个环，其尾部连接到第二个节点。

 示例 2：

 输入：head = [1,2], pos = 0
 输出：tail connects to node index 0
 解释：链表中有一个环，其尾部连接到第一个节点。

 示例 3：

 输入：head = [1], pos = -1
 输出：no cycle
 解释：链表中没有环。

 进阶：
 你是否可以不用额外空间解决此题？
 */
static ListNode *detectCycle(ListNode *head)
{
    ListNode *slow = head;
    ListNode *fast = head;
    while (fast && fast->next) {
        slow = slow->next;
        fast = fast->next->next;
        if (slow == fast) {
            break;
        }
    }
    if (fast == nullptr || fast->next == nullptr) {
        return nullptr;
    }

    slow = head;
    while (true) {
        if (fast == slow) {
            break;
        }
        fast = fast->next;
        slow = slow->next;
    }
    return fast;
}

+ (void)run
{
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3, 4, 5});
        list->print();
        list = detectCycle(list);
        printf("\nCycle: %d\n", list ? list->val : -1);
    }
    {
        ListNode *list = new ListNode(vector<int>{1, 2, 3, 4, 5});
        list->print();
        list->next->next->next->next = list->next;
        list = detectCycle(list);
        printf("\nCycle: %d\n", list ? list->val : -1);
    }
}

@end
