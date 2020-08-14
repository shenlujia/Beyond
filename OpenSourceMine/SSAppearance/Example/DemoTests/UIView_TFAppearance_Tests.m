//
//  UIView_TFAppearance_Tests.m
//  DemoTests
//
//  Created by shenlujia on 2018/6/11.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import <TFAppearance/TFAppearance.h>
#import <TFAppearance/UIView+TFAppearance.h>

@interface UIView_TFAppearance_Tests : XCTestCase

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) TFAppearanceColor *color0;
@property (nonatomic, strong) TFAppearanceColor *color1;
@property (nonatomic, strong) TFAppearanceColor *color2;

@end

@implementation UIView_TFAppearance_Tests

- (void)setUp
{
    [super setUp];
    self.label = [[UILabel alloc] init];
    self.color0 = [[TFAppearanceColor alloc] init];
    self.color1 = [[TFAppearanceColor alloc] init];
    self.color2 = [[TFAppearanceColor alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)test_addObject
{
    [self.label appearance_addObject:self.color0.backgroundType];
    [self.label appearance_addObject:self.color1.backgroundType];
    [self.label appearance_addObject:self.color2.backgroundType];
    
    [self.label appearance_addObject:self.color0.textType];
    [self.label appearance_addObject:self.color1.textType];
    
    
    const void * key = NSSelectorFromString(@"appearance_objectArray");
    NSArray *array = [objc_getAssociatedObject(self.label, key) copy];
    
    NSArray *current = @[self.color2.backgroundType, self.color1.textType];
    XCTAssert([array isEqualToArray:current]);
}

@end
