//
//  TFBaseObject_Tests.m
//  DemoTests
//
//  Created by admin on 2018/5/31.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TFBaseObject/TFBaseObject.h>

@interface SSTestObject_simple1 : TFBaseObject

@property (nonatomic, strong) id idObject;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, copy) NSArray *array;
@property (nonatomic, copy) NSDictionary *dictionary;

@end

@implementation SSTestObject_simple1

@end

@interface SSTest2Object : TFBaseObject

@property (nonatomic, strong) id idObject;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, copy) NSArray *array;
@property (nonatomic, copy) NSDictionary *dictionary;
@property (nonatomic, strong) SSTestObject_simple1 *other;

@end

@implementation SSTest2Object

+ (NSDictionary *)ss_replacedKeyFromPropertyName
{
    return @{@"text" : @"what"};
}

+ (NSDictionary *)ss_objectClassInArray
{
    return @{@"array" : [SSTest2Object class]};
}

@end

@interface TFBaseObject_Tests : XCTestCase

@end

@implementation TFBaseObject_Tests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_replacedKeyFromPropertyName
{
    NSDictionary *test = @{@"what" : @"SLJ"};
    
    SSTest2Object *object = [[SSTest2Object alloc] init];
    [object ss_setKeyValues:test];
    
    XCTAssert([object.text isEqualToString:@"SLJ"]);
}

- (void)test_objectClassInArray
{
    NSDictionary *test = @{@"what" : @"a",
                           @"array" : @[@{@"what" : @"a0"},
                                        @{@"what" : @"a1"}]
                           };
    SSTest2Object *a = [[SSTest2Object alloc] init];
    [a ss_setKeyValues:test];
    
    XCTAssert([a.text isEqualToString:@"a"]);
    SSTest2Object *a0 = a.array[0];
    SSTest2Object *a1 = a.array[1];
    XCTAssert([a0.text isEqualToString:@"a0"]);
    XCTAssert([a1.text isEqualToString:@"a1"]);
}

- (void)test_copy
{
    NSDictionary *test = @{@"what" : @"1",
                           @"array" : @[@{@"what" : @"a0"},
                                        @{@"what" : @"a1"}]
                           };
    SSTest2Object *a = [[SSTest2Object alloc] init];
    [a ss_setKeyValues:test];
    SSTest2Object *b = [a copy];
    
    XCTAssert([a.text isEqualToString:@"1"]);
    XCTAssert([b.text isEqualToString:@"1"]);
    
    SSTest2Object *a0 = a.array[0];
    SSTest2Object *a1 = a.array[1];
    XCTAssert([a0.text isEqualToString:@"a0"]);
    XCTAssert([a1.text isEqualToString:@"a1"]);
    
    SSTest2Object *b0 = b.array[0];
    SSTest2Object *b1 = b.array[1];
    XCTAssert([b0.text isEqualToString:@"a0"]);
    XCTAssert([b1.text isEqualToString:@"a1"]);
    
    XCTAssert(a0 != b0);
    XCTAssert(a1 != b1);
}

- (void)test_setFill
{
    SSTest2Object *obj = [[SSTest2Object alloc] init];
    XCTAssert(!obj.idObject &&
              !obj.text &&
              obj.number == 0 &&
              !obj.array &&
              !obj.dictionary &&
              !obj.other);
    
    [obj ss_setFill];
    
    XCTAssert(!obj.idObject);
    XCTAssert([obj.text isEqualToString:@""]);
    XCTAssert(obj.number == 0);
    XCTAssert([obj.array isEqualToArray:@[]]);
    XCTAssert([obj.dictionary isEqualToDictionary:@{}]);
    
    XCTAssert(!obj.other.idObject);
    XCTAssert([obj.other.text isEqualToString:@""]);
    XCTAssert(obj.other.number == 0);
    XCTAssert([obj.other.array isEqualToArray:@[]]);
    XCTAssert([obj.other.dictionary isEqualToDictionary:@{}]);
}

@end
