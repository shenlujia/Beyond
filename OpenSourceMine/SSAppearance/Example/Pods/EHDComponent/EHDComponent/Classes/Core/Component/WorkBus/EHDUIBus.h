//
//  EHDUIBus.h
//  EHDComponent
//
//  Created by luohs on 2017/10/27.
//  Copyright © 2017年 luohs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Activity __kindof UIViewController

//NS_ASSUME_NONNULL_BEGIN
typedef void(^TransitionCompletionBlock)(void);
typedef void(^TransitionBlock)(Activity *thisInterface, Activity *nextInterface, TransitionCompletionBlock completionBlock);

@protocol EHDComponentRoutable;
@interface EHDUIBus : NSObject

/**
 *  可运行组件
 */
@property (nonatomic, weak, readonly) __kindof id<EHDComponentRoutable> componentRoutable;
/**
 *  初始化方法
 *
 *  @param componentRoutable 可运行组件
 *
 *  @return EHDUIBus
 */
- (instancetype)initWithComponentRoutable:(__kindof id<EHDComponentRoutable>)componentRoutable NS_DESIGNATED_INITIALIZER;
/**
 *  自定义打开一个URL组件
 *
 *  @param URL             URL
 *  @param transitionBlock 视图切换代码
 *  @param extraData 自定义配制数据
 *  @param completion 自定义配制代码Block
 */
- (id<EHDComponentRoutable>)openURL:(NSString *)URL
                    transitionBlock:(TransitionBlock)transitionBlock
                          extraData:(id)extraData
                         completion:(void (^)(id result))completion;


/**
 *  自定义打开一个组件
 *
 *  @param componentName componentName
 *  @param transitionBlock 视图切换代码
 *  @param extraData 自定义配制数据
 *  @param completion 自定义配制代码Block
 */
- (id<EHDComponentRoutable>)open:(NSString *)componentName
                 transitionBlock:(TransitionBlock)transitionBlock
                       extraData:(id)extraData
                      completion:(void (^)(id result))completion;
@end
//NS_ASSUME_NONNULL_END
