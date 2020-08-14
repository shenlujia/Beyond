//
//  NSObject+ComponentBridge.h
//  Pods
//
//  Created by luohs on 2017/11/7.
//
//

#import <Foundation/Foundation.h>
#import "EHDUIBus.h"
#import "EHDEventBus.h"
//NS_ASSUME_NONNULL_BEGIN
@interface NSObject (ComponentBridge)
/**
 *  UI总线
 */
@property (nonatomic, strong, readonly) __kindof EHDUIBus *uiBus;
/**
 *  事件总线
 */
@property (nonatomic, strong, readonly) __kindof EHDEventBus *eventBus;
/**
 *  上一个URL组件传递过来的URL参数
 */
@property (nonatomic, copy, readonly) NSDictionary *URLParams;

/**
 *  上一个URL组件传递过来的自定义数据对象
 */
@property (nonatomic, copy, nullable, readonly) id extraData;
/**
 *  数据回传时的回调
 */
@property (nonatomic, copy, nullable, readonly) void(^completionBlock)(id result);
@end
//NS_ASSUME_NONNULL_END
