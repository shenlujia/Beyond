//
//  Created by ZZZ on 2020/10/30.
//

#import <Foundation/Foundation.h>

#define PRINT_BLANK_LINE ss_easy_log(@"%@", @"");

FOUNDATION_EXTERN void ss_easy_aweme_cpp_test_start(void);

FOUNDATION_EXTERN NSString * ss_easy_string_with_format(const char *format, va_list args);

FOUNDATION_EXTERN BOOL ss_easy_log_should_filter(NSString *text);

FOUNDATION_EXTERN void ss_easy_log_add_filter_prefix(NSString *filter_prefix);

FOUNDATION_EXTERN void ss_activate_easy_log(void);

FOUNDATION_EXTERN void ss_easy_log_text(NSString *text);

FOUNDATION_EXTERN void ss_easy_log(NSString *format, ...) NS_FORMAT_FUNCTION(1,0);
