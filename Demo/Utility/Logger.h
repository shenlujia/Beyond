//
//  Logger.h
//  Beyond
//
//  Created by ZZZ on 2021/6/1.
//  Copyright © 2021 SLJ. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef DEBUG
#define NSLog(...) _ss_log_impl(__VA_ARGS__)
#else
#define NSLog(...)
#endif


#define PRINT_BLANK_LINE printf("\n");


FOUNDATION_EXTERN void _ss_log_impl(NSString *format, ...);

