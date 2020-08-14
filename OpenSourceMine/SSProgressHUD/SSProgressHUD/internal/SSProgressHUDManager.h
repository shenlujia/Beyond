//
//  SSProgressHUDManager.h
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/15.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSProgressHUD;

@interface SSProgressHUDManager : NSObject

+ (instancetype)sharedManager;

- (void)show:(SSProgressHUD *)progressHUD;
- (void)hide:(SSProgressHUD *)progressHUD;
- (void)hideAll;

@end
