//
//  SSProgressHUDLabel.m
//  SSProgressHUD
//
//  Created by shenlujia on 2015/5/16.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "SSProgressHUDLabel.h"

@implementation SSProgressHUDLabel

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize ret = [super sizeThatFits:size];
    ret.width = MIN(ret.width, size.width);
    ret.height = MIN(ret.height, size.height);
    return ret;
}

@end
