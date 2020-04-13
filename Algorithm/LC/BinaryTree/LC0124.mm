//
//  LC0124.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0124.h"
#import "TreeNode.h"

@implementation LC0124
// todo... 可以优化
/*
 二叉树中的最大路径和

 给定一个非空二叉树，返回其最大路径和。

 本题中，路径被定义为一条从树中任意节点出发，达到任意节点的序列。该路径至少包含一个节点，且不一定经过根节点。

 示例 1:
 输入: [1,2,3]
        1
       / \
      2   3

 输出: 6
 示例 2:
 输入: [-10,9,20,null,null,15,7]

    -10
    / \
   9  20
     /  \
    15   7

 输出: 42
 */
static int maxPathSum(TreeNode *root)
{
    if (root == NULL) {
        return INT_MIN;
    }
    if (root->left == NULL && root->right == NULL) {
        return root->val;
    }
    int left = maxPathSum(root->left);
    int right = maxPathSum(root->right);

    int ret = root->val;
    int left_line = maxPathSumInLine(root->left);
    int right_line = maxPathSumInLine(root->right);
    if (left_line > 0) {
        ret += left_line;
    }
    if (right_line > 0) {
        ret += right_line;
    }

    if (ret < left) {
        ret = left;
    }
    if (ret < right) {
        ret = right;
    }
    return ret;
}

static int maxPathSumInLine(TreeNode *root)
{
    if (root == NULL) {
        return INT_MIN;
    }
    int ret = root->val;
    int left_line = maxPathSumInLine(root->left);
    int right_line = maxPathSumInLine(root->right);
    int sub = left_line > right_line ? left_line : right_line;
    if (sub > 0) {
        ret += sub;
    }
    return ret;
}

+ (void)run
{
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[1,2,3]");
        NSParameterAssert(maxPathSum(root) == 6);
    }
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[-10,9,20,null,null,15,7]");
        NSParameterAssert(maxPathSum(root) == 42);
    }
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[5,4,8,11,null,13,4,7,2,null,null,null,1]");
        NSParameterAssert(maxPathSum(root) == 49);
    }
}

@end
/*
          5
     4          8
   11        13   4
 7   2         1
*/
