//
//  TFAppearanceTextStyle.h
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceColor.h"
#import "TFAppearanceFont.h"

@interface TFAppearanceTextStyle : TFAppearanceObject <TFAppearance>

@property (nonatomic, strong, readonly) TFAppearanceFont *font;
@property (nonatomic, strong, readonly) TFAppearanceColor *color;

@end

@interface TFAppearanceTextStyleGroup : TFAppearanceObject

@property (nonatomic, strong, readonly) TFAppearanceTextStyle *titleStyle; // 主标题 20pt 一级色
@property (nonatomic, strong, readonly) TFAppearanceTextStyle *detailTitleStyle; // 详情标题 18pt 一级色
@property (nonatomic, strong, readonly) TFAppearanceTextStyle *listTitleStyle; // 列表标题 17pt 一级色

@property (nonatomic, strong, readonly) TFAppearanceTextStyle *bodyStyle; // 正文 16pt 一级色

@property (nonatomic, strong, readonly) TFAppearanceTextStyle *other1Style; // 其他 14pt 二级色
@property (nonatomic, strong, readonly) TFAppearanceTextStyle *other2Style; // 其他 12pt 三级色
@property (nonatomic, strong, readonly) TFAppearanceTextStyle *other3Style; // 其他 12pt 四级色

@end
