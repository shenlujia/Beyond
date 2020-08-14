//
//  SSGaugeFPS.m
//  Pods-Demo
//
//  Created by TF020283 on 2018/9/27.
//

#import "SSGaugeFPS.h"

@interface SSGaugeFPS_WeakProxy : NSObject

@property (nonatomic, weak, readonly) id target;

@end

@implementation SSGaugeFPS_WeakProxy

- (instancetype)initWithTarget:(id)target
{
    _target = target;
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.target;
}

@end

@interface SSGaugeFPS ()

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSTimeInterval lastTimestamp;
@property (nonatomic, strong) SSGaugeFPS_WeakProxy *proxy;

@property (nonatomic, strong) CADisplayLink *link;

@end

@implementation SSGaugeFPS

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    self.link.paused = YES;
    [self.link removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

- (instancetype)init
{
    self = [super init];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(applicationDidBecomeActive)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(applicationWillResignActive)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
    
    self.count = 0;
    self.lastTimestamp = 0;
    self.proxy = [[SSGaugeFPS_WeakProxy alloc] initWithTarget:self];
    
    self.link = [CADisplayLink displayLinkWithTarget:self.proxy selector:@selector(linkAction:)];
    [self.link addToRunLoop:NSRunLoop.currentRunLoop forMode:NSRunLoopCommonModes];
    self.link.paused = NO;
    
    return self;
}

#pragma mark - notification

- (void)applicationDidBecomeActive
{
    self.count = 0;
    self.lastTimestamp = 0;
    self.link.paused = NO;
}

- (void)applicationWillResignActive
{
    self.link.paused = YES;
}

#pragma mark - private

- (void)linkAction:(CADisplayLink *)link
{
    if (self.lastTimestamp == 0) {
        self.lastTimestamp = link.timestamp;
        return;
    }
    
    ++self.count;
    NSTimeInterval interval = link.timestamp - self.lastTimestamp;
    if (interval < 1) {
        return;
    }
    
    if (self.callback) {
        self.callback(self.count / interval);
    }
    
    self.lastTimestamp = link.timestamp;
    self.count = 0;
}

@end
