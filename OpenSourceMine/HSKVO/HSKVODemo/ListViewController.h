//
//  ListViewController.h
//  HSKVO
//
//  Created by shenlujia on 2016/1/13.
//  Copyright © 2016年 shenlujia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController

@property (nonatomic, copy) NSArray *data;

- (void)didSelectIndex:(NSInteger)index;

@end
