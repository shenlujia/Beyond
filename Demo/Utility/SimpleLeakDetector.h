//
//  SimpleLeakDetector.h
//  Demo
//
//  Created by ZZZ on 2020/11/15.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef __cplusplus
extern "C" {
#endif

void leak_detector_register_class(Class c);
void leak_detector_register_object(id object, int depth);
void leak_detector_register_callback(void (^callback)(NSDictionary *business, NSDictionary *total), NSTimeInterval interval);

#ifdef __cplusplus
}
#endif
