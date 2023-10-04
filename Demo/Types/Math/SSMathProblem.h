//
//  SSMathProblem.h
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSMathProblem <NSObject>

@property (nonatomic, strong, readonly) NSString *string;
@property (nonatomic, strong, readonly) NSString *answer;

@end

@interface SSMathProblem : NSObject <SSMathProblem>

@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSString *answer;

@end
