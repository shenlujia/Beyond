//
//  LC1038.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC1038.h"
#import "TreeNode.h"

@implementation LC1038

/*
 从二叉搜索树到更大和树

 给出二叉 搜索 树的根节点，该二叉树的节点值各不相同，修改二叉树，使每个节点 node 的新值等于原树中大于或等于 node.val 的值之和。

 提醒一下，二叉搜索树满足下列约束条件：

 节点的左子树仅包含键 小于 节点键的节点。
 节点的右子树仅包含键 大于 节点键的节点。
 左右子树也必须是二叉搜索树。

 示例：

 输入：[4,1,6,0,2,5,7,null,null,null,3,null,null,null,8]
 输出：[30,36,21,36,35,26,15,null,null,null,33,null,null,null,8]

 提示：

 树中的节点数介于 1 和 100 之间。
 每个节点的值介于 0 和 100 之间。
 给定的树为二叉搜索树。
 */
static TreeNode *bstToGst(TreeNode *root)
{
    if (root == NULL) {
        return NULL;
    }
    int sum = 0;
    bstToGstWithSum(root, sum);
    return root;
}

static TreeNode *bstToGstWithSum(TreeNode *root, int &sum)
{
    if (root == NULL) {
        return NULL;
    }
    bstToGstWithSum(root->right, sum);
    sum += root->val;
    root->val = sum;
    bstToGstWithSum(root->left, sum);
    return root;
}

+ (void)run
{
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[4,1,6,0,2,5,7,null,null,null,3,null,null,null,8]");
        root = bstToGst(root);
        NSParameterAssert(root->val == 30);
    }
}

@end
