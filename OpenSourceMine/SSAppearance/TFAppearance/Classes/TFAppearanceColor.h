//
//  TFAppearanceColor.h
//  TFAppearance
//
//  Created by shenlujia on 2018/5/31.
//

#import "TFAppearanceObject.h"
#import "TFAppearanceProtocol.h"

@interface TFAppearanceColor : TFAppearanceObject

@property (nonatomic, copy, readonly) NSString *rgb;
@property (nonatomic, copy, readonly) NSString *hex;
@property (nonatomic, copy, readonly) NSString *alphaValue;

@property (nonatomic, strong, readonly) id <TFAppearance> backgroundType;
@property (nonatomic, strong, readonly) id <TFAppearance> textType;
@property (nonatomic, strong, readonly) id <TFAppearance> borderType;
@property (nonatomic, strong, readonly) id <TFAppearance> shadowType;

@property (nonatomic, strong, readonly) TFAppearanceColor * (^alpha)(CGFloat alpha);

- (UIColor *)color;

@end

@interface TFAppearanceColorGroup : TFAppearanceObject

@property (nonatomic, strong, readonly) TFAppearanceColor *theme; // 主题色
@property (nonatomic, strong, readonly) TFAppearanceColor *lightTheme; // 浅主题色
@property (nonatomic, strong, readonly) TFAppearanceColor *contrast; // 反差色

@property (nonatomic, strong, readonly) TFAppearanceColor *background; // 页面背景色

@property (nonatomic, strong, readonly) TFAppearanceColor *white; // 白色
@property (nonatomic, strong, readonly) TFAppearanceColor *black; // 黑色
@property (nonatomic, strong, readonly) TFAppearanceColor *clear; // 透明

@property (nonatomic, strong, readonly) TFAppearanceColor *darkText; // 一级色 标题和正文 推荐字体16以上
@property (nonatomic, strong, readonly) TFAppearanceColor *lightText1; // 二级色 辅助 推荐字体14
@property (nonatomic, strong, readonly) TFAppearanceColor *lightText2; // 三级色 辅助 推荐字体12
@property (nonatomic, strong, readonly) TFAppearanceColor *lightText3; // 四级色 辅助 推荐字体12

@property (nonatomic, strong, readonly) TFAppearanceColor *line; // 分割线 淡灰色

@end
