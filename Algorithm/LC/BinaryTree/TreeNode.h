//
//  TreeNode.h
//  DSPro
//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

using namespace std;

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

    // 输出: [3,5,1,6,2,0,8,null,null,7,4]
    void print();

    TreeNode *findNodeWithValue(int val);
};

#endif /* TreeNode_h */
