//
//  TFAppearanceManager.m
//  TFAppearance
//
//  Created by shenlujia on 2018/6/8.
//

#import "TFAppearanceManager.h"
#import "TFAppearanceStorage.h"
#import "TFAppearance.h"
#import "UIView+TFAppearance.h"

@interface TFAppearanceManager ()

@property (nonatomic, strong) NSHashTable *views;

@end

@implementation TFAppearanceManager

@synthesize appearance = _appearance;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _views = [NSHashTable weakObjectsHashTable];
        
        _designScale = 1;
        _fontScale = 1;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            const CGFloat screenWidth = ({
                CGSize size = UIScreen.mainScreen.bounds.size;
                MIN(size.width, size.height);
            });
            if (screenWidth < 370) {
                _designScale = 0.85;
                _fontScale = 0.95;
            }
            if (screenWidth > 380) {
                _designScale = 1.1;
                _fontScale = 1.05;
            }
        }
    }
    return self;
}

+ (TFAppearanceManager *)manager
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (TFAppearance *)appearance
{
    if (!_appearance) {
        _appearance = [TFAppearanceStorage.storage defaultAppearance];
        NSParameterAssert(_appearance);
    }
    return _appearance;
}

- (void)decorate:(__kindof UIView *)view appearance:(id <TFAppearance>)appearance
{
    if (!view || !appearance) {
        return;
    }
    
#ifdef DEBUG
    if ([appearance isKindOfClass:NSClassFromString(@"TFAppearanceColor_internal")] ||
        [appearance isKindOfClass:[TFAppearanceButtonStyle class]]) {
        NSParameterAssert(view.layer.masksToBounds == NO);
        NSParameterAssert(view.layer.cornerRadius == 0);
        NSParameterAssert(view.layer.borderWidth == 0);
    }
#endif
    
    [self.views addObject:view];
    [view appearance_addObject:appearance];
}

- (CGFloat)roundValue:(CGFloat)value
{
    const CGFloat deviceScale = UIScreen.mainScreen.scale;
    const NSInteger pixels = round(value * deviceScale);
    return pixels / deviceScale;
}

- (CGFloat)scaleDesignValue:(CGFloat)value
{
    return [self roundValue:value * self.designScale];
}

- (CGFloat)scaleFontValue:(CGFloat)value
{
    return [self roundValue:value * self.fontScale];
}

- (void)installAppearance:(TFAppearance *)appearance
{
    if (![appearance isKindOfClass:[TFAppearance class]]) {
        return;
    }
    
    [self.appearance updateWithAppearanceObject:appearance];
    
    for (UIView *view in self.views.allObjects) {
        [view appearance_setNeedsUpdateAppearance];
    }
}

@end
