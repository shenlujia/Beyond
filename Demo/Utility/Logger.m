//
//  Logger.m
//  Beyond
//
//  Created by ZZZ on 2021/6/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import "Logger.h"

void log_impl(NSString *format, ...)
{
    if (!format) {
        return;
    }

    va_list args;
    va_start(args, format);

    NSString *text = [[NSString alloc] initWithFormat:format arguments:args];
    printf("%s\n", text.UTF8String);

    va_end(args);
}
