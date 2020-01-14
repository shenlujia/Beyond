//
//  ListNode.m
//  DSPro
//
//  Created by SLJ on 2020/1/14.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ListNode.h"

ListNode::ListNode(int x)
    : val(x)
    , next(NULL)
{
}

ListNode::ListNode(const vector<int> &values)
{
    val = 0;
    next = NULL;

    if (values.size() > 0) {
        val = values[0];
    }
    if (values.size() > 1) {
        next = new ListNode(vector<int>(values.begin() + 1, values.end()));
    }
}

void ListNode::print()
{
    printf("\n");
    ListNode *node = this;
    while (node != NULL) {
        if (node != this) {
            printf("->");
        }
        printf("%d", node->val);
        node = node->next;
    }
}
