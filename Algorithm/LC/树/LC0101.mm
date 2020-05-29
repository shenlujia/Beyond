//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"

LC_CLASS_BEGIN(0101)

/*
 对称二叉树
 给定一个二叉树，检查它是否是镜像对称的。
 例如，二叉树 [1,2,2,3,4,4,3] 是对称的。
     1
    / \
   2   2
  / \ / \
 3  4 4  3
 但是下面这个 [1,2,2,null,3,null,3] 则不是镜像对称的:
     1
    / \
   2   2
    \   \
    3    3
 进阶：
 你可以运用递归和迭代两种方法解决这个问题吗？
 */
static bool isSymmetric(TreeNode* root)
{
    if (root == NULL) {
        return true;
    }
    return is_mirror(root->left, root->right);
}

static bool is_mirror(TreeNode* a, TreeNode *b) {
    if (a == NULL && b == NULL) {
        return true;
    }
    if (a == NULL || b == NULL) {
        return false;
    }
    return a->val == b->val && is_mirror(a->left, b->right) && is_mirror(a->right, b->left);
}

bool isSymmetric_2(TreeNode* root)
{
    if(!root) {
        return true;
    }
    queue<TreeNode *> q;
    q.push(root);
    while (!q.empty()) {
        int len = (int)q.size();
        vector<int> v(len);
        for(int i = 0; i < len; ++i) {
            TreeNode *node = q.front();
            q.pop();
            v[i] = node ? node->val : INT_MIN;
            if (node) {
                q.push(node->left);
                q.push(node->right);
            }
        }
        // 判断是否回文
        for (int i = 0; i < len / 2; ++i) {
            if(v[i] != v[len - 1 - i]) {
                return false;
            }
        }
    }
    return true;
}

int longestUnivaluePath(TreeNode* root) {
    int max = 0;
    p(root,max);
    return max;
}
void p(TreeNode* root, int &m)
{
    if (root == NULL) return;
    p(root->left,m);
    p(root->right,m);
    
    int left = 0;
    int right = 0;
    if (root->left && root->left->val == root->val) {
        left = max_down_len(root->left);
    }
    if (root->right && root->right->val == root->val) {
        right = max_down_len(root->right);
    }
    m = max(m, left+right);
}

int max_down_len(TreeNode *root)
{
    if (root == NULL) return 0;
    if (root->left == NULL && root->right == NULL) {
        return 1;
    }
    int left = 0;
    int right = 0;
    if (root->left && root->val == root->left->val) {
        left = max_down_len(root->left) + 1;
    }
    if (root->right && root->val == root->right->val) {
        right = max_down_len(root->right) + 1;
    }
    return max(left, right);
}

+ (void)run
{
    TreeNode *root = TreeNode::createNodeWithArrayString(@"[5,4,5,1,1,5]");
    int jj = longestUnivaluePath(root);
    
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[1,2,2,3,4,4,3]");
        NSParameterAssert(isSymmetric(root) == true);
        NSParameterAssert(isSymmetric_2(root) == true);
    }
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[1,2,2,2,null,2]");
        NSParameterAssert(isSymmetric(root) == false);
        NSParameterAssert(isSymmetric_2(root) == false);
    }
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[1,2,3]");
        NSParameterAssert(isSymmetric(root) == false);
        NSParameterAssert(isSymmetric_2(root) == false);
    }
    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[]");
        NSParameterAssert(isSymmetric(root) == true);
        NSParameterAssert(isSymmetric_2(root) == true);
    }
}

LC_CLASS_END
