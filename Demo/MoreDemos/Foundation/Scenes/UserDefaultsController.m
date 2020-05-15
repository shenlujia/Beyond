//
//  UserDefaultsController.m
//  Foundation
//
//  Created by SLJ on 2020/5/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "UserDefaultsController.h"
#import "NSObject+MethodSwizzle.h"

@interface NSUserDefaults (UserDefaultsController)

@end

@implementation NSUserDefaults (UserDefaultsController)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSUserDefaults ss_swizzleMethod:@selector(synchronize) withMethod:@selector(ss_synchronize)];
    });
}

- (BOOL)ss_synchronize
{
    NSLog(@"NSUserDefaults synchronize");
    return [self ss_synchronize];
}

@end

@interface UserDefaultsController ()

@end

@implementation UserDefaultsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [NSUserDefaults.standardUserDefaults setObject:@(NSDate.date.timeIntervalSince1970) forKey:@"time"];
}

@end
