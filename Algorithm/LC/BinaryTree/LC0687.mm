//
//  LC0687.m
//  DSPro
//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "LC0687.h"
#import "TreeNode.h"
#import <string>
#import <vector>

@implementation LC0687

/*
 最长同值路径

 给定一个二叉树，找到最长的路径，这个路径中的每个节点具有相同值。 这条路径可以经过也可以不经过根节点。

 注意：两个节点之间的路径长度由它们之间的边数表示。

 示例 1:

 输入:

               5
              / \
             4   5
            / \   \
           1   1   5
 输出:

 2
 示例 2:

 输入:

               1
              / \
             4   5
            / \   \
           4   4   5
 输出:

 2
 注意: 给定的二叉树不超过10000个结点。 树的高度不超过1000。
 */
static int longestUnivaluePath(TreeNode *root)
{
    int ret = 0;
    longestUnivaluePathImpl(root, ret);
    return ret;
}

static int longestUnivaluePathImpl(TreeNode *root, int &longest)
{
    if (root == NULL) {
        return 0;
    }
    int left = longestUnivaluePathImpl(root->left, longest);
    int right = longestUnivaluePathImpl(root->right, longest);

    if (root->left == NULL || root->left->val != root->val) {
        left = 0;
    }
    if (root->right == NULL || root->right->val != root->val) {
        right = 0;
    }
    longest = max(longest, left + right);

    return left > right ? left + 1 : right + 1;
}

+ (void)run
{
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[5,4,5,1,1,null,5]");
        int ret = longestUnivaluePath(root);
        NSParameterAssert(ret == 2);
    }
}

@end
