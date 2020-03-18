//
//  Test.m
//  DSPro
//
//  Created by SLJ on 2020/1/9.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "Test.h"
#import "BinaryTreeTest.h"
#import "DesignTest.h"
#import "ListTest.h"
#import "Sort.h"

@implementation Test

+ (void)run
{
    [DesignTest run];
    [BinaryTreeTest run];
    //    [Sort run];
    //    [ListTest run];
}

@end
