//
//  TreeNode.m
//  DSPro
//
//  Created by SLJ on 2020/3/18.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "TreeNode.h"

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

TreeNode::TreeNode(int x)
    : val(x)
    , left(NULL);
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

// static NSMutableArray *p_nodeValueArray(TreeNode *node)
//{
//    NSMutableArray *ret = [NSMutableArray array];
//    if (node == NULL) {
//        [ret addObject:@"null"];
//        return ret;
//    }
//    [ret addObject:@(node->val).stringValue];
//
//}

void TreeNode::print()
{
    //    printf("\n");
    //    TreeNode *node = this;
    //    while (node != NULL) {
    //        if (node != this) {
    //            printf("->");
    //        }
    //        printf("%d", node->val);
    //        node = node->next;
    //    }
}
