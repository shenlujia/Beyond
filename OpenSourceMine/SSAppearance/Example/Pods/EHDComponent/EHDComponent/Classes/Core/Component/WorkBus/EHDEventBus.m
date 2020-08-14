//
//  EHDEventBus.m
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import "EHDEventBus.h"
#import "EHDComponentRoutable.h"
#import "EHDComponentMarco.h"
#import "EHDComponentManager.h"


@interface EHDEventBus ()

/**
 *  可运行组件
 */
@property (nonatomic, weak) __kindof id<EHDComponentRoutable> componentRoutable;

/**
 *  所有用侦听通知的对象
 */
@property (nonatomic, strong) NSMutableArray *observers;
@end

@implementation EHDEventBus
- (instancetype)init
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    return [self initWithComponentRoutable:nil];
#pragma clang diagnostic pop
}

- (instancetype)initWithComponentRoutable:(__kindof id<EHDComponentRoutable>)componentRoutable
{
    self = [super init];
    if (self) {
        _componentRoutable = componentRoutable;
    }
    return self;
}

- (void)sendEventName:(NSString *)eventName intentData:(nullable id)intentData,...
{
    // 指向变参的指针
    va_list args;
    // 使用最后一个参数来初使化list指针
    va_start(args, intentData);
    while (YES) {
        // 返回可变参数，va_arg第二个参数为可变参数类型，如果有多个可变参数，依次调用可获取各个参数
        NSString *componentName = va_arg(args, NSString*);
        if (!componentName || ![componentName isKindOfClass:[NSString class]]) {
            break;
        }
        [EHDComponentManager sendEventName:eventName intentData:intentData forComponent:componentName];
    }
    // 结束可变参数的获取
    va_end(args);
}

- (void)sendEventName:(NSString *)eventName intentData:(nullable id)intentData forComponents:(NSArray<NSString *> *)componentNames
{
    for (NSString *componentName in componentNames) {
        [EHDComponentManager sendEventName:eventName intentData:intentData forComponent:componentName];
    }
}

- (void)sendNotificationWithName:(NSString *)notiName intentData:(nullable id)intentData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notiName object:nil userInfo:intentData];
}

- (void)registerNotificationsForTarget:(id)target,... {
    // 如果没有接收方法，直接返回
    if (![self.componentRoutable respondsToSelector:@selector(receiveComponentEventName:intentData:)]) {
        return;
    }
    va_list args;
    va_start(args, target);
    while (YES) {
        NSString *notiName = va_arg(args, NSString*);
        if (!notiName) {
            break;
        }
        [self _innerRegisterNotiName:notiName];
    }
    va_end(args);
}

- (void)registerNotifications:(NSArray<NSString *> *)notiNames
{
    if (notiNames == nil || notiNames.count == 0) {
        return;
    }
    for (NSString *notiName in notiNames) {
        [self _innerRegisterNotiName:notiName];
    }
}

- (void)_innerRegisterNotiName:(NSString *)notiName
{
    EHD_Define_Weak
    // 侦听通知
    id<NSObject> observer =
    [[NSNotificationCenter defaultCenter] addObserverForName:notiName
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
         EHD_Define_Strong
         // 通知组件接收事件
         [self.componentRoutable receiveComponentEventName:note.name intentData:note.userInfo];
     }];
    // 添加到侦听数组
    [self.observers addObject:observer];
}

- (NSMutableArray *)observers
{
    if (_observers == nil) {
        _observers = [NSMutableArray array];
    }
    return _observers;
}

// 删除所有侦听
- (void)_removeObservers {
    if (_observers) {
        for (id<NSObject> observer in _observers) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }
        _observers = nil;
    }
}

- (void)dealloc
{
    [self _removeObservers];
}
@end
