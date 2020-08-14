//
//  TFLoadingConfiguration.m
//  Pods
//
//  Created by shenlujia on 16/4/1.
//
//

#import "TFLoadingConfiguration.h"
#import <TFAppearance/TFAppearance.h>
#import "TFLoadingStyle.h"

@interface TFLoadingConfiguration()

@property (nonatomic, strong) NSMutableDictionary *styleDictionary;

@end

@implementation TFLoadingConfiguration

static NSBundle *resourceBundle = nil;

+ (void)initialize
{
    if (!resourceBundle) {
        NSString *resourcePath = NSBundle.mainBundle.resourcePath;
        NSString *resourceName = @"TFLoadingView.bundle";
        NSString *bundlePath = [resourcePath stringByAppendingPathComponent:resourceName];
        resourceBundle = [NSBundle bundleWithPath:bundlePath];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ignoreTouchIfStateEmpty = YES;
        _backgroundColor = [TFAppearance.color.background color];;
        _styleDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (TFLoadingConfiguration *)defaultConfiguration
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TFLoadingConfiguration *object = [self p_default];
        [object p_resetDefaultStyle];
    });
    return [self p_default];
}

+ (void)setResourceBundle:(NSBundle *)bundle
{
    resourceBundle = bundle;
}

- (TFLoadingStyle *)styleForState:(TFLoadingState)state
{
    TFLoadingStyle *style = self.styleDictionary[@(state)];
    TFLoadingConfiguration *_default = [TFLoadingConfiguration p_default];
    if (![style isKindOfClass:[TFLoadingStyle class]] && self != _default) {
        style = _default.styleDictionary[@(state)];
    }
    return [style copy];
}

- (void)updateStyle:(TFLoadingStyle *)style forState:(TFLoadingState)state
{
    self.styleDictionary[@(state)] = [style copy];
}

- (void)updateStyleWithBlock:(void (^)(TFLoadingStyle *style))block forState:(TFLoadingState)state
{
    TFLoadingStyle *style = [self styleForState:state];
    if (block) {
        block(style);
    }
    self.styleDictionary[@(state)] = [style copy];
}

+ (TFLoadingConfiguration *)p_default
{
    static TFLoadingConfiguration *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TFLoadingConfiguration alloc] init];
        NSMutableDictionary *styleDictionary = [NSMutableDictionary dictionary];
        styleDictionary[@(TFLoadingStateInit)] = [[TFLoadingStyle alloc] init];
        styleDictionary[@(TFLoadingStateLoading)] = [[TFLoadingStyle alloc] init];
        styleDictionary[@(TFLoadingStateError)] = [[TFLoadingStyle alloc] init];
        styleDictionary[@(TFLoadingStateEmpty)] = [[TFLoadingStyle alloc] init];
        styleDictionary[@(TFLoadingStateEmptyList)] = [[TFLoadingStyle alloc] init];
        styleDictionary[@(TFLoadingStateHidden)] = [[TFLoadingStyle alloc] init];
        instance.styleDictionary = styleDictionary;
    });
    return instance;
}

- (void)p_resetDefaultStyle
{
    TFLoadingStyle *defaultStyle = [[TFLoadingStyle alloc] init];
  
    defaultStyle.verticalAlignment = UIControlContentVerticalAlignmentCenter;
    defaultStyle.contentEdgeInsets = UIEdgeInsetsZero;
    defaultStyle.itemVerticalMargin = 25;
    defaultStyle.itemHorizontalMargin = 15;
    
    [self updateStyle:defaultStyle forState:TFLoadingStateLoading];
    [self updateStyle:defaultStyle forState:TFLoadingStateNoNetwork];
    [self updateStyle:defaultStyle forState:TFLoadingStateError];
    [self updateStyle:defaultStyle forState:TFLoadingStateEmpty];
    [self updateStyle:defaultStyle forState:TFLoadingStateEmptyList];
    
    [self updateStyleWithBlock:^(TFLoadingStyle *style) {
        style.text = @"加载中...";
        style.image = nil;
    } forState:TFLoadingStateLoading];
    
    [self updateStyleWithBlock:^(TFLoadingStyle *style) {
        style.text = @"网络连接失败，请重试";
        style.image = [TFLoadingConfiguration p_imageWithName:@"TF_DeliveryDriverdetailNowifi"];
        style.buttonNormalTitle = @"重新加载";
        style.buttonSize = CGSizeMake(118, 40);
    } forState:TFLoadingStateNoNetwork];
    
    [self updateStyleWithBlock:^(TFLoadingStyle *style) {
        style.text = @"网络连接失败，请重试";
        style.image = [TFLoadingConfiguration p_imageWithName:@"TF_DeliveryDriverdetailNowifi"];
        style.buttonNormalTitle = @"重新加载";
        style.buttonSize = CGSizeMake(118, 40);
    } forState:TFLoadingStateError];
    
    [self updateStyleWithBlock:^(TFLoadingStyle *style) {
        style.text = @"暂无数据";
        style.image = [TFLoadingConfiguration p_imageWithName:@"TF_NoOrder"];
    } forState:TFLoadingStateEmpty];
    
    [self updateStyleWithBlock:^(TFLoadingStyle *style) {
        style.text = @"暂无数据";
        style.image = [TFLoadingConfiguration p_imageWithName:@"TF_NoOrder"];
    } forState:TFLoadingStateEmptyList];
}

+ (UIImage *)p_imageWithName:(NSString *)name
{
    return [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
}

@end
