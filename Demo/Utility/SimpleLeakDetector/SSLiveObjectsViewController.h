//
//  SSLiveObjectsViewController.h
//  Beyond
//
//  Created by ZZZ on 2021/3/4.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSLeakDetectorRecord.h"

@interface SSLiveObjectsViewController : UIViewController

+ (void)showWithObject:(SSLeakDetectorRecord *)object;

@end
