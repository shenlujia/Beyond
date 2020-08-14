//
//  NSDate+SSJSONSerialization.h
//  MJExtension
//
//  Created by admin on 2018/5/31.
//

#import <Foundation/Foundation.h>

#define M_SECOND_IN_MINUTE  60
#define M_SECOND_IN_HOUR    3600
#define M_SECOND_IN_DAY     86400
#define M_SECOND_IN_WEEK    604800

@interface NSDate (SSJSONSerialization)

@property (readonly) NSInteger ss_year;
@property (readonly) NSInteger ss_month;
@property (readonly) NSInteger ss_day;
@property (readonly) NSInteger ss_hour;
@property (readonly) NSInteger ss_minute;
@property (readonly) NSInteger ss_second;

// NSNumber 毫秒数
// NSNumber 秒数
// NSString `yyyy-MM-dd`
// NSString `yyyy-MM-dd HH:mm`
// NSString `yyyy-MM-dd HH:mm:ss`
+ (instancetype)ss_dateWithObject:(id)object;
- (NSString *)ss_stringWithFormat:(NSString *)format;

@end
