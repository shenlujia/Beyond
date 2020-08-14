//
//  SSNetworkSession.h
//  SSNetworkDemo
//
//  Created by shenlujia on 2017/8/13.
//  Copyright © 2017年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSNetworkSession : NSObject

@property (nonatomic, copy) NSNumber *timelag;
@property (nonatomic, copy) NSString *unicode;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;

@end
