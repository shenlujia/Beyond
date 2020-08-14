//
//  UIViewController+BackButtonItem.m
//  TFBaseViewController
//
//  Created by shenlujia on 2018/6/20.
//

#import "UIViewController+BackButtonItem.h"
#import <objc/runtime.h>

@implementation UIViewController (BackButtonItem)

- (TFNavigationBarBackButtonItem *)tf_backButtonItem
{
    const void * key = @selector(tf_backButtonItem);
    TFNavigationBarBackButtonItem *object = objc_getAssociatedObject(self, key);
    if (![object isKindOfClass:[TFNavigationBarBackButtonItem class]]) {
        object = [[TFNavigationBarBackButtonItem alloc] init];
        self.tf_backButtonItem = object;
    }
    return object;
}

- (void)setTf_backButtonItem:(TFNavigationBarBackButtonItem *)tf_backButtonItem
{
    const void * key = @selector(tf_backButtonItem);
    objc_setAssociatedObject(self, key, tf_backButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)tf_resetBackButtonItemWithTarget:(id)target action:(SEL)action
{
    UIButton *button = self.tf_backButtonItem.button;
    if (!button) {
        button = self.navigationController.tf_backButtonItem.button;
    }
    if (!button) {
        button = self.tf_backButtonItem.defaultButton;
    }
    [button addTarget:target
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    
    const CGSize size = self.navigationController.navigationBar.bounds.size;
    const CGSize buttonSize = [button sizeThatFits:size];
  
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    self.navigationItem.leftBarButtonItem = ({
        [[UIBarButtonItem alloc] initWithCustomView:button];
    });
}

@end
