//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"
#import <list>

static TreeNode *createNode(NSArray *array, NSInteger index)
{
    if (index >= array.count) {
        return NULL;
    }
    NSString *value = array[index];
    if ([[value lowercaseString] isEqualToString:@"null"]) {
        return NULL;
    }
    TreeNode *node = new TreeNode(value.intValue);
    node->left = createNode(array, index * 2);
    node->right = createNode(array, index * 2 + 1);
    return node;
}

// 深度优先遍历 DFS
static void depthFirstSearch(TreeNode *root, vector<int> &ret)
{
    if (root == NULL) {
        return;
    }
    stack<TreeNode *> nodeStack;
    nodeStack.push(root);
    TreeNode *node = NULL;
    while (!nodeStack.empty()) {
        node = nodeStack.top();
        nodeStack.pop();
        ret.push_back(node->val);
        if (node->right) {
            nodeStack.push(node->right); // 先将右子树压栈
        }
        if (node->left) {
            nodeStack.push(node->left); // 再将左子树压栈
        }
    }
}

// 广度优先遍历 BFS
static void breadthFirstSearch(TreeNode *root, vector<int> &ret)
{
    if (root == NULL) {
        return;
    }
    queue<TreeNode *> nodeQueue; // 使用C++的STL标准模板库
    nodeQueue.push(root);
    TreeNode *node = NULL;
    while (!nodeQueue.empty()) {
        node = nodeQueue.front();
        nodeQueue.pop();
        ret.push_back(node->val);
        if (node->left) {
            nodeQueue.push(node->left); // 先将左子树入队
        }
        if (node->right) {
            nodeQueue.push(node->right); // 再将右子树入队
        }
    }
}

// 层序遍历
static vector<vector<int>> levelOrder_1(TreeNode *root)
{
    vector<vector<int>> levelResult;
    if (root == NULL) {
        return levelResult;
    }

    // 用来暂存数据
    queue<TreeNode *> q;
    // 先存储根节点，每一层的结束用 NULL 分割
    q.push(root);
    q.push(NULL);
    // 当前层的节点
    vector<int> cur_vec;
    while (!q.empty()) {
        TreeNode *cur = q.front();
        q.pop();
        if (cur == NULL) {
            // 一层遍历结束了
            levelResult.push_back(cur_vec);
            // 重置 cur_vec
            cur_vec.clear();
            if (q.size() > 0) {
                // 插入层的分割
                q.push(NULL);
            }
        } else {
            cur_vec.push_back(cur->val);
            // 当前节点的左右节点入队
            if (cur->left) {
                q.push(cur->left);
            }
            if (cur->right) {
                q.push(cur->right);
            }
        }
    }

    return levelResult;
}

// 二叉树前序遍历 递归
static void preOrder_1(TreeNode *root, vector<int> &ret)
{
    if (root != NULL) {
        ret.push_back(root->val);
        preOrder_1(root->left, ret);
        preOrder_1(root->right, ret);
    }
}

// 二叉树前序遍历 非递归
// 根据前序遍历访问的顺序，优先访问根结点，然后再分别访问左孩子和右孩子。
// 即对于任一结点，其可看做是根结点，因此可以直接访问，访问完之后，若其左孩子不为空，按相同规则访问它的左子树；当访问其左子树时，再访问它的右子树。
// 对于任一结点P：
// 访问结点P，并将结点P入栈;
// 判断结点P的左孩子是否为空，若为空，则取栈顶结点并进行出栈操作，并将栈顶结点的右孩子置为当前的结点P，循环至1);若不为空，则将P的左孩子置为当前的结点P;
// 直到P为NULL并且栈为空，则遍历结束。
static void preOrder_2(TreeNode *root, vector<int> &ret)
{
    if (root == NULL) {
        return;
    }
    stack<TreeNode *> s;
    s.push(root);
    while (!s.empty()) {
        TreeNode *node = s.top();
        s.pop();
        if (node->right) {
            s.push(node->right);
        }
        if (node->left) {
            s.push(node->left);
        }
        ret.push_back(node->val);
    }
}

// 二叉树中序遍历 递归
static void inorderTraversal_1(TreeNode *root, vector<int> &ret)
{
    if (root != NULL) {
        inorderTraversal_1(root->left, ret);
        ret.push_back(root->val);
        inorderTraversal_1(root->right, ret);
    }
}

