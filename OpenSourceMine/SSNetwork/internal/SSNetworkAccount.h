//
//  SSNetworkAccount.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/14.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSNetworkAccount : NSObject

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSNumber *usId;

+ (instancetype)unarchivedObject;

- (BOOL)archive;

@end
