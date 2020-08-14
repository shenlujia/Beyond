//
//  PodModel.h
//  FixHeaderImport
//
//  Created by SLJ on 2019/8/7.
//  Copyright © 2019 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PodItem : NSObject

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSDictionary *items; // {@"BBB.h" : @"<AAA/BBB.h>"}

@end

@interface PodModel : NSObject

@property (nonatomic, copy, readonly) NSString *path;

@property (nonatomic, copy, readonly) NSError *error;

@property (nonatomic, copy, readonly) NSDictionary<NSString *, PodItem *> *pods;

- (instancetype)initWithPath:(NSString *)path;

@end
