//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"

LC_CLASS_BEGIN(0105)

/*
 从前序与中序遍历序列构造二叉树
 根据一棵树的前序遍历与中序遍历构造二叉树。
 注意:
 你可以假设树中没有重复的元素。
 例如，给出
 前序遍历 preorder = [3,9,20,15,7]
 中序遍历 inorder = [9,3,15,20,7]
 返回如下的二叉树：
     3
    / \
   9  20
     /  \
    15   7
 */
static TreeNode* buildTree(vector<int>& preorder, vector<int>& inorder)
{
    if (preorder.empty() || preorder.size() != inorder.size()) {
        return NULL;
    }
    unordered_map<int, int> m;
    for (int i = 0; i < inorder.size(); ++i) {
        m[inorder[i]] = i;
    }
    return go(inorder, preorder, m, 0, (int)inorder.size() - 1, 0, (int)preorder.size() - 1);
}

static TreeNode* go(vector<int>& inorder, vector<int>& preorder, unordered_map<int, int> &m, int inL, int inR, int pL, int pR)
{
    if (pL > pR) {
        return NULL;
    }
    TreeNode *root = new TreeNode(preorder[pL]);
    int k = m[preorder[pL]];
    root->left = go(inorder, preorder, m, inL, k - 1, pL + 1, pL + k - inL);
    root->right = go(inorder, preorder, m, k + 1, inR, pL + k - inL + 1, pR);
    return root;
}

+ (void)run
{
    {
        vector<int> v1 = {3, 9, 20, 15, 7};
        vector<int> v2 = {9, 3, 15, 20, 7};
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[3,9,20,null,null,15,7]");
        TreeNode *ret = buildTree(v1, v2);
        NSParameterAssert(TreeNode::equal(root, ret));
    }
}

LC_CLASS_END