// 二叉树中序遍历 非递归
static void inorderTraversal_2(TreeNode *root, vector<int> &ret)
{
    stack<TreeNode *> s;
    TreeNode *curr = root;
    while (curr != NULL || !s.empty()) {
        while (curr != NULL) {
            s.push(curr);
            curr = curr->left;
        }
        if (!s.empty()) {
            curr = s.top();
            s.pop();
            ret.push_back(curr->val);
            curr = curr->right;
        }
    }
}

// 二叉树后序遍历 递归
static void postOrder_1(TreeNode *root, vector<int> &ret)
{
    if (root != NULL) {
        postOrder_1(root->left, ret);
        postOrder_1(root->right, ret);
        ret.push_back(root->val);
    }
}

// 二叉树后序遍历 非递归
// 我们可以很简单的实现另一种遍历：”根->右->左“遍历。虽然这种遍历没有名字，但是他是后序遍历的反序。所以我们可以利用两个栈，利用栈的LIFO特点，来实现后续遍历。
static void postOrder_2(TreeNode *root, vector<int> &ret)
{
    if (root == NULL) {
        return;
    }
    stack<TreeNode *> s;
    s.push(root);
    while (!s.empty()) {
        TreeNode *node = s.top();
        s.pop();
        if (node->left) {
            s.push(node->left);
        }
        if (node->right) {
            s.push(node->right);
        }
        ret.push_back(node->val);
    }
    reverse(ret.begin(), ret.end());
}

TreeNode::TreeNode(int x)
    : val(x)
    , left(NULL)
    , right(NULL)
{
}

TreeNode *TreeNode::createNodeWithArrayString(NSString *arrayString)
{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
    NSArray *array = [[arrayString stringByTrimmingCharactersInSet:set] componentsSeparatedByString:@","];
    array = [@[@""] arrayByAddingObjectsFromArray:array];
    return createNode(array, 1);
}

TreeNode *TreeNode::findNodeWithValue(int val)
{
    if (this->val == val) {
        return this;
    }
    if (this->left != NULL) {
        TreeNode *left = this->left->findNodeWithValue(val);
        if (left) {
            return left;
        }
    }
    if (this->right != NULL) {
        TreeNode *right = this->right->findNodeWithValue(val);
        if (right) {
            return right;
        }
    }
    return NULL;
}

vector<int> TreeNode::preOrder1()
{
    vector<int> ret;
    preOrder_1(this, ret);
    return ret;
}

vector<int> TreeNode::preOrder2()
{
    vector<int> ret;
    preOrder_2(this, ret);
    return ret;
}

vector<int> TreeNode::inOrder1()
{
    vector<int> ret;
    inorderTraversal_1(this, ret);
    return ret;
}

vector<int> TreeNode::inOrder2()
{
    vector<int> ret;
    inorderTraversal_2(this, ret);
    return ret;
}

vector<int> TreeNode::postOrder1()
{
    vector<int> ret;
    postOrder_1(this, ret);
    return ret;
}

vector<int> TreeNode::postOrder2()
{
    vector<int> ret;
    postOrder_2(this, ret);
    return ret;
}

vector<vector<int>> TreeNode::levelOrder()
{
    return levelOrder_1(this);
}

vector<int> TreeNode::dfs()
{
    vector<int> ret;
    depthFirstSearch(this, ret);
    return ret;
}

vector<int> TreeNode::bfs()
{
    vector<int> ret;
    breadthFirstSearch(this, ret);
    return ret;
}

int TreeNode::maxDepth()
{
    int left = 0;
    if (this->left) {
        left = this->left->maxDepth();
    }
    int right = 0;
    if (this->right) {
        right = this->right->maxDepth();
    }
    return max(left, right) + 1;
}

void TreeNode::mirror()
{
    if (this->left || this->right) {
        TreeNode *temp = this->left;
        this->left = this->right;
        this->right = temp;
    }
    if (this->left) {
        this->left->mirror();
    }
    if (this->right) {
        this->right->mirror();
    }
}

bool TreeNode::equal(TreeNode *a, TreeNode *b)
{
    if (a == NULL && b == NULL) {
        return true;
    }
    if (a == NULL || b == NULL) {
        return false;
    }
    return equal(a->left, b->left) && equal(a->right, b->right);
}
