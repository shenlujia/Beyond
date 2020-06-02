//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#ifndef TreeNode_h
#define TreeNode_h

class TreeNode
{
  public:
    int val;
    TreeNode *left;
    TreeNode *right;
    TreeNode(int x);

    // 从 [3,5,1,6,2,0,8,null,null,7,4] 创建
    static TreeNode *createNodeWithArrayString(NSString *arrayString);

    TreeNode *findNodeWithValue(int val);

    vector<int> preOrder1();
    vector<int> preOrder2();
    vector<int> inOrder1();
    vector<int> inOrder2();
    vector<int> postOrder1();
    vector<int> postOrder2();
    vector<vector<int>> levelOrder();

    vector<int> dfs();
    vector<int> bfs();

    int maxDepth(); // 最大深度
    void mirror();  // 镜像
    
    static bool equal(TreeNode *a, TreeNode *b);
};

#endif /* TreeNode_h */
