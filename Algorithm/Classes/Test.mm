//
//  Test.m
//  DSPro
//
//  Created by SLJ on 2020/1/9.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "Test.h"
#import "BacktrackTest.h"
#import "BinarySearchTest.h"
#import "BinaryTreeTest.h"
#import "DPTest.h"
#import "DesignTest.h"
#import "DoublePointerTest.h"
#import "GreedTest.h"
#import "ListTest.h"
#import "MergeIntervalTest.h"
#import "OtherTest.h"
#import "PriorityQueueTest.h"
#import "QueueTest.h"
#import "Sort.h"
#import "StackTest.h"
#import "ArrayTest.h"

@implementation Test

+ (void)run
{
    [ArrayTest run];
    [BinarySearchTest run];
    [PriorityQueueTest run];
    [BacktrackTest run];
    [GreedTest run];
    [StackTest run];
    [QueueTest run];
    [DoublePointerTest run];
    [DPTest run];
    [OtherTest run];
    [DesignTest run];
    [BinaryTreeTest run];
    [MergeIntervalTest run];
    //    [Sort run];
    [ListTest run];
}

@end
