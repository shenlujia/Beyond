//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"

LC_CLASS_BEGIN(0111)

/*
 二叉树的最小深度
 给定一个二叉树，找出其最小深度。
 最小深度是从根节点到最近叶子节点的最短路径上的节点数量。
 说明: 叶子节点是指没有子节点的节点。
 示例:
 给定二叉树 [3,9,20,null,null,15,7],
     3
    / \
   9  20
     /  \
    15   7
 返回它的最小深度  2.
 */
static int minDepth(TreeNode *root)
{
    if (root == NULL) {
        return 0;
    }
    queue<TreeNode *> q;
    q.push(root);
    int dep = 1;
    while (!q.empty()) {
        int size = (int)q.size();
        for (int i = 0; i < size; ++i) {
            TreeNode *temp = q.front();
            q.pop();
            if (temp->left == NULL && temp->right == NULL) {
                return dep;
            }
            if (temp->left) {
                q.push(temp->left);
            }
            if (temp->right) {
                q.push(temp->right);
            }
        }
        ++dep;
    }
    return dep;
}

+ (void)run
{
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[3,9,20,null,null,15,7]");
        NSParameterAssert(minDepth(root) == 2);
    }
}

LC_CLASS_END
