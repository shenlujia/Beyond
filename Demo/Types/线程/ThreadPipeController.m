//
//  ThreadPipeController.m
//  Demo
//
//  Created by SLJ on 2020/6/22.
//  Copyright © 2020 SLJ. All rights reserved.
//

#import "ThreadPipeController.h"

@interface SystemLogHooker : NSObject

@property (nonatomic, strong) void (^callback)(NSString *text);
@property (nonatomic, strong, readonly) NSPipe *pipe;
@property (nonatomic, assign, readonly) int old;

@end

@implementation SystemLogHooker

- (void)dealloc
{
    NSLog(@"~%@", NSStringFromClass([self class]));
    [self close];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSPipe *pipe = [NSPipe pipe];
        _pipe = pipe;
        
        _old = dup(fileno(stderr));
        dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stderr));
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(fileHandleReadCompletion:)
                                                   name:NSFileHandleReadCompletionNotification
                                                 object:pipe.fileHandleForReading];
        [pipe.fileHandleForReading readInBackgroundAndNotify];
    }
    return self;
}

- (void)fileHandleReadCompletion:(NSNotification *)n
{
    NSString *text = nil;
    NSData *data = n.userInfo[NSFileHandleNotificationDataItem];
    if (data.length) {
        text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    if (self.callback) {
        self.callback(text);
    }
    [n.object readInBackgroundAndNotify];
}

- (void)close
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    dup2(_old, fileno(stderr));
}

@end

@interface ThreadPipeController ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) SystemLogHooker *hooker;

@end

@implementation ThreadPipeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WEAKSELF
    
    CGRect frame = weak_s.view.bounds;
    frame.size.height /= 3;
    frame.origin.y = weak_s.view.bounds.size.height - frame.size.height;
    weak_s.textView = [[UITextView alloc] initWithFrame:frame];
    [weak_s.view addSubview:weak_s.textView];
    weak_s.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    weak_s.hooker = [[SystemLogHooker alloc] init];
    weak_s.hooker.callback = ^(NSString *text) {
        text = text ?: @"";
        [weak_s.textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:text]];
        NSRange range;
        range.location = weak_s.textView.text.length - 1;
        range.length = 0;
        [weak_s.textView scrollRangeToVisible:range];
    };
    
    [weak_s test:@"log" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSLog(@"%@", NSDate.date);
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.hooker close];
}

@end
