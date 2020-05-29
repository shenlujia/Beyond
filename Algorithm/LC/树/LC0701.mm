//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"

LC_CLASS_BEGIN(0701)

/*
 二叉搜索树中的插入操作
 给定二叉搜索树（BST）的根节点和要插入树中的值，将值插入二叉搜索树。 返回插入后二叉搜索树的根节点。 保证原始二叉搜索树中不存在新值。
 注意，可能存在多种有效的插入方式，只要树在插入后仍保持为二叉搜索树即可。 你可以返回任意有效的结果。
 例如,
 给定二叉搜索树:
         4
        / \
       2   7
      / \
     1   3
 和 插入的值: 5
 你可以返回这个二叉搜索树:
          4
        /   \
       2     7
      / \   /
     1   3 5
 或者这个树也是有效的:
          5
        /   \
       2     7
      / \
     1   3
          \
           4
 */
static TreeNode *insertIntoBST(TreeNode *root, int val)
{
    if (root == NULL) {
        return new TreeNode(val);
    }
    if (root->val == val) {
        return root;
    }
    if (val < root->val) {
        root->left = insertIntoBST(root->left, val);
    } else {
        root->right = insertIntoBST(root->right, val);
    }

    return root;
}

+ (void)run
{
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[3,5,1,6,2,0,8,null,null,7,4]");
        insertIntoBST(root, 10);
    }
}

LC_CLASS_END
