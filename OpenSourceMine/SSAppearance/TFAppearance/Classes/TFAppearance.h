//
//  TFAppearance.h
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceButtonStyle.h"
#import "TFAppearanceCell.h"
#import "TFAppearanceColor.h"
#import "TFAppearanceFont.h"
#import "TFAppearanceTextStyle.h"

/*
 
 ////////// 颜色 //////////
 TFAppearance.color.theme.textType.decorate(view);
 TFAppearance.color.lightTheme.textType.decorate(view);
 TFAppearance.color.contrast.textType.decorate(view);
 

 /////////// 字体 /////////
 TFAppearance.font.size16.bold(YES).decorate(view); // 加粗
 TFAppearance.font.size14.name(@"Oswald-SemiBold").decorate(view); // 自定义字体
 TFAppearance.font.size8.size(38).decorate(view); // 自定义大小
 TFAppearance.font.size8.size(38).bold(YES).decorate(view); // 链式复杂设置
 
 
 /////////// 按钮 /////////
 TFAppearance.button.normalStyle.decorate(view); // 普通
 TFAppearance.button.lightStyle.decorate(view); // 浅色
 TFAppearance.button.hollowStyle.decorate(view); // 中空
 TFAppearance.button.hollowStyle.normal.textColor.decorate(view); // 可以取出子项目设置 不推荐
 
 
 /////////// 文字 /////////
 TFAppearance.text.titleStyle.decorate(view); // 主标题
 TFAppearance.text.detailTitleStyle.decorate(view); // 详情标题
 TFAppearance.text.listTitleStyle.decorate(view); // 列表标题
 TFAppearance.text.bodyStyle.decorate(view); // 正文
 TFAppearance.text.bodyStyle.font.decorate(view); // 可以取出子项目设置 不推荐
 TFAppearance.text.bodyStyle.color.decorate(view); // 可以取出子项目设置 不推荐
 
 */

@interface TFAppearance : TFAppearanceObject

@property (class, strong, readonly) TFAppearanceButtonStyleGroup *button;
@property (class, strong, readonly) TFAppearanceCellGroup *cell;
@property (class, strong, readonly) TFAppearanceColorGroup *color;
@property (class, strong, readonly) TFAppearanceFontGroup *font;
@property (class, strong, readonly) TFAppearanceTextStyleGroup *text;

@property (class, assign, readonly) CGFloat designScale; // 以6为基准
@property (class, strong, readonly) CGFloat (^scale)(CGFloat value); // 以6为基准
@property (class, strong, readonly) CGFloat (^round)(CGFloat value); // 四舍五入到一个像素

+ (instancetype)appearanceWithContentsOfFile:(NSString *)path;

- (void)install;

@end
