//
//  TFLoadingConfiguration.h
//  Pods
//
//  Created by shenlujia on 16/4/1.
//
//

#import <TFBaseObject/TFBaseObject.h>

@class TFLoadingStyle;

typedef NS_ENUM(NSInteger, TFLoadingState) {
    TFLoadingStateInit = 0,
    TFLoadingStateLoading,
    TFLoadingStateNoNetwork,
    TFLoadingStateError,
    TFLoadingStateEmpty,
    TFLoadingStateEmptyList,
    TFLoadingStateHidden
};

@interface TFLoadingConfiguration : TFBaseObject

/// 默认配置
@property (class, strong, readonly) TFLoadingConfiguration *defaultConfiguration;
/// 空白状态是否忽略点击 默认`YES`
@property (nonatomic, assign) BOOL ignoreTouchIfStateEmpty;
/// 默认`nil`
@property (nonatomic, copy) UIColor *backgroundColor;

+ (void)setResourceBundle:(NSBundle *)bundle;

- (TFLoadingStyle *)styleForState:(TFLoadingState)state;

- (void)updateStyle:(TFLoadingStyle *)style forState:(TFLoadingState)state;

- (void)updateStyleWithBlock:(void (^)(TFLoadingStyle *style))block forState:(TFLoadingState)state;

@end
