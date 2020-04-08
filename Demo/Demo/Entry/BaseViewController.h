//
//  BaseViewController.h
//  Demo
//
//  Created by SLJ on 2020/4/8.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ActionBlock)(UIButton *button);

@interface BaseViewController : UIViewController

- (void)test:(NSString *)title setup:(ActionBlock)setup callback:(ActionBlock)callback;

@end
