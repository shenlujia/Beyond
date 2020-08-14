//
//  HSKVORecord.h
//  HSKVO
//
//  Created by shenlujia on 2015/12/22.
//  Copyright © 2015年 shenlujia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSKVORecord : NSObject

@property (nonatomic, copy, readonly) NSString *keyPath;
@property (nonatomic, assign, readonly) NSKeyValueObservingOptions options;
@property (nonatomic, copy, readonly) id block;

- (instancetype)initWithKeyPath:(NSString *)keyPath
                        options:(NSKeyValueObservingOptions)options
                          block:(id)block;

@end
