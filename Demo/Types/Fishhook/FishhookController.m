//
//  FishhookController.m
//  Demo
//
//  Created by SLJ on 2020/8/26.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "FishhookController.h"
#import "MacroHeader.h"

extern void hook_msgsend(void);

@interface FishhookTestObj : NSObject

@end

@implementation FishhookTestObj

+ (void)func_hello
{
    printf("====== hello ======\n");
}

+ (void)func_world
{
    printf("====== world ======\n");
}

@end

@interface FishhookController ()

@end

@implementation FishhookController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self test:@"arm64 hook msg_send" tap:^(UIButton *button, NSDictionary *userInfo) {
        PRINT_BLANK_LINE
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            hook_msgsend();
        });
        [FishhookTestObj func_hello];
        [FishhookTestObj func_world];
    }];
}

@end
