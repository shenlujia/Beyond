//
//  TFAppearanceColor.m
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceColor.h"
#import <TFViewDecorator/TFViewDecorator.h>
#import "TFAppearanceManager.h"

#pragma mark - TFAppearanceColor_impl

@interface TFAppearanceColor_internal : TFAppearanceObject <TFAppearance>

@property (nonatomic, weak, readonly) TFAppearanceColor *master;

@property (nonatomic, copy, readonly) NSString *alphaValue;

@end

@implementation TFAppearanceColor_internal

- (instancetype)initWithColor:(TFAppearanceColor *)color
{
    self = [self init];
    if (self) {
        _master = color;
        if ([color isFollower]) {
            _master = [color master];
        }
        _alphaValue = [color.alphaValue copy];
    }
    return self;
}

- (void)decorate:(__kindof UIView *)view
{
    
}

- (void (^)(UIView *))decorate
{
    __weak typeof (self) weak_p = self;
    return ^(UIView *view) {
        [weak_p decorate:view];
    };
}

- (UIColor *)p_color
{
    NSString *alpha = self.alphaValue;
    if (alpha.length == 0) {
        alpha = self.master.alphaValue;
    }
    return [[self class] p_color:self.master.hex rgb:self.master.rgb alpha:alpha];
}

+ (UIColor *)p_color:(NSString *)hex rgb:(NSString *)rgb alpha:(NSString *)alphaValue
{
    TFColorGenerator *generator = [[TFColorGenerator alloc] init];
    generator.hex = hex;
    generator.rgb = rgb;
    generator.alpha = alphaValue;
    return generator.color;
}

@end

#pragma mark - TFAppearanceColor_background

@interface TFAppearanceColor_background : TFAppearanceColor_internal

@end

@implementation TFAppearanceColor_background

- (void)decorate:(__kindof UIView *)view
{
    if ([view respondsToSelector:@selector(setBackgroundColor:)]) {
        [TFAppearanceManager.manager decorate:view appearance:self];
        [view setBackgroundColor:[self p_color]];
        return;
    }
}

@end

#pragma mark - TFAppearanceColor_text

@interface TFAppearanceColor_text : TFAppearanceColor_internal

@end

@implementation TFAppearanceColor_text

- (void)decorate:(__kindof UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) {
        [TFAppearanceManager.manager decorate:view appearance:self];
        UIButton *button = view;
        [button setTitleColor:[self p_color] forState:UIControlStateNormal];
        return;
    }
    
    if ([view respondsToSelector:@selector(setTextColor:)]) {
        [TFAppearanceManager.manager decorate:view appearance:self];
        UILabel *label = view;
        [label setTextColor:[self p_color]];
        return;
    }
}

@end

#pragma mark - TFAppearanceColor_border

@interface TFAppearanceColor_border : TFAppearanceColor_internal

@end

@implementation TFAppearanceColor_border

- (void)decorate:(__kindof UIView *)view
{
    [TFAppearanceManager.manager decorate:view appearance:self];
    UIColor *color = [self p_color];
    view.tf_decorator.borderColor = color;
    if (color) {
        if (view.tf_decorator.borderWidth == 0) {
            view.tf_decorator.borderWidth = 1;
        }
        if (!view.tf_decorator.color) {
            view.tf_decorator.color = UIColor.clearColor;
        }
    }
}

@end

#pragma mark - TFAppearanceColor_shadow

@interface TFAppearanceColor_shadow : TFAppearanceColor_internal

@end

@implementation TFAppearanceColor_shadow

- (void)decorate:(__kindof UIView *)view
{
    [TFAppearanceManager.manager decorate:view appearance:self];
    UIColor *color = [self p_color];
    view.tf_decorator.shadowColor = color;
    if (view.tf_decorator.shadowOpacity == 0 && color) {
        view.tf_decorator.shadowOpacity = 1;
    }
}

@end

#pragma mark - TFAppearanceColor

@interface TFAppearanceColor ()

@end

@implementation TFAppearanceColor

@synthesize backgroundType = _backgroundType;
@synthesize textType = _textType;
@synthesize borderType = _borderType;
@synthesize shadowType = _shadowType;

+ (NSDictionary *)ss_replacedKeyFromPropertyName
{
    return @{@"alphaValue" : @"alpha"};
}

+ (NSArray *)ss_ignoredPropertyNames
{
    NSArray *ret = @[@"alpha",
                     @"backgroundType",
                     @"textType",
                     @"borderType",
                     @"shadowType"];
    
    NSArray *temp = [super ss_ignoredPropertyNames];
    if (temp.count) {
        ret = [ret arrayByAddingObjectsFromArray:temp];
    }
    
    return ret;
}

- (void)updateWithAppearanceObject:(TFAppearanceObject *)object
{
    if (![object isKindOfClass:[TFAppearanceColor class]]) {
        return;
    }
    
    [super updateWithAppearanceObject:object];
    
    TFAppearanceColor *other = (TFAppearanceColor *)object;
    
    _rgb = [other.rgb copy];
    _hex = [other.hex copy];
    _alphaValue = [other.alphaValue copy];
}

- (TFAppearanceColor * (^)(CGFloat))alpha
{
    __weak typeof (self) weak_p = self;
    return ^(CGFloat alpha) {
        __strong typeof (weak_p) strong_p = weak_p;
        TFAppearanceColor *object = [strong_p createFollower];
        object->_alphaValue = @(alpha).stringValue;
        return object;
    };
}

- (id <TFAppearance>)backgroundType
{
    if (!_backgroundType) {
        _backgroundType = [[TFAppearanceColor_background alloc] initWithColor:self];
    }
    return _backgroundType;
}

- (id <TFAppearance>)textType
{
    if (!_textType) {
        _textType = [[TFAppearanceColor_text alloc] initWithColor:self];
    }
    return _textType;
}

- (id <TFAppearance>)borderType
{
    if (!_borderType) {
        _borderType = [[TFAppearanceColor_border alloc] initWithColor:self];
    }
    return _borderType;
}

- (id <TFAppearance>)shadowType
{
    if (!_shadowType) {
        _shadowType = [[TFAppearanceColor_shadow alloc] initWithColor:self];
    }
    return _shadowType;
}

- (UIColor *)color
{
    return [TFAppearanceColor_internal p_color:self.hex rgb:self.rgb alpha:self.alphaValue];
}

@end

#pragma mark - TFAppearanceColorGroup

@implementation TFAppearanceColorGroup

@end
