//
//  NotMainThreadClassDetector.h
//  Beyond
//
//  Created by ZZZ on 2021/2/7.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

// 检测对象在非主线程修改属性 打印堆栈

@interface NotMainThreadClassDetector : NSObject

+ (void)checkClass:(Class)c;

+ (void)setCallback:(void (^)(NSDictionary *userInfo))callback;

@end
