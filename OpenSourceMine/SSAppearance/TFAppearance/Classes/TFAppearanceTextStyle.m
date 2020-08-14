//
//  TFAppearanceTextStyle.m
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceTextStyle.h"
#import "TFAppearance.h"
#import "UIView+TFAppearance.h"

@interface TFAppearanceTextStyle ()
{
@public
    TFAppearanceFont *_font;
    TFAppearanceColor *_color;
}

@end

@implementation TFAppearanceTextStyle

- (void)decorate:(__kindof UIView *)view
{
    self.font.decorate(view);
    self.color.textType.decorate(view);
}

- (void (^)(UIView *))decorate
{
    __weak typeof (self) weak_p = self;
    return ^(UIView *view) {
        [weak_p decorate:view];
    };
}

@end

@implementation TFAppearanceTextStyleGroup

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        TFAppearanceColorGroup *color = TFAppearance.color;
        TFAppearanceFontGroup *font = TFAppearance.font;
        
        _titleStyle = [[TFAppearanceTextStyle alloc] init];
        self.titleStyle->_color = color.darkText;
        self.titleStyle->_font = font.size20;
        
        _detailTitleStyle = [[TFAppearanceTextStyle alloc] init];
        self.detailTitleStyle->_color = color.darkText;
        self.detailTitleStyle->_font = font.size18;
        
        _listTitleStyle = [[TFAppearanceTextStyle alloc] init];
        self.listTitleStyle->_color = color.darkText;
        self.listTitleStyle->_font = font.size17;
        
        _bodyStyle = [[TFAppearanceTextStyle alloc] init];
        self.bodyStyle->_color = color.darkText;
        self.bodyStyle->_font = font.size16;
        
        _other1Style = [[TFAppearanceTextStyle alloc] init];
        self.other1Style->_color = color.lightText1;
        self.other1Style->_font = font.size14;
        
        _other2Style = [[TFAppearanceTextStyle alloc] init];
        self.other2Style->_color = color.lightText2;
        self.other2Style->_font = font.size12;
        
        _other3Style = [[TFAppearanceTextStyle alloc] init];
        self.other3Style->_color = color.lightText3;
        self.other3Style->_font = font.size12;
    }
    
    return self;
}

@end
