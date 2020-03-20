//
//  Test.m
//  DSPro
//
//  Created by SLJ on 2020/1/9.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "Test.h"
#import "BinaryTreeTest.h"
#import "DPTest.h"
#import "DesignTest.h"
#import "DoublePointerTest.h"
#import "ListTest.h"
#import "MergeIntervalTest.h"
#import "OtherTest.h"
#import "Sort.h"

@implementation Test

+ (void)run
{
    [DoublePointerTest run];
    [DPTest run];
    [OtherTest run];
    [DesignTest run];
    [BinaryTreeTest run];
    [MergeIntervalTest run];
    //    [Sort run];
    //    [ListTest run];
}

@end
