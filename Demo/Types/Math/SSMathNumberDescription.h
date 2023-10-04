//
//  SSMathNumberDescription.h
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSMathNumberSign.h"

@protocol SSMathNumberDescription <NSObject>

@property (nonatomic, assign, readonly) BOOL enabled;

@property (nonatomic, assign, readonly) BOOL digit1;
@property (nonatomic, assign, readonly) BOOL digit2;
@property (nonatomic, assign, readonly) BOOL digit3;

@property (nonatomic, assign, readonly) BOOL plus;
@property (nonatomic, assign, readonly) BOOL minus;

- (NSInteger)suggestedLength;

- (SSMathNumberSign)suggestedSign;

- (NSInteger)suggestedValue;

@end

@interface SSMathNumberDescription : NSObject <SSMathNumberDescription>

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, assign) BOOL digit1;
@property (nonatomic, assign) BOOL digit2;
@property (nonatomic, assign) BOOL digit3;

@property (nonatomic, assign) BOOL plus;
@property (nonatomic, assign) BOOL minus;

@end
