//
//  BaseViewController.h
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>


#define WEAKSELF __weak typeof (self) weak_s = self;
#define STRONGSELF __strong typeof (weak_s) self = weak_s;


#define kButtonTapCountKey @"count"

FOUNDATION_EXTERN UIEdgeInsets app_safeAreaInsets(void);

static void inline ss_print_cost(NSString *title, dispatch_block_t block) {
    double start = CFAbsoluteTimeGetCurrent();
    if (block != nil) {
        block();
    }
    double end = CFAbsoluteTimeGetCurrent();
    NSString *text = [NSString stringWithFormat:@"[slj_cost] %@: %f", title, end - start];
    printf("%s\n", text.UTF8String);
};


typedef void (^ActionBlock)(UIButton *button, NSDictionary *userInfo);

@interface BaseViewController : UIViewController

- (void)add_navi_right_item:(NSString *)title tap:(ActionBlock)tap;

- (void)observe:(NSString *)name block:(void (^)(NSNotification *notification))block;

- (void)set_insets:(UIEdgeInsets)insets;

- (void)test_c:(NSString *)c;

- (void)test_c:(NSString *)c title:(NSString *)title;

- (void)test:(NSString *)title tap:(ActionBlock)tap;

- (void)test:(NSString *)title set:(ActionBlock)setup tap:(ActionBlock)tap;

- (void)test:(NSString *)title set:(ActionBlock)setup action:(SEL)action;

@end
