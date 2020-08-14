//
//  TFAppearanceFont.m
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceFont.h"
#import "TFAppearanceManager.h"

@interface TFAppearanceFont ()

@property (nonatomic, copy) NSString *p_name;
@property (nonatomic, copy) NSNumber *p_size;
@property (nonatomic, copy) NSNumber *p_bold; // 加粗
@property (nonatomic, copy) NSNumber *p_adaptive; // 自适应

@end

@implementation TFAppearanceFont

+ (TFAppearanceFont *)defaultFont
{
    TFAppearanceFont *object = [[TFAppearanceFont alloc] init];
    object.p_name = nil;
    object.p_size = @(16);
    object.p_bold = @(NO);
    object.p_adaptive = @(YES);
    return object;
}

+ (NSArray *)ss_ignoredPropertyNames
{
    NSArray *ret = @[@"name", @"size", @"bold", @"adaptive"];
    
    NSArray *temp = [super ss_ignoredPropertyNames];
    if (temp.count) {
        ret = [ret arrayByAddingObjectsFromArray:temp];
    }
    
    return ret;
}

- (void)updateWithAppearanceObject:(TFAppearanceObject *)object
{
    if (![object isKindOfClass:[TFAppearanceFont class]]) {
        return;
    }
    
    [super updateWithAppearanceObject:object];
    
    TFAppearanceFont *other = (TFAppearanceFont *)object;
    _p_name = [other.p_name copy];
    _p_size = [other.p_size copy];
    _p_bold = [other.p_bold copy];
    _p_adaptive = [other.p_adaptive copy];
}

- (TFAppearanceFont * (^)(NSString *))name
{
    __weak typeof (self) weak_p = self;
    return ^(NSString *name) {
        __strong typeof (weak_p) strong_p = weak_p;
        TFAppearanceFont *object = [strong_p createFollower];
        object.p_name = [name copy];
        return object;
    };
}

- (TFAppearanceFont * (^)(CGFloat))size
{
    __weak typeof (self) weak_p = self;
    return ^(CGFloat size) {
        __strong typeof (weak_p) strong_p = weak_p;
        TFAppearanceFont *object = [strong_p createFollower];
        object.p_size = @(size);
        return object;
    };
}

- (TFAppearanceFont * (^)(BOOL))bold
{
    __weak typeof (self) weak_p = self;
    return ^(BOOL bold) {
        __strong typeof (weak_p) strong_p = weak_p;
        TFAppearanceFont *object = [strong_p createFollower];
        object.p_bold = @(bold);
        return object;
    };
}

- (TFAppearanceFont * (^)(BOOL))adaptive
{
    __weak typeof (self) weak_p = self;
    return ^(BOOL adaptive) {
        __strong typeof (weak_p) strong_p = weak_p;
        TFAppearanceFont *object = [strong_p createFollower];
        object.p_adaptive = @(adaptive);
        return object;
    };
}

- (void)decorate:(__kindof UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) {
        [TFAppearanceManager.manager decorate:view appearance:self];
        UIButton *button = view;
        button.titleLabel.font = [self font];
        return;
    }
    
    if ([view respondsToSelector:@selector(setFont:)]) {
        [TFAppearanceManager.manager decorate:view appearance:self];
        UILabel *temp = view;
        [temp setFont:[self font]];
    }
}

- (void (^)(UIView *))decorate
{
    __weak typeof (self) weak_p = self;
    return ^(UIView *view) {
        [weak_p decorate:view];
    };
}

- (CGFloat)p_sizeValue
{
    NSNumber *ret = self.p_size;
    if (!ret) {
        TFAppearanceFont *master = [self master];
        ret = master.p_size;
    }
    return ret.floatValue;
}

- (NSString *)p_nameValue
{
    NSString *ret = self.p_name;
    if (!ret) {
        TFAppearanceFont *master = [self master];
        ret = master.p_name;
    }
    return ret;
}

- (BOOL)p_boldValue
{
    NSNumber *ret = self.p_bold;
    if (!ret) {
        TFAppearanceFont *master = [self master];
        ret = master.p_bold;
    }
    return ret.boolValue;
}

- (BOOL)p_adaptiveValue
{
    NSNumber *ret = self.p_adaptive;
    if (!ret) {
        TFAppearanceFont *master = [self master];
        ret = master.p_adaptive;
    }
    return ret.boolValue;
}

- (UIFont *)font
{
    CGFloat size = [self p_sizeValue];
    if ([self p_adaptiveValue]) {
        size = [TFAppearanceManager.manager scaleFontValue:size];
    }
    
    NSString *name = [self p_nameValue];
    
    // 自定义字体
    if (name.length) {
        return [UIFont fontWithName:name size:size];
    }
    
    // 加粗字体
    if ([self p_boldValue]) {
        return [UIFont boldSystemFontOfSize:size];
    }
    
    // 系统正常字体
    return [UIFont systemFontOfSize:size];
}

@end

@interface TFAppearanceFontGroup ()

@property (nonatomic, strong, readonly) TFAppearanceFont *defaultFont;

@end

@implementation TFAppearanceFontGroup

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        TFAppearanceFont *font = [TFAppearanceFont defaultFont];
        _defaultFont = font;
        _size8 = font.size(8);
        _size10 = font.size(10);
        _size12 = font.size(12);
        _size14 = font.size(14);
        _size16 = font.size(16);
        _size17 = font.size(17);
        _size18 = font.size(18);
        _size20 = font.size(20);
        _size22 = font.size(22);
        _size24 = font.size(24);
    }
    
    return self;
}

- (TFAppearanceFont * (^)(CGFloat))size
{
    __weak typeof (self) weak_p = self;
    return ^(CGFloat size) {
        __strong typeof (weak_p) strong_p = weak_p;
        TFAppearanceFont *object = [strong_p.defaultFont createFollower];
        object.p_size = @(size);
        return object;
    };
}

@end
