//
//  TFAppearance.m
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearance.h"
#import "TFAppearanceManager.h"

@interface TFAppearance ()

@property (nonatomic, strong) TFAppearanceButtonStyleGroup *button;
@property (nonatomic, strong) TFAppearanceCellGroup *cell;
@property (nonatomic, strong) TFAppearanceColorGroup *color;
@property (nonatomic, strong) TFAppearanceFontGroup *font;
@property (nonatomic, strong) TFAppearanceTextStyleGroup *text;

@end

@implementation TFAppearance

@synthesize button = _button;
@synthesize cell = _cell;
@synthesize color = _color;
@synthesize font = _font;
@synthesize text = _text;

+ (instancetype)appearanceWithContentsOfFile:(NSString *)path
{
    if (![path isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length == 0) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&error];
    if (error) {
        return nil;
    }
    
    TFAppearance *object = [[TFAppearance alloc] init];
    [object ss_setKeyValues:dictionary];
    
    return object;
}

- (void)install
{
    [TFAppearanceManager.manager installAppearance:self];
}

- (TFAppearanceButtonStyleGroup *)button
{
    if (!_button) {
        _button = [[TFAppearanceButtonStyleGroup alloc] init];
    }
    return _button;
}

- (TFAppearanceCellGroup *)cell
{
    if (!_cell) {
        _cell = [[TFAppearanceCellGroup alloc] init];
    }
    return _cell;
}

- (TFAppearanceColorGroup *)color
{
    if (!_color) {
        _color = [[TFAppearanceColorGroup alloc] init];
    }
    return _color;
}

- (TFAppearanceFontGroup *)font
{
    if (!_font) {
        _font = [[TFAppearanceFontGroup alloc] init];
    }
    return _font;
}

- (TFAppearanceTextStyleGroup *)text
{
    if (!_text) {
        _text = [[TFAppearanceTextStyleGroup alloc] init];
    }
    return _text;
}

+ (TFAppearanceButtonStyleGroup *)button
{
    return TFAppearanceManager.manager.appearance.button;
}

+ (TFAppearanceCellGroup *)cell
{
    return TFAppearanceManager.manager.appearance.cell;
}

+ (TFAppearanceColorGroup *)color
{
    return TFAppearanceManager.manager.appearance.color;
}

+ (TFAppearanceFontGroup *)font
{
    return TFAppearanceManager.manager.appearance.font;
}

+ (TFAppearanceTextStyleGroup *)text
{
    return TFAppearanceManager.manager.appearance.text;
}

+ (CGFloat)designScale
{
    return TFAppearanceManager.manager.designScale;
}

+ (CGFloat (^)(CGFloat))scale
{
    return ^(CGFloat value) {
        return [TFAppearanceManager.manager scaleDesignValue:value];
    };
}

+ (CGFloat (^)(CGFloat))round
{
    return ^(CGFloat value) {
        return [TFAppearanceManager.manager roundValue:value];
    };
}

@end
