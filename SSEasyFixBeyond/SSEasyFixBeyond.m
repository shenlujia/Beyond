//
//  SSEasyFixBeyond.m
//
//  Created by ZZZ on 2021/11/16.
//

#import "SSEasyFixBeyond.h"
#import <fishhook/fishhook.h>

NSString * beyond_entryClassName(void)
{
    NSString *name = nil;
    name = @"ViewController";
    return name;
}

void open_bdfishhook(void)
{
    
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
int bd_rebind_symbols(struct rebinding array[], size_t n)
{
    return rebind_symbols(array, n);
}
#pragma clang diagnostic pop
