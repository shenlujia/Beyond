//
//  BlockController.m
//  Demo
//
//  Created by SLJ on 2020/4/10.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "BlockController.h"

static int p_static_int = 5;
int p_global_block_int = 10;

@interface BlockController ()

@end

@implementation BlockController

- (void)viewDidLoad
{
    [super viewDidLoad];

    int local_int = 20;

    NSLog(@"p_static_int: %p %d", &p_static_int, p_static_int);
    NSLog(@"p_global_block_int: %p %d", &p_global_block_int, p_global_block_int);
    NSLog(@"local_int: %p %d", &local_int, local_int);
    printf("\n");

    ^{
        NSLog(@"p_static_int: %p %d", &p_static_int, p_static_int);
        NSLog(@"p_global_block_int: %p %d", &p_global_block_int, p_global_block_int);
        NSLog(@"local_int: %p %d", &local_int, local_int);
        printf("\n");
    }();

    void (^block)(void) = ^{
        NSLog(@"p_static_int: %p %d", &p_static_int, p_static_int);
        NSLog(@"p_global_block_int: %p %d", &p_global_block_int, p_global_block_int);
        NSLog(@"local_int: %p %d", &local_int, local_int);
        printf("\n");
    };

    block();
}

@end
