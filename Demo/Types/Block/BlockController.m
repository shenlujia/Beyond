//
//  BlockController.m
//  Demo
//
//  Created by SLJ on 2020/4/10.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "BlockController.h"
#import "MacroHeader.h"

static int p_static_int = 5;
int p_global_block_int = 10;

void (^g_block_obj_1)(void) = ^(){
    NSLog(@"g_block_obj_1");
};

void (^g_block_obj_2)(void) = ^(){
    NSLog(@"g_block_obj_2 %@", @(p_static_int));
};

static void (^s_block_obj_1)(void) = ^(){
    NSLog(@"s_block_obj_1 %@", @(p_static_int));
};

@interface BlockController ()

@end

@implementation BlockController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self test:@"static global" tap:^(UIButton *button) {
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
    }];

    [self test:@"GlobalBlock MallocBlock StackBlock" tap:^(UIButton *button) {
        int a = 22;
        void (^l_block_1)(void) = ^(){
            NSLog(@"l_block_1");
        };
        void (^l_block_2)(void) = ^(){
            NSLog(@"l_block_2 %@", @(a));
        };
        NSLog(@"%@", g_block_obj_1);
        g_block_obj_1();
        PRINT_BLANK_LINE
        NSLog(@"%@", g_block_obj_2);
        g_block_obj_2();
        PRINT_BLANK_LINE
        NSLog(@"%@", s_block_obj_1);
        s_block_obj_1();
        PRINT_BLANK_LINE
        NSLog(@"%@", l_block_1);
        l_block_1();
        PRINT_BLANK_LINE
        NSLog(@"%@", l_block_2);
        l_block_2();
        PRINT_BLANK_LINE
        NSLog(@"%@", ^{});
        PRINT_BLANK_LINE
        NSLog(@"%@", ^{NSLog(@"%@", @(a));});
    }];
}

@end
