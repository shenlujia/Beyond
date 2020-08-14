//
//  BaseViewController.h
//  Demo
//
//  Created by TF020283 on 2018/9/27.
//  Copyright © 2018 TF020283. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

- (UIButton *)addCaseWithTitle:(NSString *)title block:(void (^)(UIButton *button))block;

@end

NS_ASSUME_NONNULL_END
