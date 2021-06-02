//
//  RunLoopController.m
//  Demo
//
//  Created by SLJ on 2020/7/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "RunLoopController.h"
#import "MacroHeader.h"
#import "Logger.h"

@interface RunLoopController ()

@end

@implementation RunLoopController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self test:@"1" tap:^(UIButton *button, NSDictionary *userInfo) {
        PRINT_BLANK_LINE
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"main queue task 1");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"main queue task 2");
            });
            NSLog(@"main queue task 3");
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            NSLog(@"main queue task 4");
        });
        /// main_queue是个串行队列 所以输出 1 3 4 2
    }];
    
    [self test:@"2" tap:^(UIButton *button, NSDictionary *userInfo) {
        PRINT_BLANK_LINE
        CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopCommonModes, ^{
            NSLog(@"main queue task 4");
            CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopCommonModes, ^{
                NSLog(@"main queue task 5");
            });
            NSLog(@"main queue task 6");
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            NSLog(@"main queue task 7");
        });
        /// 输出 4 6 5 7
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
