//
//  MainThreadMonitor.h
//  MainThreadMonitor
//
//  Created by shenlujia on 2018/3/5.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainThreadMonitor : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property (atomic, assign) BOOL enabled;

@property (class, readonly) MainThreadMonitor *sharedMonitor;

@end
