//
//  AppearanceController.m
//  Demo
//
//  Created by SLJ on 2020/4/22.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "AppearanceController.h"

@interface TestAppearanceBaseView : UIView

@property (nonatomic, assign) NSInteger base0;
@property (nonatomic, assign) NSInteger base1;
@property (nonatomic, assign) NSInteger base2;

@end

@implementation TestAppearanceBaseView

@end

@interface TestAppearanceView : TestAppearanceBaseView

@property (nonatomic, assign) NSInteger test_internalChange UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSInteger test_set UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSInteger test_num UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSInteger test_num1 UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSInteger test_num2;

@end

@implementation TestAppearanceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _test_internalChange = 1000;
    return self;
}

- (void)setTest_num:(NSInteger)test_num
{
    _test_num = test_num;
}

@end

@interface AppearanceController ()

@end

@implementation AppearanceController

- (void)viewDidLoad
{
    [super viewDidLoad];

    TestAppearanceBaseView *baseAppearance = [TestAppearanceBaseView appearance];
    TestAppearanceView *childAppearance = [TestAppearanceView appearance];

    baseAppearance.base0 = -1;

    baseAppearance.base1 = 1;
    childAppearance.base1 = 10;

    childAppearance.base2 = 2;
    baseAppearance.base2 = 20;

    childAppearance.test_internalChange = 32;
    childAppearance.test_set = 12345;
    childAppearance.test_num = 5;
    childAppearance.test_num1 = 8;
    childAppearance.test_num2 = 10;

    TestAppearanceView *view = [[TestAppearanceView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [view setValue:@(300) forKey:@"test_set"];
    [self.view addSubview:view];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSParameterAssert(view.base0 == -1); // 子类能获取父类的设置
        NSParameterAssert(view.base1 == 10); // 优先取子类的设置 不管先后
        NSParameterAssert(view.base2 == 2);  // 优先取子类的设置 不管先后

        NSParameterAssert(view.test_internalChange == 32); // 下划线修改属性会被appearance覆盖 所以不要用self.abc方式初始化变量
        NSParameterAssert(view.test_set == 300);           // 已经设过值的不会再变
        NSParameterAssert(view.test_num == 5);
        NSParameterAssert(view.test_num1 == 8);
        NSParameterAssert(view.test_num2 == 10); // UI_APPEARANCE_SELECTOR只是一个声明 不加也是有效的
    });
}

@end
