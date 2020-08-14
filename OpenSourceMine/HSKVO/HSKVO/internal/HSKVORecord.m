//
//  HSKVORecord.m
//  HSKVO
//
//  Created by shenlujia on 2015/12/22.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import "HSKVORecord.h"

@implementation HSKVORecord

- (instancetype)initWithKeyPath:(NSString *)keyPath
                        options:(NSKeyValueObservingOptions)options
                          block:(id)block
{
    self = [self init];
    if (self) {
        _keyPath = [keyPath copy];
        _options = options;
        _block = [block copy];
    }
    return self;
}

@end
