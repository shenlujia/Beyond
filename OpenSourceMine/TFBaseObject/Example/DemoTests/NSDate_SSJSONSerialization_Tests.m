//
//  NSDate_SSJSONSerialization_Tests.m
//  DemoTests
//
//  Created by admin on 2018/5/31.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TFBaseObject/TFBaseObject.h>

@interface NSDate_SSJSONSerialization_Tests : XCTestCase

@end

@implementation NSDate_SSJSONSerialization_Tests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_separate
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1527769619];
    
    XCTAssert(date.ss_year == 2018);
    XCTAssert(date.ss_month == 5);
    XCTAssert(date.ss_day == 31);
    XCTAssert(date.ss_hour == 20);
    XCTAssert(date.ss_minute == 26);
    XCTAssert(date.ss_second == 59);
}

- (void)test_dateWithObject
{
    XCTAssert([NSDate ss_dateWithObject:nil] == nil);
    XCTAssert([NSDate ss_dateWithObject:@""] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"20"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"201"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-0"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-05"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-05-"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-05-3"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-05-31 "] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-05-31 2"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-05-31 20"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-05-31 20:"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-05-31 20:2"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-05-31 20:26:"] == nil);
    XCTAssert([NSDate ss_dateWithObject:@"2018-05-31 20:26:5"] == nil);
    
    NSDate *date1 = [NSDate ss_dateWithObject:@(1527769619)];
   
    {
        NSDate *date2 = [NSDate ss_dateWithObject:@(1527769619000)];
        NSDate *date3 = [NSDate ss_dateWithObject:@"2018-05-31 20:26:59"];
        
        XCTAssert(date1.ss_year == date2.ss_year && date2.ss_year == date3.ss_year);
        XCTAssert(date1.ss_month == date2.ss_month && date2.ss_month == date3.ss_month);
        XCTAssert(date1.ss_day == date2.ss_day && date2.ss_day == date3.ss_day);
        XCTAssert(date1.ss_hour == date2.ss_hour && date2.ss_hour == date3.ss_hour);
        XCTAssert(date1.ss_minute == date2.ss_minute && date2.ss_minute == date3.ss_minute);
        XCTAssert(date1.ss_second == date2.ss_second && date2.ss_second == date3.ss_second);
    }
    
    {
        NSDate *date2 = [NSDate ss_dateWithObject:@"2018-05-31 20:26"];
        NSDate *date3 = [NSDate ss_dateWithObject:@"2018-05-31"];
        
        XCTAssert(date1.ss_year == date2.ss_year && date2.ss_year == date3.ss_year);
        XCTAssert(date1.ss_month == date2.ss_month && date2.ss_month == date3.ss_month);
        XCTAssert(date1.ss_day == date2.ss_day && date2.ss_day == date3.ss_day);
        XCTAssert(date1.ss_hour == date2.ss_hour && date3.ss_hour == 0);
        XCTAssert(date1.ss_minute == date2.ss_minute && date3.ss_minute == 0);
        XCTAssert(date2.ss_second == 0 && date3.ss_second == 0);
    }
}

- (void)test_stringWithFormat
{
    NSDate *date = [NSDate ss_dateWithObject:@"2018-05-31 20:26:59"];
    
    NSString *s1 = [date ss_stringWithFormat:@"yyyy-MM-dd"];
    NSString *s2 = [date ss_stringWithFormat:@"yyyy-MM-dd HH:mm"];
    NSString *s3 = [date ss_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    XCTAssert([s1 isEqualToString:@"2018-05-31"]);
    XCTAssert([s2 isEqualToString:@"2018-05-31 20:26"]);
    XCTAssert([s3 isEqualToString:@"2018-05-31 20:26:59"]);
}

@end
