//
//  UIViewController+BackButtonItem.h
//  TFBaseViewController
//
//  Created by shenlujia on 2018/6/20.
//

#import <UIKit/UIKit.h>
#import "TFNavigationBarBackButtonItem.h"

@interface UIViewController (BackButtonItem)

@property (nonatomic, strong) TFNavigationBarBackButtonItem *tf_backButtonItem;

- (void)tf_resetBackButtonItemWithTarget:(id)target action:(SEL)action;

@end
