//
//  CallStackController.m
//  Demo
//
//  Created by SLJ on 2020/8/26.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "CallStackController.h"
#import "MacroHeader.h"
#import "KKCallStack.h"
#import "SSEasy.h"

#define PRINT_SYSTEM_CALL_STACK \
PRINT_BLANK_LINE \
printf("====== [NSThread callStackSymbols] ======\n"); \
printf("%s", [[NSThread callStackSymbols] componentsJoinedByString:@"\n"].UTF8String); \
PRINT_BLANK_LINE

@interface CallStackController ()

@end

@implementation CallStackController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self test:@"arm64 main" set:nil action:@selector(arm64_main)];
    [self test:@"arm64 current" set:nil action:@selector(arm64_current)];
    [self test:@"arm64 all" set:nil action:@selector(arm64_all)];
}

- (void)arm64_main
{
    PRINT_BLANK_LINE
    printf("%s", [KKCallStack callStackWithType:KKCallStackTypeMain].UTF8String);
    PRINT_BLANK_LINE
    PRINT_SYSTEM_CALL_STACK
}

- (void)arm64_current
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PRINT_BLANK_LINE
        printf("%s", [KKCallStack callStackWithType:KKCallStackTypeCurrent].UTF8String);
        PRINT_BLANK_LINE
        PRINT_SYSTEM_CALL_STACK
    });
}

- (void)arm64_all
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PRINT_BLANK_LINE
        printf("%s", [KKCallStack callStackWithType:KKCallStackTypeAll].UTF8String);
        PRINT_BLANK_LINE
        PRINT_SYSTEM_CALL_STACK
    });
}

@end
