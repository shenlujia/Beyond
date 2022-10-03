//
//  FindMe.m
//  NameCenter
//
//  Created by ZZZ on 2022/10/3.
//

#import "FindMe.h"

@implementation FindMe

+ (NSArray *)find:(NSString *)string from:(NSArray *)from
{
    if (string.length == 0) {
        return nil;
    }
    
    NSMutableArray *ret = [NSMutableArray array];
    for (NSString *text in from) {
        if ([self match:string local:text]) {
            [ret addObject:text];
        }
    }
    [ret sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1.lowercaseString compare:obj2.lowercaseString];
    }];
    return ret;
}

+ (BOOL)match:(NSString *)string local:(NSString *)local
{
    if (string.length == 0) {
        return NO;
    }
    
    NSString *p_string = [self convertString:string];
    NSString *p_local = [self convertString:local];
    
    NSArray *strings = [p_string componentsSeparatedByString:@" "];
    for (NSString *temp in strings) {
        NSString *s = [self convertString:temp];
        if (s.length == 0) {
            continue;
        }
        if (![p_local containsString:s]) {
            return NO;
        }
    }
    
    return YES;
}

+ (NSString *)convertString:(NSString *)text
{
    NSString *string = text.lowercaseString;
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    string = [string stringByReplacingOccurrencesOfString:@"stars" withString:@"star"];
    string = [string stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return string;
}

@end
