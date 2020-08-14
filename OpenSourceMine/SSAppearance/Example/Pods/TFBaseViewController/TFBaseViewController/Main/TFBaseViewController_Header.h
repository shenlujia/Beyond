//
//  TFBaseViewController_Header.h
//  TFBaseViewController
//
//  Created by shenlujia on 2018/5/12.
//

#import <UIKit/UIKit.h>
#import <JZNavigationExtension/JZNavigationExtension.h>

@interface TFBaseViewController : UIViewController

@property (nonatomic, assign) BOOL navigationBarTranslucent;

- (void)backAction; // 返回按钮事件

@end
