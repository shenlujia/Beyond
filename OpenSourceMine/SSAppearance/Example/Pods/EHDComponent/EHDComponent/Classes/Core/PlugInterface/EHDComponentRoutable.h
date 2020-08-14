//
//  EHDComponentRoutable.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//
#import <UIKit/UIKit.h>
/**
 *  一个组件可运行接口
 */
//NS_ASSUME_NONNULL_BEGIN
@class EHDUIBus, EHDEventBus;
@protocol EHDComponentRoutable <NSObject>
@optional
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
@property (nonatomic, copy, nullable, readonly) NSDictionary *URLParams;
/**
 *  上一个URL组件传递过来的自定义数据对象
 */
@property (nonatomic, copy, nullable, readonly) id extraData;
/**
 *  数据回传时的回调
 */
@property (nonatomic, copy, nullable, readonly) void (^completionBlock)(id result);

/**
 *  接收到组件的消息事件
 *
 *  @param eventName  消息名
 *  @param intentData 消息数据
 */
- (void)receiveComponentEventName:(NSString *)eventName intentData:(id)intentData;
/**
 *  返回组件视图层
 *
 */
- (UIViewController *)componentUInterface;
@end
//NS_ASSUME_NONNULL_END
