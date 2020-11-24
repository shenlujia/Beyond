//
//  SimpleLeakDetector.h
//  Demo
//
//  Created by ZZZ on 2020/11/23.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

extern void simple_leak_detect_class(Class c);
extern void simple_leak_detect_object(id object, int depth);
extern void simple_leak_detect_callback(void (^callback)(NSDictionary *leaks), NSTimeInterval interval);
