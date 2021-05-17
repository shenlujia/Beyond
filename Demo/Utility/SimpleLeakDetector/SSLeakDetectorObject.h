//
//  SSLeakDetectorObject.h
//  Beyond
//
//  Created by ZZZ on 2021/3/3.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSLeakDetectorObjectItem : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSArray *pointers;

- (NSComparisonResult)compare:(SSLeakDetectorObjectItem *)other;

- (BOOL)hasContent:(NSString *)content;
- (BOOL)hasPrefix:(NSString *)prefix;

@end

@interface SSLeakDetectorObject : NSObject

@property (nonatomic, copy, readonly) NSArray<SSLeakDetectorObjectItem *> *items;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, SSLeakDetectorObjectItem *> *mapping;

- (instancetype)initWithDictionary:(NSDictionary<Class, NSArray<NSNumber *> *> *)dictionary;

@end
