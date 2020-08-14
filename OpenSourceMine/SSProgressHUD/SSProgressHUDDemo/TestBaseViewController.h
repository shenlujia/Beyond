//
//  TestBaseViewController.h
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/16.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestParameter.h"

@interface TestBaseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) UISegmentedControl *imageControl;
@property (nonatomic, strong, readonly) UISegmentedControl *textControl;
@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, copy) NSArray *array;

@end
