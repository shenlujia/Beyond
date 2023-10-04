//
//  SSMathUtil.h
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSMathUtil : NSObject

+ (NSInteger)randomValueWithLength:(NSInteger)length;

+ (NSInteger)randomValueWithMax:(NSInteger)max;

+ (NSInteger)digitCount:(NSInteger)value;

@end
