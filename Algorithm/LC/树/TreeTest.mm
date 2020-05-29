//
//  TreeTest.m
//  DSPro
//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeTest.h"
#import "TreeNode.h"

@implementation TreeTest

+ (void)run
{
    vector<int> v = {101, 111, 124, 235, 251, 687, 700, 701, 1038};

    for (int i = 0; i < v.size(); ++i) {
        int value = v[i];
        NSString *name = [NSString stringWithFormat:@"%04d", value];
        Class c = NSClassFromString([NSString stringWithFormat:@"LC%@", name]);
        printf("====== %s ======", name.UTF8String);
        NSParameterAssert(c);
        [c performSelector:@selector(run)];
        printf("\n\n");
    }

    TreeNode *root = TreeNode::createNodeWithArrayString(@"[6,2,8,1,4,7,9,null,null,3,5]");
    vector<int> preOrder1 = root->preOrder1();
    vector<int> preOrder2 = root->preOrder2();
    vector<int> inOrder1 = root->inOrder1();
    vector<int> inOrder2 = root->inOrder2();
    vector<int> postOrder1 = root->postOrder1();
    vector<int> postOrder2 = root->postOrder2();
    NSParameterAssert(preOrder1 == preOrder2 && inOrder1 == inOrder2 && postOrder1 == postOrder2);

    vector<int> d = root->dfs();
    vector<int> d_1 = {6, 2, 1, 4, 3, 5, 8, 7, 9};
    vector<int> b = root->bfs();
    vector<int> b_1 = {6, 2, 8, 1, 4, 7, 9, 3, 5};
    NSParameterAssert(d == d_1 && b == b_1);

    {
        TreeNode *root = TreeNode::createNodeWithArrayString(@"[3,9,20,null,null,15,7]");
        vector<vector<int>> ret = {{3}, {9, 20}, {15, 7}};
        NSParameterAssert(root->levelOrder() == ret);
    }
}

LC_CLASS_END
