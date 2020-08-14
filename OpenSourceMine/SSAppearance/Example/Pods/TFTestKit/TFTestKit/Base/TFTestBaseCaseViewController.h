//
//  TFTestBaseCaseViewController.h
//  AFNetworking
//
//  Created by admin on 2018/6/4.
//

#import <UIKit/UIKit.h>
#import <TFBaseViewController/TFBaseViewController.h>

@interface TFTestBaseCaseViewController : TFBaseViewController

- (UIButton *)addCaseWithTitle:(NSString *)title block:(void (^)(UIButton *button))block;

@end
