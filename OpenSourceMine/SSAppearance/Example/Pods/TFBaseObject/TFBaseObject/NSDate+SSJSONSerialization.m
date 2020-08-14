//
//  NSDate+SSJSONSerialization.m
//  MJExtension
//
//  Created by admin on 2018/5/31.
//

#import "NSDate+SSJSONSerialization.h"

@implementation NSDate (SSJSONSerialization)

- (NSInteger)ss_year
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:self];
    return components.year;
}

- (NSInteger)ss_month
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:self];
    return components.month;
}

- (NSInteger)ss_day
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:self];
    return components.day;
}

- (NSInteger)ss_hour
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate:self];
    return components.hour;
}

- (NSInteger)ss_minute
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:self];
    return components.minute;
}

- (NSInteger)ss_second
{
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitSecond fromDate:self];
    return components.second;
}

+ (instancetype)ss_dateWithObject:(id)object
{
    if ([object respondsToSelector:@selector(longLongValue)]) {
        long long value = [object longLongValue];
        if (value > 10000) {
            return [self p_ss_dateWithNumber:@(value)];
        }
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        return [self p_ss_dateWithString:object];
    }
    
    return nil;
}

+ (instancetype)p_ss_dateWithNumber:(NSNumber *)object
{
    static double flag = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        flag = [[NSDate date] timeIntervalSince1970] * 100;
    });
    
    NSTimeInterval interval = object.doubleValue;
    if (interval <= 0) {
        return nil;
    }
    
    if (interval > flag) {
        // 毫秒 除以 1000
        interval /= 1000;
    }
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

+ (instancetype)p_ss_dateWithString:(NSString *)object
{
    static NSDictionary *dateFormatters = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        NSArray *formats = @[@"yyyy-MM-dd",
                             @"yyyy-MM-dd HH:mm",
                             @"yyyy-MM-dd HH:mm:ss"];
        for (NSString *format in formats) {
            NSDateFormatter *obj = [[NSDateFormatter alloc] init];
            obj.locale = [NSLocale currentLocale];
            obj.dateFormat = format;
            ret[@(format.length)] = obj;
        }
        dateFormatters = [ret copy];
    });
    NSDateFormatter *dateFormatter = dateFormatters[@(object.length)];
    return [dateFormatter dateFromString:object];
}

- (NSString *)ss_stringWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:self];
}

@end
