//
//  EHDBacktraceLogger.h
//  EHDMonitorKit
//
//  Created by yuan-hd on 2018/4/8.
//  Copyright © 2018年 yuansirios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHDBacktraceLogger : NSObject

+ (NSString *)ehd_backtraceOfAllThread;
+ (NSString *)ehd_backtraceOfMainThread;
+ (NSString *)ehd_backtraceOfCurrentThread;
+ (NSString *)ehd_backtraceOfNSThread:(NSThread *)thread;

+ (void)ehd_logMain;
+ (void)ehd_logCurrent;
+ (void)ehd_logAllThread;

+ (NSString *)backtraceLogFilePath;
+ (void)recordLoggerWithFileName:(NSString *)fileName;

@end
