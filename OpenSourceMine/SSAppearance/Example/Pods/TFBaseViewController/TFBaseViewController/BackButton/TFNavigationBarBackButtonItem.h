//
//  TFNavigationBarBackButtonItem.h
//  TFBaseViewController
//
//  Created by shenlujia on 2018/6/21.
//

#import <Foundation/Foundation.h>

@interface TFNavigationBarBackButtonItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong, readonly) UIButton *button;
@property (nonatomic, strong, readonly) UIButton *defaultButton;

@end
