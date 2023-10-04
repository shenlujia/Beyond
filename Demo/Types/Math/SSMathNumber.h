//
//  SSMathNumber.h
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSMathNumberSign.h"

@interface SSMathNumber : NSObject

@property (nonatomic, assign) NSInteger stringLength;

@property (nonatomic, assign) NSInteger value;
@property (nonatomic, assign) SSMathNumberSign sign;

@property (nonatomic, assign) NSInteger currentResult;

- (NSString *)signText;

@end
