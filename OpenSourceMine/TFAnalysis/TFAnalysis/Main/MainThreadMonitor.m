//
//  MainThreadMonitor.m
//  MainThreadMonitor
//
//  Created by shenlujia on 2018/3/5.
//  Copyright © 2018年 shenlujia. All rights reserved.
//

#import "MainThreadMonitor.h"
#import <pthread.h>

#define THREAD_MONITOR_SIG SIGUSR1

void main_thread_sig_call_stack(int sig)
{
    if (sig != THREAD_MONITOR_SIG) {
        return;
    }
    
    NSArray *stackSymbols = [NSThread callStackSymbols];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDateComponents *dateComponents = ({
            static const NSInteger unitFlags = (NSCalendarUnitYear |
                                                NSCalendarUnitMonth |
                                                NSCalendarUnitDay |
                                                NSCalendarUnitHour |
                                                NSCalendarUnitMinute |
                                                NSCalendarUnitSecond);
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar components:unitFlags fromDate:[NSDate date]];
        });
        NSString *time = ({
            NSString *day = ({
                NSString *format = @"%04ld-%02ld-%02ld";
                NSInteger y = dateComponents.year;
                NSInteger m = dateComponents.month;
                NSInteger d = dateComponents.day;
                [NSString stringWithFormat:format, y, m, d];
            });
            NSString *time = ({
                NSString *format = @"%02ld:%02ld:%02ld";
                NSInteger h = dateComponents.hour;
                NSInteger m = dateComponents.minute;
                NSInteger s = dateComponents.second;
                [NSString stringWithFormat:format, h, m, s];
            });
            [NSString stringWithFormat:@"%@ %@", day, time];
        });
        NSString *category = ({
            NSString *format = @"%04ld-%02ld-%02ld";
            NSInteger y = dateComponents.year;
            NSInteger m = dateComponents.month;
            NSInteger d = dateComponents.day;
            [NSString stringWithFormat:format, y, m, d];
        });
        NSString *filename = ({
            NSString *format = @"%02ld-%02ld-%02ld";
            NSInteger h = dateComponents.hour;
            NSInteger m = dateComponents.minute;
            NSInteger s = dateComponents.second;
            [NSString stringWithFormat:format, h, m, s];
        });
        NSString *path = ({
            NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask,
                                                                       YES);
            NSString *ret = [directories.firstObject stringByAppendingPathComponent:@"lag"];
            ret = [ret stringByAppendingPathComponent:category];
            NSFileManager *manager = [[NSFileManager alloc] init];
            [manager createDirectoryAtPath:ret
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
            
            [ret stringByAppendingPathComponent:filename];
        });
        NSString *record = ({
            NSMutableString *ret = [NSMutableString string];
            [ret appendFormat:@"%@\n", time];
            [ret appendString:[stackSymbols componentsJoinedByString:@"\n"]];
            ret;
        });
        [record writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    });
}

@interface MainThreadMonitor ()
{
    NSThread *_monitorThread;
    NSTimer *_workTimer;
    pthread_t _mainThread;
}

@end

@implementation MainThreadMonitor

- (void)dealloc
{
    [_workTimer invalidate];
    _workTimer = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _monitorThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(monitorThreadRun:)
                                                   object:nil];
        [_monitorThread start];
        
        _mainThread = pthread_self();
        signal(THREAD_MONITOR_SIG, main_thread_sig_call_stack);
    }
    return self;
}

+ (MainThreadMonitor *)sharedMonitor
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)monitorThreadRun:(id)object
{
    _monitorThread.name = @"MainThreadMonitor";
    
    _workTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(ping)
                                                userInfo:nil
                                                 repeats:YES];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addTimer:_workTimer forMode:NSRunLoopCommonModes];
    [runloop run];
}

- (void)ping
{
    if (!self.enabled) {
        return;
    }
    
    NSTimer *timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                             target:self
                                                           selector:@selector(timeout:)
                                                           userInfo:nil
                                                            repeats:NO];
    
    __weak NSTimer *weakTimer = timeoutTimer;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong NSTimer *strongTimer = weakTimer;
        [strongTimer invalidate];
    }];
}

- (void)timeout:(NSTimer *)timer
{
    [timer invalidate];
    pthread_kill(_mainThread, THREAD_MONITOR_SIG);
}

@end

