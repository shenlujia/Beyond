//
//  SSMathNumber.m
//  Beyond
//
//  Created by ZZZ on 2023/10/4.
//  Copyright © 2023 SLJ. All rights reserved.
//

#import "SSMathNumber.h"

@implementation SSMathNumber

- (void)updateWithLastValue:(NSInteger)lastValue
{
    switch (self.sign) {
        case SSMathNumberSignPlus: {
            _currentResult = lastValue + self.value;
            _didCarry = ((lastValue % 10) + (self.value % 10)) >= 10;
            break;
        }
        case SSMathNumberSignMinus: {
            _currentResult = lastValue - self.value;
            _didCarry = ((lastValue % 10) - (self.value % 10)) < 0;
            break;
        }
    }
}

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
