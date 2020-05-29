//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"

LC_CLASS_BEGIN(0700)

/*
 二叉搜索树中的搜索
 给定二叉搜索树（BST）的根节点和一个值。 你需要在BST中找到节点值等于给定值的节点。 返回以该节点为根的子树。 如果节点不存在，则返回 NULL。
 例如，
 给定二叉搜索树:
         4
        / \
       2   7
      / \
     1   3
 和值: 2
 你应该返回如下子树:
       2
      / \
     1   3
 在上述示例中，如果要找的值是 5，但因为没有节点值为 5，我们应该返回 NULL。
 */
static TreeNode *searchBST(TreeNode *root, int val)
{
    while (true) {
        if (root == NULL || root->val == val) {
            return root;
        }
        root = root->val > val ? root->left : root->right;
    }
    return NULL;
}

+ (void)run
{
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[3,5,1,6,2,0,8,null,null,7,4]");
        searchBST(root, 10);
    }
}

LC_CLASS_END
