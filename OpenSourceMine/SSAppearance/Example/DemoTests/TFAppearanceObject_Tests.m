//
//  TFAppearanceObject_Tests.m
//  DemoTests
//
//  Created by shenlujia on 2018/6/11.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TFAppearance/TFAppearance.h>

@interface TFAppearanceObject_Tests : XCTestCase

@property (nonatomic, copy) TFAppearanceColor *color0;
@property (nonatomic, copy) TFAppearanceColor *color1;
@property (nonatomic, copy) TFAppearanceColor *color2;

@end

@implementation TFAppearanceObject_Tests

- (void)setUp
{
    [super setUp];
    
    self.color0 = [[TFAppearanceColor alloc] init];
    self.color1 = [[TFAppearanceColor alloc] init];
    self.color2 = [[TFAppearanceColor alloc] init];
    
    [self.color0 setValue:@"111111" forKey:@"hex"];
    [self.color0 setValue:@"1" forKey:@"alphaValue"];
    [self.color1 setValue:@"222222" forKey:@"hex"];
    [self.color1 setValue:@"0.6" forKey:@"alphaValue"];
    [self.color2 setValue:@"333333" forKey:@"hex"];
    [self.color2 setValue:@"0.2" forKey:@"alphaValue"];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_follower_leader
{
    TFAppearanceColor *original = self.color0;
    XCTAssert([original.hex isEqualToString:@"111111"]);
    XCTAssert([original.alphaValue isEqualToString:@"1"]);
    
    TFAppearanceColor *object = [original follower];
    XCTAssert([object.hex isEqualToString:original.hex]);
    XCTAssert([object.alphaValue isEqualToString:original.alphaValue]);
}

- (void)test_leader
{
    TFAppearanceColor *original = self.color0;
    XCTAssert([original.hex isEqualToString:@"111111"]);
    XCTAssert([original.alphaValue isEqualToString:@"1"]);
    
    XCTAssert([[original follower] leader] == original);
}

- (void)test_updateWithAppearanceObject
{
    TFAppearanceColor *original = self.color0;
    XCTAssert([original.hex isEqualToString:@"111111"]);
    XCTAssert([original.alphaValue isEqualToString:@"1"]);
    
    [original updateWithAppearanceObject:self.color1];
    
    XCTAssert([original.hex isEqualToString:self.color1.hex]);
    XCTAssert([original.alphaValue isEqualToString:self.color1.alphaValue]);
}

@end
