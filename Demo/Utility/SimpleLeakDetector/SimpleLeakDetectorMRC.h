//
//  SimpleLeakDetectorMRC.h
//  Demo
//
//  Created by ZZZ on 2020/11/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSLeakDetectorCallback : NSObject

@property (nonatomic, copy, readonly) NSDictionary *total;
@property (nonatomic, copy, readonly) NSDictionary *nonempty;
@property (nonatomic, copy, readonly) NSArray *diffs;
@property (nonatomic, copy, readonly) NSArray *business;
@property (nonatomic, copy, readonly) NSArray *more_than_once;

@end

#ifdef __cplusplus
extern "C" {
#endif

void leak_detector_register_init();
void leak_detector_register_callback(NSTimeInterval interval, void (^callback)(id object));

void leak_detector_enum_live_objects(void (^callback)(const char *class_name, long long pointer));

#ifdef __cplusplus
}
#endif
