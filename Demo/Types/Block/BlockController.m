//
//  BlockController.m
//  Demo
//
//  Created by SLJ on 2020/4/10.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "BlockController.h"
#import "MacroHeader.h"
#import "BlockNotCallChecker.h"

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
    
    WEAKSELF
    
    [self test:@"static global" tap:^(UIButton *button, NSDictionary *userInfo) {
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

    [self test:@"GlobalBlock MallocBlock StackBlock" tap:^(UIButton *button, NSDictionary *userInfo) {
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
    
    [self test:@"block同步是否被调用" set:nil action:@selector(block_sync_called_or_not)];
    
    [self test:@"block异步是否被调用" set:nil action:@selector(block_async_called_or_not)];
}

- (void)block_sync_called_or_not
{
    PRINT_BLANK_LINE
    {
        BlockNotCallChecker *checker = [[BlockNotCallChecker alloc] initWithName:@"block1"];
        void (^block)(void) = ^{
            NSLog(@"sync block1 done");
            [checker didCall];
        };
        [self block_sync_called_test:block];
    }
    {
        BlockNotCallChecker *checker = [[BlockNotCallChecker alloc] initWithName:@"block2"];
        void (^block)(void) = ^{
            NSLog(@"sync block2 done");
            [checker didCall];
        };
        [self block_sync_called_not_test:block];
    }
}

- (void)block_sync_called_test:(void (^)(void))block
{
    block();
}

- (void)block_sync_called_not_test:(void (^)(void))block
{
    
}

- (void)block_async_called_or_not
{
    PRINT_BLANK_LINE
    {
        BlockNotCallChecker *checker = [[BlockNotCallChecker alloc] initWithName:@"block3"];
        void (^block)(void) = ^{
            NSLog(@"async block3 done");
            [checker didCall];
        };
        [self block_async_called_test:block];
    }
    {
        BlockNotCallChecker *checker = [[BlockNotCallChecker alloc] initWithName:@"block4"];
        void (^block)(void) = ^{
            NSLog(@"async block4 done");
            [checker didCall];
        };
        [self block_async_called_not_test:block];
    }
}

- (void)block_async_called_test:(void (^)(void))block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __unused void (^b)(void) = block;
        b();
    });
}

- (void)block_async_called_not_test:(void (^)(void))block
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __unused void (^b)(void) = block;
    });
}

@end
