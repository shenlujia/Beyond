//
//  SSCommonTests.m
//  FixHeaderImportTests
//
//  Created by SLJ on 2019/9/22.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SSCommon.h"

@interface SSCommonTests : XCTestCase

@end

@implementation SSCommonTests

- (void)test_fixXibString
{
    NSArray *cases = @[@{@"@\"AAAAAA\"" : @"AAAAAA"},
                       @{@"AAAAAA.viewNib" : @"AAAAAA"},
                       @{@"AAAAAA.htuc_viewNib" : @"AAAAAA"},
                       @{@"AAAAAA.htuc_viewWithNib" : @"AAAAAA"},
                       @{@"[UINib htuc_nibNamed:AAAAAA]" : @"AAAAAA"},
                       @{@"[UINib nibWithNibName:AAAAAA bundle:nil]" : @"AAAAAA"},
                       @{@"[UINib htuc_nibNamed:NSStringFromClass([AAAAAA class])]" : @"AAAAAA"},
                       @{@"[AAAAAA viewNib]" : @"AAAAAA"},
                       @{@"[UINib nibWthNibName:AAAAAA bundle:nil]" : @"AAAAAA"},
                       @{@"[AAAAAA viewWithNib]" : @"AAAAAA"},
                       @{@"NSStringFromClass(AAAAAA.class)" : @"AAAAAA"},
                       @{@"NSStringFromClass([AAAAAA class])" : @"AAAAAA"},
                       @{@"[AAAAAA createViewFromXib]" : @"AAAAAA"}];
    
    for (NSDictionary *item in cases) {
        NSString *key = item.allKeys.firstObject;
        NSString *value = item.allValues.firstObject;
        NSString *result = [SSCommon fixXibString:key];
        XCTAssert([result isEqualToString:value], @"key = %@, ret = %@", key, result);
    }
}

@end
