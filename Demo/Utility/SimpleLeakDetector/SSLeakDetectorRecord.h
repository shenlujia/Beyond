//
//  SSLeakDetectorRecord.h
//  Beyond
//
//  Created by ZZZ on 2021/3/3.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSLeakDetectorRecord : NSObject

@property (nonatomic, copy, readonly) NSDictionary *total;
@property (nonatomic, copy, readonly) NSDictionary *nonempty;
@property (nonatomic, copy, readonly) NSArray *diffs;
@property (nonatomic, copy, readonly) NSArray *business;
@property (nonatomic, copy, readonly) NSArray *more_than_once;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

@end
