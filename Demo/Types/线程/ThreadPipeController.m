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
@property (nonatomic, assign, readonly) int saved;

@end

@implementation SystemLogHooker

- (void)dealloc
{
    NSPipe *pipe = self.pipe;
//    close(pipe.fileHandleForWriting.fileDescriptor);
    dup2(_saved, fileno(stderr));
    NSLog(@"~%@", NSStringFromClass([self class]));
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSPipe *pipe = [NSPipe pipe];
        _pipe = pipe;
        
        _saved = dup2(pipe.fileHandleForWriting.fileDescriptor, fileno(stderr));
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(redirectNotificationHandle:)
                                                   name:NSFileHandleReadCompletionNotification
                                                 object:pipe.fileHandleForReading];
        [pipe.fileHandleForReading readInBackgroundAndNotify];
    }
    return self;
}

- (void)redirectNotificationHandle:(NSNotification *)n
{
    NSData *data = n.userInfo[NSFileHandleNotificationDataItem];
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (self.callback) {
        self.callback(text);
    }
    [n.object readInBackgroundAndNotify];
}

- (void)close
{
    
}

@end

@interface ThreadPipeController ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) SystemLogHooker *hooker;

@end

@implementation ThreadPipeController

- (void)dealloc
{
    self.hooker;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WEAKSELF
    
    CGRect frame = self.view.bounds;
    frame.size.height /= 3;
    frame.origin.y = self.view.bounds.size.height - frame.size.height;
    self.textView = [[UITextView alloc] initWithFrame:frame];
    [self.view addSubview:self.textView];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.hooker = [[SystemLogHooker alloc] init];
    self.hooker.callback = ^(NSString *text) {
        text = text ?: @"";
        [weak_s.textView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:text]];
        NSRange range;
        range.location = weak_s.textView.text.length - 1;
        range.length = 0;
        [weak_s.textView scrollRangeToVisible:range];
    };
    
    [self test:@"log" tap:^(UIButton *button, NSDictionary *userInfo) {
        NSLog(@"%@", NSDate.date);
    }];
}

@end
