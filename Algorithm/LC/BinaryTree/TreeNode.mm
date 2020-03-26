//
//  TreeNode.m
//  DSPro
//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"
#import <queue>
#import <stack>

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
        ret.push_back(node->val);
        nodeStack.pop();
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
    stack<TreeNode *> s;
    TreeNode *p = root;
    while (p != NULL || !s.empty()) {
        while (p != NULL) {
            ret.push_back(p->val);
            s.push(p);
            p = p->left;
        }
        if (!s.empty()) {
            p = s.top();
            s.pop();
            p = p->right;
        }
    }
}

// 二叉树中序遍历 递归
static void inOrder_1(TreeNode *root, vector<int> &ret)
{
    if (root != NULL) {
        inOrder_1(root->left, ret);
        ret.push_back(root->val);
        inOrder_1(root->right, ret);
    }
}

// 二叉树中序遍历 非递归
// 根据中序遍历的顺序，对于任一结点，优先访问其左孩子，而左孩子结点又可以看做一根结点，然后继续访问其左孩子结点，直到遇到左孩子结点为空的结点才进行访问，然后按相同的规则访问其右子树。
// 对于任一结点P，
// 若其左孩子不为空，则将P入栈并将P的左孩子置为当前的P，然后对当前结点P再进行相同的处理；
// 若其左孩子为空，则取栈顶元素并进行出栈操作，访问该栈顶结点，然后将当前的P置为栈顶结点的右孩子；
// 直到P为NULL并且栈为空则遍历结束
static void inOrder_2(TreeNode *root, vector<int> &ret)
{
    stack<TreeNode *> s;
    TreeNode *p = root;
    while (p != NULL || !s.empty()) {
        while (p != NULL) {
            s.push(p);
            p = p->left;
        }
        if (!s.empty()) {
            p = s.top();
            ret.push_back(p->val);
            s.pop();
            p = p->right;
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

//// 二叉树后序遍历 非递归
////
///后序遍历的非递归实现是三种遍历方式中最难的一种。因为在后序遍历中，要保证左孩子和右孩子都已被访问并且左孩子在右孩子前访问才能访问根结点，这就为流程的控制带来了难题。
//// 对于任一结点P，将其入栈，然后沿其左子树一直往下搜索，直到搜索到没有左孩子的结点，此时该结点出现在栈顶，但是此时不能将其出栈并访问，因此其右孩子还为被访问。
//// 所以接下来按照相同的规则对其右子树进行相同的处理，当访问完其右孩子时，该结点又出现在栈顶，此时可以将其出栈并访问。
////
///这样就保证了正确的访问顺序。可以看出，在这个过程中，每个结点都两次出现在栈顶，只有在第二次出现在栈顶时，才能访问它。因此需要多设置一个变量标识该结点是否是第一次出现在栈顶。
// static void postOrder_2(TreeNode *root, vector<int> &ret)
//{
//    stack<TreeNode *> s;
//    TreeNode *p = root;
//    TreeNode *temp;
//    while (p!=NULL || !s.empty()) {
//        while (p!=NULL) { // 沿左子树一直往下搜索，直至出现没有左子树的结点
//            TreeNode *btn=(TreeNode *)malloc(sizeof(BTNode));
//            btn->btnode=p;
//            btn->isFirst=true;
//            s.push(btn);
//            p=p->lchild;
//        }
//        if(!s.empty())
//        {
//            temp=s.top();
//            s.pop();
//            if(temp->isFirst==true)     //表示是第一次出现在栈顶
//             {
//                temp->isFirst=false;
//                s.push(temp);
//                p=temp->btnode->rchild;
//            }
//            else//第二次出现在栈顶
//             {
//                cout<<temp->btnode->data<<"";
//                p=NULL;
//            }
//        }
//    }
//}

// 二叉树后序遍历 非递归
// 要保证根结点在左孩子和右孩子访问之后才能访问，因此对于任一结点P，先将其入栈。
// 如果P不存在左孩子和右孩子，则可以直接访问它；或者P存在左孩子或者右孩子，但是其左孩子和右孩子都已被访问过了，则同样可以直接访问该结点。
// 若非上述两种情况，则将P的右孩子和左孩子依次入栈，这样就保证了每次取栈顶元素的时候，左孩子在右孩子前面被访问，左孩子和右孩子都在根结点前面被访问。
static void postOrder_2(TreeNode *root, vector<int> &ret)
{
    stack<TreeNode *> s;
    TreeNode *cur;        // 当前结点
    TreeNode *pre = NULL; // 前一次访问的结点
    s.push(root);
    while (!s.empty()) {
        cur = s.top();
        if ((cur->left == NULL && cur->right == NULL) || (pre != NULL && (pre == cur->left || pre == cur->right))) {
            ret.push_back(cur->val);
            s.pop();
            pre = cur;
        } else {
            if (cur->right != NULL) {
                s.push(cur->right);
            }
            if (cur->left != NULL) {
                s.push(cur->left);
            }
        }
    }
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
    inOrder_1(this, ret);
    return ret;
}

vector<int> TreeNode::inOrder2()
{
    vector<int> ret;
    inOrder_2(this, ret);
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
