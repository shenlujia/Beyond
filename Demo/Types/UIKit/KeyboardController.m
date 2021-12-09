//
//  KeyboardController.m
//  Beyond
//
//  Created by ZZZ on 2021/12/9.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "KeyboardController.h"
#import <Masonry/Masonry.h>
#import "SSEasy.h"

static const CGFloat kContentHeight = 100;

@interface KeyboardController ()

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation KeyboardController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillChangeFrameNotification:)
                                               name:UIKeyboardWillChangeFrameNotification
                                             object:nil];
    
    self.contentView = ({
        CGRect frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, kContentHeight);
        UIView *view = [[UIView alloc] initWithFrame:frame];
        [self.view addSubview:view];
        view.backgroundColor = UIColor.lightGrayColor;
        
        view;
    });
    
    self.textField = ({
        UITextField *view = [[UITextField alloc] init];
        [self.contentView addSubview:view];
        view.placeholder = @"I am placeholder";
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(view.superview).inset(20);
            make.center.equalTo(view.superview);
        }];
        
        view;
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ss_easy_log(@"viewWillAppear");
    [self.textField becomeFirstResponder];
}

#pragma mark - notification

- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification
{
    CGFloat duration = MAX([notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue], 0.1);
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedRect = [self.view convertRect:keyboardFrame fromView:UIApplication.sharedApplication.delegate.window];
    
    [UIView animateWithDuration:duration animations:^{
        self.contentView.frame = CGRectMake(0, convertedRect.origin.y - kContentHeight, self.view.bounds.size.width, kContentHeight);
    }];
}

@end
