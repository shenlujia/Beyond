//
//  ListTest.m
//  DSPro
//
//  Created by SLJ on 2020/1/14.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ListTest.h"
#import "ListNode.h"

@implementation ListTest

+ (void)run
{
    NSArray *array = @[@"0083", @"0086"];
    for (NSString *string in array) {
        Class c = NSClassFromString([NSString stringWithFormat:@"LC%@", string]);
        printf("====== %s ======", string.UTF8String);
        NSParameterAssert(c);
        [c performSelector:@selector(run)];
        printf("\n");
    }
}

@end
