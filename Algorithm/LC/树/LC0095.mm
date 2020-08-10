//
//  Created by SLJ on 2020/1/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"

LC_CLASS_BEGIN(0095)

/*
 给定一个整数 n，生成所有由 1 ... n 为节点所组成的 二叉搜索树 。
 示例：
 输入：3
 输出：
 [
   [1,null,3,2],
   [3,2,null,1],
   [3,1,null,null,2],
   [2,1,3],
   [1,null,2,null,3]
 ]
 解释：
 以上的输出对应以下 5 种不同结构的二叉搜索树：

    1         3     3      2      1
     \       /     /      / \      \
      3     2     1      1   3      2
     /     /       \                 \
    2     1         2                 3
 提示：
 0 <= n <= 8
 */
static vector<TreeNode*> generateTrees(int n)
{
    if (n <= 0) {
        return vector<TreeNode*>();
    }
    return p(1, n);
}

static vector<TreeNode *> p(int left, int right)
{
    vector<TreeNode *> ret;
    if (left > right) {
        ret.push_back(NULL);
        return ret;
    }
    for (int k = left; k <= right; ++k) {
        vector<TreeNode *> left_nodes = p(left, k - 1);
        vector<TreeNode *> right_nodes = p(k + 1, right);
        for (int a = 0; a < left_nodes.size(); ++a) {
            for (int b = 0; b < right_nodes.size(); ++b) {
                TreeNode *node = new TreeNode(k);
                node->left = left_nodes[a];
                node->right = right_nodes[b];
                ret.push_back(node);
            }
        }
    }
    return ret;
}

+ (void)run
{
    {
        vector<TreeNode*> ret = generateTrees(3);
        NSParameterAssert(ret.size() == 5);
    }
}

LC_CLASS_END
