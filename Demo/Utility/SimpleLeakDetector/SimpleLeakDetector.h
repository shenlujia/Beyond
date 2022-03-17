//
//  SimpleLeakDetector.h
//  Beyond
//
//  Created by ZZZ on 2021/3/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleLeakDetector : NSObject

+ (void)run;

+ (NSDictionary<Class, NSArray<NSNumber *> *> *)allDetectedLiveObjects; // 通过监听`alloc`获取对象
+ (NSDictionary<Class, NSArray<NSNumber *> *> *)allHeapObjects; // 从堆内获取对象 堆内对象不太可靠

+ (NSArray *)ownersOfObject:(id)object; // 从`allDetectedLiveObjects`内部找引用了`object`的对象 支持`NSString *`、`Class`、`NSObject *`
+ (id)anyOwnerOfObject:(id)object; // 从`allDetectedLiveObjects`内部找任意一个引用了`object`的对象

// 从`allDetectedLiveObjects`内部找符合`classes`类的对象 找到后对其排查循环引用
// `classes`可以包含`Class`或者`NSString`
// `maxCycleLength`为查找深度
+ (NSSet *)findRetainCyclesWithClasses:(NSArray *)classes maxCycleLength:(NSInteger)maxCycleLength;

@end
