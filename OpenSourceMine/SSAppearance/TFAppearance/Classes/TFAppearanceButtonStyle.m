//
//  TFAppearanceButtonStyle.m
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceButtonStyle.h"
#import "TFAppearanceManager.h"

@implementation TFAppearanceButtonStyle

- (void)decorate:(__kindof UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) {
        [TFAppearanceManager.manager decorate:view appearance:self];
        [view setNeedsLayout];
    }
}

- (void (^)(UIView *))decorate
{
    __weak typeof (self) weak_p = self;
    return ^(UIView *view) {
        [weak_p decorate:view];
    };
}

@end

@implementation TFAppearanceButtonStyleGroup

@end
