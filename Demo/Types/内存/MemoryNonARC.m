//
//  MemoryNonARC.m
//  Beyond
//
//  Created by ZZZ on 2021/2/4.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "MemoryNonARC.h"

@implementation MemoryNonARC

+ (void)releaseObject:(NSObject *)obj
{
    [obj release];
}

@end
