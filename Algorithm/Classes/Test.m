//
//  Test.m
//  DSPro
//
//  Created by SLJ on 2020/1/9.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "Test.h"
#import "BacktrackTest.h"
#import "BinaryTreeTest.h"
#import "DPTest.h"
#import "DesignTest.h"
#import "DoublePointerTest.h"
#import "GreedTest.h"
#import "ListTest.h"
#import "MergeIntervalTest.h"
#import "OtherTest.h"
#import "QueueTest.h"
#import "Sort.h"
#import "StackTest.h"

@implementation Test

+ (void)run
{
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
