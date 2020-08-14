//
//  NSObject_SSJSONSerialization_Tests.m
//  DemoTests
//
//  Created by admin on 2018/5/31.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TFBaseObject/TFBaseObject.h>

@interface SSTest1Object : TFBaseObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign) NSInteger number;

@property (nonatomic, copy) SSTest1Object *object;
@property (nonatomic, copy) NSArray *array;
@property (nonatomic, copy) NSDictionary *dictionary;
@property (nonatomic, copy) NSDictionary *obj_to_obj;

@end

@implementation SSTest1Object

@end

@interface NSObject_SSJSONSerialization_Tests : XCTestCase

@end

@implementation NSObject_SSJSONSerialization_Tests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_ignoredSystemPropertyNames
{
    NSArray *test = @[@"debugDescription",
                      @"description",
                      @"hash",
                      @"superclass"];
    
    NSArray *array = [NSObject ss_ignoredSystemPropertyNames];
    XCTAssert([array isEqualToArray:test]);
}

- (void)test_classProperties
{
    NSArray *test = @[@"SSTest1Object.array",
                      @"SSTest1Object.date",
                      @"SSTest1Object.dictionary",
                      @"SSTest1Object.number",
                      @"SSTest1Object.obj_to_obj",
                      @"SSTest1Object.object",
                      @"SSTest1Object.text"];
    
    NSDictionary *classProperties = [SSTest1Object ss_classProperties];
    NSArray *array = classProperties[@"SSTest1Object"];
    
    XCTAssert([array isEqualToArray:test]);
}

- (void)test_properties
{
    NSArray *test = @[@"TFBaseObject.debugDescription",
                      @"TFBaseObject.description",
                      @"TFBaseObject.hash",
                      @"TFBaseObject.superclass",
                      @"SSTest1Object.array",
                      @"SSTest1Object.date",
                      @"SSTest1Object.dictionary",
                      @"SSTest1Object.number",
                      @"SSTest1Object.obj_to_obj",
                      @"SSTest1Object.object",
                      @"SSTest1Object.text"];
    
    NSArray *array = [SSTest1Object ss_properties];
    
    XCTAssert([array isEqualToArray:test]);
}

- (void)test_keyValues
{
    const NSInteger number = 5;
    NSDate * const date = [NSDate dateWithTimeIntervalSince1970:1518888000];
    NSString * const text = @"text";
    
    SSTest1Object *(^createObject)(void) = ^SSTest1Object *() {
        SSTest1Object *object = [[SSTest1Object alloc] init];
        
        object.number = number;
        object.date = [date copy];
        object.text = [text copy];
        
        return object;
    };
    
    SSTest1Object *object = createObject();
    object.object = createObject();
    
    object.array = ({
        NSMutableArray *array = [NSMutableArray array];
        
        SSTest1Object *obj = createObject();
        [array addObject:obj];
        
        array;
    });
    
    object.dictionary = ({
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        SSTest1Object *obj = createObject();
        dictionary[@"key"] = obj;
        
        dictionary;
    });
    
    object.obj_to_obj = ({
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        SSTest1Object *key = createObject();
        SSTest1Object *value = createObject();
        dictionary[key] = value;
        
        dictionary;
    });
    
    NSDictionary *keyValues = [object ss_keyValues];
    XCTAssert([keyValues isKindOfClass:[NSDictionary class]]);
    
    void (^checkKeyValues)(NSDictionary *) = ^(NSDictionary *keyValues) {
        
        XCTAssert([keyValues isKindOfClass:[NSDictionary class]]);
        
        NSString *t = keyValues[@"text"];
        XCTAssert([t isEqualToString:text]);
        
        NSNumber *n = keyValues[@"number"];
        XCTAssert([n isEqualToNumber:@(number)]);
        
        NSNumber *d = keyValues[@"date"];
        XCTAssert([d isKindOfClass:[NSNumber class]]);
        NSTimeInterval interval = [date timeIntervalSince1970];
        NSTimeInterval delta = interval - d.doubleValue;
        XCTAssert(fabs(delta) < 0.1);
    };
    
    checkKeyValues(keyValues);
    checkKeyValues(keyValues[@"object"]);
    
    @autoreleasepool {
        NSArray *array = keyValues[@"array"];
        for (NSDictionary *obj in array) {
            checkKeyValues(obj);
        }
    }
    
    @autoreleasepool {
        NSDictionary *dictionary = keyValues[@"dictionary"];
        dictionary = dictionary[@"key"];
        checkKeyValues(dictionary);
    }
    
    @autoreleasepool {
        NSDictionary *obj_to_obj = keyValues[@"obj_to_obj"];
        [obj_to_obj enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            checkKeyValues(key);
            checkKeyValues(obj);
        }];
    }
}

- (void)test_setKeyValues
{
    NSDictionary *keyValues = @{@"text" : @"text",
                                @"date" : @"2018-02-04 06:08:12",
                                @"number" : @"68"};
    
    SSTest1Object *object1 = [[SSTest1Object alloc] init];
    SSTest1Object *object2 = [[SSTest1Object alloc] init];
    [object1 ss_setKeyValues:keyValues];
    [object2 ss_setKeyValues:object1];
    
    XCTAssert([object1.text isEqualToString:@"text"]);
    XCTAssert([[object1.date ss_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"] isEqualToString:@"2018-02-04 06:08:12"]);
    XCTAssert(object1.number == 68);
    
    XCTAssert([object1.text isEqualToString:object2.text]);
    XCTAssert([object1.date isEqualToDate:object2.date]);
    XCTAssert(object1.number == object2.number);
}

@end
