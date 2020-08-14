//
//  FBKVOControllerTests.m
//  HSKVOTests
//
//  Created by shenlujia on 2016/3/7.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KVOController/KVOController.h>
#import "NSObject+HSKVO.h"

#define KVO_NAME_KEY @"name"

@interface CompareTestObject : NSObject

@property (nonatomic, copy) NSString *name;

@end

@implementation CompareTestObject

@end

@interface CompareTests : XCTestCase

@end

@implementation CompareTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testObserveSameKeyTwice
{
    __block NSInteger fbkvo_count = 0;
    __block NSInteger hskvo_count = 0;
    
    CompareTestObject *object = [[CompareTestObject alloc] init];
    
    [self.KVOController observe:object
                        keyPath:KVO_NAME_KEY
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              ++fbkvo_count;
    }];
    [self.KVOController observe:object
                        keyPath:KVO_NAME_KEY
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change) {
                              ++fbkvo_count;
                          }];
    [self.HSKVO observe:object
                keyPath:KVO_NAME_KEY
                options:NSKeyValueObservingOptionNew
                  block:^(id observer, id object, NSDictionary *change) {
                      ++hskvo_count;
    }];
    [self.HSKVO observe:object
                keyPath:KVO_NAME_KEY
                options:NSKeyValueObservingOptionNew
                  block:^(id observer, id object, NSDictionary *change) {
                      ++hskvo_count;
                  }];
    
    object.name = @"aha";
    
    XCTAssert(fbkvo_count == 1 && hskvo_count == 2);
}

@end
