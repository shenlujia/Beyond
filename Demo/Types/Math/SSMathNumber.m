//
//  SSMathNumber.m
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import "SSMathNumber.h"

@implementation SSMathNumber

- (NSString *)signText
{
    NSString *text = @"?";
    switch (self.sign) {
        case SSMathNumberSignPlus:
            text = @"+";
            break;
        case SSMathNumberSignMinus:
            text = @"-";
            break;
    }
    return text;
}

@end
