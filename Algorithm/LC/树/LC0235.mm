//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"

LC_CLASS_BEGIN(0235)

/*
 给定一个二叉搜索树, 找到该树中两个指定节点的最近公共祖先。
 百度百科中最近公共祖先的定义为：“对于有根树 T 的两个结点 p、q，最近公共祖先表示为一个结点 x，满足 x 是 p、q 的祖先且 x
 的深度尽可能大（一个节点也可以是它自己的祖先）。”
 示例 1:
 输入: root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 8
 输出: 6
 解释: 节点 2 和节点 8 的最近公共祖先是 6。
 示例 2:
 输入: root = [6,2,8,0,4,7,9,null,null,3,5], p = 2, q = 4
 输出: 2
 解释: 节点 2 和节点 4 的最近公共父祖先是 2, 因为根据定义最近公共祖先节点可以为节点本身。
 */
static TreeNode *lowestCommonAncestor(TreeNode *root, TreeNode *p, TreeNode *q)
{
    if (root == NULL || root == p || root == q) {
        return root;
    }
    if (p->val < root->val) {
        if (q->val > root->val) {
            return root;
        } else {
            return lowestCommonAncestor(root->left, p, q);
        }
    } else {
        if (q->val < root->val) {
            return root;
        } else {
            return lowestCommonAncestor(root->right, p, q);
        }
    }
}

+ (void)run
{
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[6,2,8,0,4,7,9,null,null,3,5]");
        TreeNode *p = root->findNodeWithValue(2);
        TreeNode *q = root->findNodeWithValue(8);
        NSParameterAssert(lowestCommonAncestor(root, p, q)->val == 6);
    }
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[6,2,8,0,4,7,9,null,null,3,5]");
        TreeNode *p = root->findNodeWithValue(2);
        TreeNode *q = root->findNodeWithValue(4);
        NSParameterAssert(lowestCommonAncestor(root, p, q)->val == 2);
    }
}

LC_CLASS_END
