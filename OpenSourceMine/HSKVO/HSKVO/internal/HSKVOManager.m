//
//  HSKVO.m
//  HSKVO
//
//  Created by shenlujia on 2015/12/25.
//

#import "HSKVOManager.h"
#import "HSKVOPrivate.h"
#import "HSKVOObserver.h"

@interface HSKVOManager () <HSKVOObserverDelegate>

@property (nonatomic, weak, readonly) id observer;

@end

@implementation HSKVOManager
{
    NSLock *_lock;
    NSMutableSet<HSKVOObserver *> *_realObservers;
}

#pragma mark - lifecycle

- (void)dealloc
{
    HSKVOLog(@"~%@", NSStringFromClass([self class]));
    
    // self.observer 观察 self.observer 的 bug 处理：
    // self.observer 强引用 KVO，KVO 强引用 HSKVOObserver。
    // 释放时 self.observer，KVO 其次，HSKVOObserver 最后，此时 unobserveAll 会有问题。
    // realObservers 延迟释放，保证 observerObjectWillDealloc 首先调用。
    [_lock lock];
    __unused NSArray *realObservers = [_realObservers.allObjects copy];
    [_lock unlock];
}

- (instancetype)initWithObserver:(id)observer
{
    self = [super init];
    if (self) {
        _observer = observer;
        _lock = [[NSLock alloc] init];
        _realObservers = [NSMutableSet set];
    }
    return self;
}

#pragma mark - HSKVO

- (void)observe:(id)object
        keyPath:(NSString *)keyPath
        options:(NSKeyValueObservingOptions)options
          block:(HSKVONotificationBlock)block
{
    if (!object || !keyPath || !block) {
        return;
    }
    
    [_lock lock];
    HSKVOObserver *realObserver = [_realObservers member:object];
    if (!realObserver) {
        realObserver = [[HSKVOObserver alloc] initWithObject:object];
        realObserver.delegate = self;
        [_realObservers addObject:realObserver];
    }
    [_lock unlock];
    
    [realObserver observe:keyPath options:options block:block];
}

- (void)observe:(id)object
       keyPaths:(NSArray<NSString *> *)keyPaths
        options:(NSKeyValueObservingOptions)options
          block:(HSKVONotificationBlock)block
{
    for (NSString *keyPath in keyPaths) {
        [self observe:object keyPath:keyPath options:options block:block];
    }
}

- (void)unobserve:(id)object keyPath:(NSString *)keyPath
{
    if (!object || !keyPath) {
        return;
    }
    
    [_lock lock];
    HSKVOObserver *realObserver = [_realObservers member:object];
    [_lock unlock];
    
    [realObserver unobserve:keyPath];
}

- (void)unobserve:(id)object
{
    if (!object) {
        return;
    }
    
    [_lock lock];
    HSKVOObserver *realObserver = [_realObservers member:object];
    if (realObserver) {
        [_realObservers removeObject:realObserver];
    }
    [_lock unlock];
    
    [realObserver unobserveAll];
}

- (void)unobserveAll
{
    [_lock lock];
    NSArray *realObservers = [_realObservers.allObjects copy];
    [_realObservers removeAllObjects];
    [_lock unlock];
    
    for (id realObserver in realObservers) {
        [realObserver unobserveAll];
    }
}

#pragma mark - HSKVOObserverDelegate

- (void)observer:(HSKVOObserver *)observer
      didObserve:(NSString *)keyPath
        ofObject:(id)object
          change:(NSDictionary *)change
           block:(id)block
{
    NSMutableDictionary *mChange = [NSMutableDictionary dictionary];
    mChange[HSKVONotificationKeyPathKey] = keyPath;
    [mChange addEntriesFromDictionary:change];
    
    HSKVONotificationBlock callback = block;
    if (callback && self.observer && object) {
        callback(self.observer, object, change);
    }
}

- (void)observerObjectWillDealloc:(HSKVOObserver *)observer
{
    [_lock lock];
    [_realObservers removeObject:observer];
    [_lock unlock];
}

@end
