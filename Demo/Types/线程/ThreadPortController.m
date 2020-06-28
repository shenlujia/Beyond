//
//  ThreadPortController.m
//  Demo
//
//  Created by SLJ on 2020/6/22.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ThreadPortController.h"
#import "NSObject+Dealloc.h"

static const int kMessageNormal = 1;
static const int kMessageExit = 10000;

@interface ThreadMessager : NSObject <NSMachPortDelegate>

@property (nonatomic, strong, readonly) NSPort *port;
@property (nonatomic, strong) void (^callback)(NSString *text);

@end

@implementation ThreadMessager

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _port = [NSMachPort port];
        _port.delegate = self;
    }
    return self;
}

- (void)send:(NSString *)text to:(ThreadMessager *)other
{
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableArray *components = [NSMutableArray array];
    if (data) {
        [components addObject:data];
    }
    [other.port sendBeforeDate:NSDate.date msgid:kMessageNormal components:components from:self.port reserved:0];
}

- (void)exit
{
    [self.port sendBeforeDate:NSDate.date msgid:kMessageExit components:nil from:self.port reserved:0];
}

- (void)handlePortMessage:(NSMessagePort *)message
{
    NSNumber *msgid = [message valueForKeyPath:@"msgid"];
    if (![msgid isKindOfClass:[NSNumber class]]) {
        return;
    }
    if (msgid.integerValue == kMessageExit) {
        [NSRunLoop.currentRunLoop removePort:self.port forMode:NSRunLoopCommonModes];
        return;
    }
    NSString *text = nil;
    NSArray *components = [message valueForKeyPath:@"components"];
    NSData *data = components.firstObject;
    if ([data isKindOfClass:[NSData class]]) {
        text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    if (self.callback) {
        self.callback(text);
    }
}

@end

@interface ThreadWorker : NSObject

@property (nonatomic, strong, readonly) ThreadMessager *messager;
@property (nonatomic, strong, readonly) NSThread *thread;

@end

@implementation ThreadWorker

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messager = [[ThreadMessager alloc] init];
        _messager.callback = ^(NSString *text) {
            NSLog(@"%@", NSThread.currentThread);
            NSLog(@"worker: %@", text);
        };
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadRun) object:nil];
        [_thread start];
        _thread.dealloc_callback = ^{
            NSLog(@"~NSThread");
        };
    }
    return self;
}

- (void)threadRun
{
    [NSRunLoop.currentRunLoop addPort:self.messager.port forMode:NSRunLoopCommonModes];
    [NSRunLoop.currentRunLoop run];
}

@end

@interface ThreadPortController ()

@property (nonatomic, strong) ThreadMessager *messager;
@property (nonatomic, strong) ThreadWorker *worker;

@end

@implementation ThreadPortController

- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"这么设计的话runLoop无法退出";
    
    WEAKSELF
    
    _messager = [[ThreadMessager alloc] init];
    [NSRunLoop.currentRunLoop addPort:self.messager.port forMode:NSRunLoopCommonModes];
    _messager.callback = ^(NSString *text) {
        NSLog(@"%@", NSThread.currentThread);
        NSLog(@"main: %@", text);
    };
    
    weak_s.worker = [[ThreadWorker alloc] init];
    
    [weak_s test:@"main to worker" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s.messager send:@"hello" to:weak_s.worker.messager];
    }];
    
    [weak_s test:@"worker to main" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s.worker.messager send:@"world" to:weak_s.messager];
    }];
    
    [weak_s test:@"main to main" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s.messager send:@"main to main" to:weak_s.messager];
    }];
    
    [weak_s test:@"worker to worker" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s.worker.messager send:@"worker to worker" to:weak_s.worker.messager];
    }];
    
    [weak_s test:@"remove worker" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s.worker.messager exit];
    }];
    
    [weak_s test:@"remove main" tap:^(UIButton *button, NSDictionary *userInfo) {
        [weak_s.messager exit];
    }];
}

@end
