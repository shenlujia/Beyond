//
//  BaseViewController.h
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WEAKSELF __weak typeof (self) weak_self = self

typedef void (^ActionBlock)(UIButton *button, NSDictionary *userInfo);

@interface BaseViewController : UIViewController

- (void)test_c:(NSString *)c;

- (void)test_c:(NSString *)c title:(NSString *)title;

- (void)test:(NSString *)title tap:(ActionBlock)tap;

- (void)test:(NSString *)title set:(ActionBlock)setup tap:(ActionBlock)tap;

- (void)test:(NSString *)title set:(ActionBlock)setup action:(SEL)action;

@end
