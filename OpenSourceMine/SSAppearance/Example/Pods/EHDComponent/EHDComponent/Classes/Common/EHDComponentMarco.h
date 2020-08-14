//
//  EHDComponentMarco.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#ifndef EHDComponentMarco_h
#define EHDComponentMarco_h

#pragma mark - 单例方法
/**************************************************************/
// 单例模式  给类自动加入单例
#undef	HEAD_SINGLETON
#define HEAD_SINGLETON( __class ) \
+ (__class *)shareInstance;

#undef	IMP_SINGLETON
#define IMP_SINGLETON( __class ) \
static __class *instance_; \
+ (__class *)shareInstance \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once( &onceToken, ^{ instance_ = [[self alloc] init]; } ); \
    return instance_; \
} \
\
+ (__class *)allocWithZone:(struct _NSZone *)zone \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ instance_ = [super allocWithZone:zone]; } ); \
    return instance_; \
}\
\
- (__class *)copyWithZone:(NSZone *)zone \
{\
    return instance_; \
}\

#pragma mark - 导出组件并绑定总线
/**************************************************************/
//导出组件并绑定总线
#undef EHD_EXPORT_COMPONENT
#define EHD_EXPORT_COMPONENT \
- (instancetype)init \
{ \
    self = [super init]; \
    if (self) { \
        [self setValue:[[EHDUIBus alloc] initWithComponentRoutable:self] forKeyPath:@"uiBus"]; \
        [self setValue:[[EHDEventBus alloc] initWithComponentRoutable:self] forKeyPath:@"eventBus"]; \
    } \
    return self; \
} \

#pragma mark - 延时执行
/**************************************************************/
// 延时执行 在主线程中延时执行
#define EHD_DelayStep(step, ExecuteCode) \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(step * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{ \
    ExecuteCode \
});

#pragma mark - 弱引用、强引用 定义引用
/**************************************************************/
// 弱引用、强引用 定义引用
#define EHD_Define_Weak \
__weak __typeof__ (self) self_weak_ = self;
#define EHD_Define_Strong \
__strong __typeof__(self) self = self_weak_;

#pragma mark - 事件总线发送事件消息
/**************************************************************/
// 发送组件消息（参数依次为：事件名，消息数据对象，多个组件多变参数)
#define EHD_SendEventForComponents(eventName, sendData, ...) \
[self.eventBus sendEventName:eventName intentData:sendData, ##__VA_ARGS__, nil];

// 发通知
#define EHD_SendNotification(notiName, sendData) \
[self.eventBus sendNotificationWithName:notiName intentData:sendData];

// 注册通知（参数为多个通知名，使用,分开）
#define EHD_RegisterNotifications(...) \
[self.eventBus registerNotificationsForTarget:self, ##__VA_ARGS__, nil];

// 快速事件类型匹配的宏
#define EHD_EventIs(EventName,ExecuteCode) \
if ([eventName isEqualToString:EventName]) { \
    ExecuteCode \
}

#pragma mark - 消除警告
/**************************************************************/
#define SuppressUndeclaredSelectorLeakWarning(code)                        \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
    code \
    _Pragma("clang diagnostic pop") \
} while (0);


#define SuppressPerformSelectorLeakWarning(code) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
code \
_Pragma("clang diagnostic pop") \
} while (0);

#endif /* EHDComponentMarco_h */
