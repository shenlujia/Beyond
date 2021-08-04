//
//  NSObject+DEBUGLog.h
//  Beyond
//
//  Created by ZZZ on 2021/3/17.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DEBUGLog)

+ (NSArray<NSString *> *)ss_ivars;

- (NSDictionary<NSString *, id> *)ss_keyValues;

- (id)ss_JSON;

@end

@interface NSArray (DEBUGLog)

@end

NS_ASSUME_NONNULL_END
