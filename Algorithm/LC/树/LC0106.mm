//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"

LC_CLASS_BEGIN(0106)

/*
 根据一棵树的中序遍历与后序遍历构造二叉树。
 注意:
 你可以假设树中没有重复的元素。
 例如，给出
 中序遍历 inorder = [9,3,15,20,7]
 后序遍历 postorder = [9,15,7,20,3]
 返回如下的二叉树：
     3
    / \
   9  20
     /  \
    15   7
 */

static TreeNode* buildTree(vector<int>& inorder, vector<int>& postorder) {
    if (inorder.empty() || inorder.size() != postorder.size()) {
        return NULL;
    }
    unordered_map<int, int> m;
    for (int i = 0; i < inorder.size(); ++i) {
        m[inorder[i]] = i;
    }
    return go(inorder, postorder, m, 0, (int)inorder.size() - 1, 0, (int)postorder.size() - 1);
}

static TreeNode* go(vector<int>& inorder, vector<int>& postorder, unordered_map<int, int> &m, int inL, int inR, int pL, int pR)
{
    if (pL > pR) {
        return NULL;
    }
    TreeNode *root = new TreeNode(postorder[pR]);
    int k = m[postorder[pR]];
    root->left = go(inorder, postorder, m, inL, k - 1, pL, pL + k - inL - 1);
    root->right = go(inorder, postorder, m, k + 1, inR, pL + k - inL, pR - 1);
    return root;
}

+ (void)run
{
    {
        vector<int> v1 = {9, 3, 15, 20, 7};
        vector<int> v2 = {9, 15, 7, 20, 3};
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[3,9,20,null,null,15,7]");
        TreeNode *ret = buildTree(v1, v2);
        NSParameterAssert(TreeNode::equal(root, ret));
    }
}

LC_CLASS_END
