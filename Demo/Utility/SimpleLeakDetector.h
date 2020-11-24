//
//  SimpleLeakDetector.h
//  Demo
//
//  Created by ZZZ on 2020/11/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSLeakDetectorCallback : NSObject

@property (nonatomic, copy, readonly) NSDictionary *total;
@property (nonatomic, copy, readonly) NSDictionary *nonempty;
@property (nonatomic, copy, readonly) NSArray *business;
@property (nonatomic, copy, readonly) NSArray *more_than_once;

@end


#ifdef __cplusplus
extern "C" {
#endif

void leak_detector_register_class(Class c);
void leak_detector_register_object(id object, int depth);
void leak_detector_register_callback(NSTimeInterval interval, void (^callback)(SSLeakDetectorCallback *object));

#ifdef __cplusplus
}
#endif
