//
//  UselessClassCheckController.m
//  Beyond
//
//  Created by ZZZ on 2021/2/3.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "UselessClassCheckController.h"
#import "MacroHeader.h"
#import "AWEClassUsageHelper.h"
#import "SSEasy.h"

SS_CHECK_TIME_REGISTER

@interface UselessClassCheckController ()

@end

@implementation UselessClassCheckController

- (void)viewDidLoad
{
    SS_CHECK_TIME_AUTO_START
    
    [super viewDidLoad];

    SS_CHECK_TIME_STEP

    [self test:@"check" tap:^(UIButton *button, NSDictionary *userInfo) {
        PRINT_BLANK_LINE
        [[AWEClassUsageHelper sharedInstance] flashAllClass];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableDictionary *allClassInfo = [[AWEClassUsageHelper sharedInstance].allClassInfo[@"classes"] mutableCopy];
            NSMutableArray *classes = [NSMutableArray array];
            [allClassInfo.allKeys enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *info = allClassInfo[obj];
                if (![info[@"isInit"] boolValue]) {
                    [classes addObject:obj];
                }
            }];
            [classes sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b) {
                return [a compare:b];
            }];
            NSLog(@"useless classes count = %@", @(classes.count));
            NSLog(@"%@", [classes componentsJoinedByString:@", "]);
        });
    }];

    SS_CHECK_TIME_STEP
}

@end
